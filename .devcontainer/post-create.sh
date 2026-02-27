#!/bin/bash
set -e

# Install system dependencies for Flutter desktop
echo "🔧 Installing system dependencies for Flutter desktop..."
sudo apt update
sudo apt install -y cmake ninja-build build-essential clang pkg-config libgtk-3-dev

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

# Mobile
if [ -d "/workspace/mobile" ]; then
  echo "📦 Setting up Flutter..."
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
  fi
  export PATH="$PATH:$HOME/flutter/bin"
  echo 'export PATH="$PATH:$HOME/flutter/bin"' >> $HOME/.bashrc
  cd /workspace/mobile
  flutter pub get || echo "⚠️  Flutter pub get failed"
fi

# Firmware
if [ -d "/workspace/firmware" ]; then
  echo "📦 Setting up firmware..."
  cd /workspace/firmware
  pip3 install -U platformio || echo "⚠️  PlatformIO install failed"
fi

echo "✅ Setup complete! Ready to code 🎉"