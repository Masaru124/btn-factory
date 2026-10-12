import io
from fastapi.testclient import TestClient
from PIL import Image

from app.core.redis_client import cache_client
from app.main import app

client = TestClient(app)


def test_redis_cache_client_fallback():
    # Test setting and getting keys via fallback cache
    assert cache_client.set('test_key', 'test_value', ex=10) is True
    assert cache_client.get('test_key') == 'test_value'

    # Test idempotency check
    assert cache_client.check_idempotency('batch_req_1', ttl=5) is True
    assert cache_client.check_idempotency('batch_req_1', ttl=5) is False  # Duplicate should be blocked

    # Test rate limiting
    assert cache_client.rate_limit('ip_127.0.0.1', max_requests=2, window_seconds=5) is True
    assert cache_client.rate_limit('ip_127.0.0.1', max_requests=2, window_seconds=5) is True
    assert cache_client.rate_limit('ip_127.0.0.1', max_requests=2, window_seconds=5) is False  # 3rd request blocked


def test_media_upload_and_static_serving():
    # Create test image in memory
    img = Image.new('RGB', (120, 120), color='crimson')
    buf = io.BytesIO()
    img.save(buf, format='JPEG')
    buf.seek(0)

    response = client.post(
        '/api/media/upload',
        files={'file': ('crimson_button.jpg', buf, 'image/jpeg')},
    )
    assert response.status_code == 200
    data = response.json()

    assert 'file_url' in data
    assert 'thumbnail_url' in data
    assert data['file_url'].endswith('.webp')
    assert data['thumbnail_url'].endswith('_thumb.webp')
    assert data['width'] == 120
    assert data['height'] == 120

    # Test static file retrieval
    media_response = client.get(data['file_url'])
    assert media_response.status_code == 200
    assert len(media_response.content) > 0
