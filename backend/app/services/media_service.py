import hashlib
import io
import os
from datetime import datetime
from PIL import Image, ImageOps

from app.core.config import get_settings

settings = get_settings()

MAX_IMAGE_DIMENSION = 1920
THUMBNAIL_DIMENSION = 240
WEBP_QUALITY = 82
THUMBNAIL_QUALITY = 75
ALLOWED_FORMATS = {'JPEG', 'PNG', 'WEBP', 'BMP', 'TIFF', 'MPO'}


class MediaService:
    def __init__(self, media_dir: str | None = None) -> None:
        self.media_dir = os.path.abspath(media_dir or settings.media_dir)
        os.makedirs(self.media_dir, exist_ok=True)

    def process_and_save_image(self, file_bytes: bytes, filename: str = 'image.png') -> dict:
        """
        Validates, optimizes, and stores an image on local disk:
        1. Validates image format using Pillow.
        2. Normalizes orientation and strips EXIF metadata.
        3. Generates SHA-256 hash for deduplication.
        4. Scales down if exceeding 1920x1920 to conserve storage and RAM.
        5. Converts to optimized WebP.
        6. Generates a 240px WebP thumbnail.
        7. Returns relative URLs and image metadata.
        """
        if not file_bytes:
            raise ValueError('Uploaded file is empty')

        # 1. Compute SHA-256
        sha256_hash = hashlib.sha256(file_bytes).hexdigest()

        # 2. Open with Pillow
        try:
            img = Image.open(io.BytesIO(file_bytes))
            img_format = img.format
            if img_format not in ALLOWED_FORMATS:
                raise ValueError(f'Unsupported image format: {img_format}. Allowed: JPEG, PNG, WEBP')
            
            # Correct orientation from EXIF if present
            img = ImageOps.exif_transpose(img)
        except Exception as e:
            raise ValueError(f'Invalid image data: {e}')

        # 3. Determine directory path by year/month
        now = datetime.now()
        rel_subpath = f"orders/{now.year}/{now.strftime('%m')}"
        target_dir = os.path.join(self.media_dir, 'orders', str(now.year), now.strftime('%m'))
        os.makedirs(target_dir, exist_ok=True)

        full_filename = f"{sha256_hash}.webp"
        thumb_filename = f"{sha256_hash}_thumb.webp"

        full_filepath = os.path.join(target_dir, full_filename)
        thumb_filepath = os.path.join(target_dir, thumb_filename)

        # 4. Convert RGBA / P mode if necessary for WebP
        if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
            save_img = img.convert('RGBA')
        else:
            save_img = img.convert('RGB')

        # 5. Save main optimized WebP if not already cached on disk
        width, height = save_img.size
        if width > MAX_IMAGE_DIMENSION or height > MAX_IMAGE_DIMENSION:
            save_img.thumbnail((MAX_IMAGE_DIMENSION, MAX_IMAGE_DIMENSION), Image.Resampling.LANCZOS)
            width, height = save_img.size

        if not os.path.exists(full_filepath):
            save_img.save(full_filepath, 'WEBP', quality=WEBP_QUALITY, method=4)

        # 6. Generate and save thumbnail
        if not os.path.exists(thumb_filepath):
            thumb_img = save_img.copy()
            thumb_img.thumbnail((THUMBNAIL_DIMENSION, THUMBNAIL_DIMENSION), Image.Resampling.LANCZOS)
            thumb_img.save(thumb_filepath, 'WEBP', quality=THUMBNAIL_QUALITY, method=4)

        file_size = os.path.getsize(full_filepath)

        return {
            'file_url': f"/media/{rel_subpath}/{full_filename}",
            'thumbnail_url': f"/media/{rel_subpath}/{thumb_filename}",
            'sha256': sha256_hash,
            'original_filename': filename,
            'width': width,
            'height': height,
            'size_bytes': file_size,
            'format': 'webp',
        }
