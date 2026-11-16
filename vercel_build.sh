#!/bin/bash
set -e

echo "=================================================="
echo "  Button Factory MES - Vercel Build Script"
echo "=================================================="

# 1. Install or reuse cached portable Flutter SDK
if [ ! -d "flutter" ]; then
  echo "[INFO] Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
else
  echo "[INFO] Reusing existing Flutter SDK cache."
fi

export PATH="$(pwd)/flutter/bin:$PATH"

echo "[INFO] Checking Flutter version..."
flutter --version

# 2. Build Flutter Web Release
echo "[INFO] Building Flutter Web for production..."
cd btn_factory
flutter pub get
flutter build web --release

# 3. Ensure runtime frontend environment file is bundled in output
if [ -f ".env" ]; then
  echo "[INFO] Bundling frontend .env into web build output..."
  cp .env build/web/.env
  mkdir -p build/web/assets
  cp .env build/web/assets/.env
fi

echo "=================================================="
echo "  Vercel Build Succeeded -> btn_factory/build/web"
echo "=================================================="
