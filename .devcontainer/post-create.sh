#!/bin/bash
set -e

echo "🚀 Setting up Locker System..."

# Backend
if [ -d "/workspace/backend" ]; then
  echo "📦 Restoring .NET packages..."
  cd /workspace/backend
  dotnet restore || echo "⚠️  Backend restore failed"
fi

# Web
if [ -d "/workspace/web" ]; then
  echo "📦 Installing Web dependencies..."
  cd /workspace/web
  npm install || echo "⚠️  Web install failed"
fi

# Flutter SDK
if [ ! -d "$HOME/flutter" ]; then
  echo "📦 Installing Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
else
  echo "✅ Flutter SDK already exists"
fi

# Thêm Flutter vào PATH vĩnh viễn
FLUTTER_PATH_LINE='export PATH="$PATH:$HOME/flutter/bin"'
if ! grep -q 'flutter/bin' ~/.bashrc; then
  echo "$FLUTTER_PATH_LINE" >> ~/.bashrc
fi
if ! grep -q 'flutter/bin' ~/.profile 2>/dev/null; then
  echo "$FLUTTER_PATH_LINE" >> ~/.profile
fi
export PATH="$PATH:$HOME/flutter/bin"

# Pre-download Dart SDK
echo "📦 Pre-caching Flutter..."
$HOME/flutter/bin/flutter precache --web 2>/dev/null || true

# Mobile
if [ -d "/workspace/mobile" ]; then
  echo "📦 Getting Flutter dependencies..."
  cd /workspace/mobile
  $HOME/flutter/bin/flutter pub get || echo "⚠️  Flutter pub get failed"
fi

# Firmware
if [ -d "/workspace/firmware" ]; then
  echo "📦 Setting up firmware..."
  cd /workspace/firmware
  pip3 install -U platformio || echo "⚠️  PlatformIO install failed"
fi

echo "✅ Setup complete! Ready to code 🎉"