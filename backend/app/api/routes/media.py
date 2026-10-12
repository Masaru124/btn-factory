from fastapi import APIRouter, File, HTTPException, UploadFile, status

from app.services.media_service import MediaService

router = APIRouter()
media_service = MediaService()

MAX_FILE_SIZE_BYTES = 25 * 1024 * 1024  # 25MB max upload size


@router.post('/upload')
async def upload_media(file: UploadFile = File(...)) -> dict:
    """
    Accepts an image file upload, optimizes it to WebP format,
    generates a thumbnail, saves to local factory media storage,
    and returns lightweight relative URLs.
    """
    if not file.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail='No filename provided',
        )

    # Read file content in chunks to check size
    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f'File size exceeds limit of {MAX_FILE_SIZE_BYTES // (1024 * 1024)}MB',
        )

    try:
        result = media_service.process_and_save_image(contents, filename=file.filename)
        return result
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f'Failed to process image: {e}',
        )
