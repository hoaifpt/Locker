# Stage 1: Build
# Sử dụng .NET 10 SDK image để build ứng dụng
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Docker build context là thư mục gốc của monorepo.
# Đầu tiên, copy file solution (.sln) và các file project (.csproj) để tận dụng caching của Docker.
# Copy file .sln từ thư mục gốc.
COPY ["locker.sln", "."]

# Copy toàn bộ thư mục backend vào trong container.
# Điều này đảm bảo tất cả các project, dependencies và source code trong 'backend' đều có sẵn.
COPY backend/ ./backend/

# Restore NuGet packages cho toàn bộ solution.
# Chỉ định rõ project backend chính để restore nếu cần, nhưng restore solution sẽ xử lý tất cả.
RUN dotnet restore "locker.sln"

# Copy toàn bộ source code còn lại (mặc dù đã copy backend, bước này để chắc chắn)
# và build dự án.
COPY . .
WORKDIR "/src/backend/src/Locker.Backend"
RUN dotnet build "Locker.Backend.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "Locker.Backend.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Final
# Sử dụng ASP.NET Core runtime image, nhẹ hơn SDK image.
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Sao chép kết quả đã publish từ stage trước.
COPY --from=publish /app/publish .

# Railway sẽ tự động cung cấp biến PORT. ASPNETCORE_URLS sẽ lắng nghe trên cổng đó.
# Chúng ta expose cổng 8080 để Railway có thể map vào.
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Chạy ứng dụng.
# TODO: Thay thế "Locker.Backend.dll" bằng tên file .dll chính xác của dự án backend của bạn.
ENTRYPOINT ["dotnet", "Locker.Backend.dll"]