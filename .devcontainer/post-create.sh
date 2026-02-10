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

# Mobile
if [ -d "/workspace/mobile" ]; then
  echo "📦 Getting Flutter dependencies..."
  cd /workspace/mobile
  echo "ℹ️  Flutter setup skipped (install manually if needed)"
fi

# Firmware
if [ -d "/workspace/firmware" ]; then
  echo "📦 Setting up firmware..."
  cd /workspace/firmware
  pip3 install -U platformio || echo "⚠️  PlatformIO install failed"
fi

echo "✅ Setup complete! Ready to code 🎉"