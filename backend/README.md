# Locker Backend

ASP.NET Core (net8.0) with Clean Architecture and MongoDB.

## Projects
- Locker.Backend (API)
- Locker.Backend.Application
- Locker.Backend.Domain
- Locker.Backend.Infrastructure

## Run
- `dotnet run --project src/Locker.Backend`

## Test
- `dotnet test`

## Endpoints
- `GET /api/health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/lockers`

## Config
- Update JWT secret in `src/Locker.Backend/appsettings.json`
- Update Mongo connection in `src/Locker.Backend/appsettings.json`
