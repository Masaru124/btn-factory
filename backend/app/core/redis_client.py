import logging
import time
from typing import Any

from app.core.config import get_settings

logger = logging.getLogger('mes.redis')
settings = get_settings()


class InMemoryFallbackCache:
    """A thread-safe in-memory cache with TTL expiration fallback when Redis is not available."""

    def __init__(self) -> None:
        self._store: dict[str, tuple[Any, float]] = {}

    def get(self, key: str) -> Any | None:
        if key in self._store:
            val, expiry = self._store[key]
            if expiry == 0 or time.time() < expiry:
                return val
            del self._store[key]
        return None

    def set(self, key: str, value: Any, ex: int | None = None) -> bool:
        expiry = time.time() + ex if ex else 0
        self._store[key] = (value, expiry)
        return True

    def delete(self, key: str) -> bool:
        if key in self._store:
            del self._store[key]
            return True
        return False

    def delete_pattern(self, pattern: str) -> int:
        prefix = pattern.rstrip('*')
        keys_to_del = [k for k in self._store if k.startswith(prefix)]
        for k in keys_to_del:
            del self._store[k]
        return len(keys_to_del)

    def check_idempotency(self, key: str, ttl: int = 30) -> bool:
        """Returns True if this is the first submission, False if duplicate within TTL."""
        cache_key = f'idempotency:{key}'
        if self.get(cache_key) is not None:
            return False
        self.set(cache_key, '1', ex=ttl)
        return True

    def rate_limit(self, key: str, max_requests: int = 60, window_seconds: int = 60) -> bool:
        """Simple fixed window rate limiter. Returns True if allowed, False if exceeded."""
        cache_key = f'ratelimit:{key}'
        count = self.get(cache_key)
        if count is None:
            self.set(cache_key, 1, ex=window_seconds)
            return True
        if int(count) >= max_requests:
            return False
        self.set(cache_key, int(count) + 1, ex=window_seconds)
        return True


class RedisClient:
    def __init__(self) -> None:
        self._redis = None
        self._fallback = InMemoryFallbackCache()
        self._connected = False
        self._initialize()

    def _initialize(self) -> None:
        if not settings.enable_redis and not settings.redis_url:
            logger.info('Redis disabled or not configured; using high-speed in-memory cache.')
            return

        try:
            import redis

            client = redis.Redis.from_url(
                settings.redis_url,
                socket_timeout=1.0,
                socket_connect_timeout=1.0,
                decode_responses=True,
            )
            # Test ping
            client.ping()
            self._redis = client
            self._connected = True
            logger.info('Connected successfully to Redis server at %s', settings.redis_url)
        except Exception as e:
            logger.warning('Redis server unreachable at %s (%s). Operating smoothly on in-memory fallback.', settings.redis_url, e)
            self._redis = None
            self._connected = False

    @property
    def is_connected(self) -> bool:
        return self._connected

    def get(self, key: str) -> Any | None:
        if self._redis:
            try:
                return self._redis.get(key)
            except Exception:
                pass
        return self._fallback.get(key)

    def set(self, key: str, value: Any, ex: int | None = None) -> bool:
        if self._redis:
            try:
                return bool(self._redis.set(key, value, ex=ex))
            except Exception:
                pass
        return self._fallback.set(key, value, ex=ex)

    def delete(self, key: str) -> bool:
        if self._redis:
            try:
                return bool(self._redis.delete(key))
            except Exception:
                pass
        return self._fallback.delete(key)

    def delete_pattern(self, pattern: str) -> int:
        if self._redis:
            try:
                keys = self._redis.keys(pattern)
                if keys:
                    return self._redis.delete(*keys)
                return 0
            except Exception:
                pass
        return self._fallback.delete_pattern(pattern)

    def check_idempotency(self, key: str, ttl: int = 30) -> bool:
        """
        Idempotency key check: Prevents duplicate double-tap writes from tablets.
        Returns True if allowed (first time seen), False if duplicate.
        """
        cache_key = f'idempotency:{key}'
        if self._redis:
            try:
                # set nx=True returns True only if key did NOT exist
                is_new = self._redis.set(cache_key, '1', ex=ttl, nx=True)
                return bool(is_new)
            except Exception:
                pass
        return self._fallback.check_idempotency(key, ttl=ttl)

    def rate_limit(self, key: str, max_requests: int = 60, window_seconds: int = 60) -> bool:
        """
        Fixed window rate limiting.
        """
        cache_key = f'ratelimit:{key}'
        if self._redis:
            try:
                pipeline = self._redis.pipeline()
                pipeline.incr(cache_key)
                pipeline.expire(cache_key, window_seconds)
                results = pipeline.execute()
                current_count = results[0]
                return current_count <= max_requests
            except Exception:
                pass
        return self._fallback.rate_limit(key, max_requests=max_requests, window_seconds=window_seconds)


# Global singleton instance
cache_client = RedisClient()
