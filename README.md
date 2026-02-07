# Locker System

Monorepo for Locker (Firmware + Backend + Web + Mobile + Infra).

## Modules
- firmware/: ESP32-S3 (ESP-IDF)
- backend/: ASP.NET Core API
- web/: React + TypeScript
- mobile/: Flutter
- infra/: Docker, MQTT, DB
- docs/: architecture and docs

## Suggested Folder Layout
```
backend/
	src/            # API source code
	tests/          # automated tests
	docs/           # backend docs
	scripts/        # dev and maintenance scripts
firmware/
	main/           # ESP-IDF app entry
	components/     # shared drivers and modules
	boards/         # board-specific configs
	scripts/        # flash and build helpers
web/
	src/            # React app
	public/         # static assets
	tests/          # UI tests
mobile/
	lib/            # Flutter app
	test/           # Flutter tests
	android/        # Android platform
	ios/            # iOS platform
infra/
	mosquitto/      # MQTT config
	postgres/       # DB config
	nginx/          # reverse proxy
docs/
	architecture/   # system diagrams
	api/            # API docs
	operations/     # runbooks
```

## Quick Start (Local-first)
1. Start infra (MQTT + DB)
2. Start backend
3. Start web/mobile
4. Flash firmware
