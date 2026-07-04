using System.IdentityModel.Tokens.Jwt;
// Assuming the project file targets net8.0
using System;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.RateLimiting;
using FluentValidation;
using FluentValidation.AspNetCore;
using Locker.Backend.Application;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Infrastructure;
using Locker.Backend.Infrastructure.Security;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

var envFile = Path.Combine(builder.Environment.ContentRootPath, ".env");
if (File.Exists(envFile))
{
    foreach (var line in File.ReadAllLines(envFile))
    {
        var match = Regex.Match(line, @"^([^=]+)=(.*)$");
        if (match.Success)
        {
            var envKey = match.Groups[1].Value.Trim();
            var value = match.Groups[2].Value.Trim();
            if (!string.IsNullOrEmpty(envKey) && !envKey.StartsWith("#"))
            {
                Environment.SetEnvironmentVariable(envKey, value);
            }
        }
    }
}
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Locker API", Version = "v1" });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Authorization header using the Bearer scheme. \r\n\r\n Enter 'your_token_here' without the 'Bearer ' prefix."
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddFluentValidationClientsideAdapters();
builder.Services.AddValidatorsFromAssemblyContaining<Locker.Backend.Application.Validators.AuthRequestValidator>();

// Rate limiting
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("auth", opt =>
    {
        opt.PermitLimit = 10;
        opt.Window = TimeSpan.FromMinutes(1);
        opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        opt.QueueLimit = 0;
    });
    options.AddFixedWindowLimiter("api", opt =>
    {
        opt.PermitLimit = 100;
        opt.Window = TimeSpan.FromMinutes(1);
        opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        opt.QueueLimit = 5;
    });
    options.RejectionStatusCode = 429;
});

var allowedOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .Get<string[]>() ?? Array.Empty<string>();

if (allowedOrigins.Length == 0 && !builder.Environment.IsDevelopment())
{
    throw new InvalidOperationException(
        "CORS AllowedOrigins must be configured in production. " +
        "Set 'Cors:AllowedOrigins' in appsettings.Production.json or via environment variables.");
}

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            if (builder.Environment.IsDevelopment())
            {
                policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
            }
            else
            {
                policy.WithOrigins(allowedOrigins)
                      .AllowAnyMethod()
                      .AllowAnyHeader()
                      .AllowCredentials();
            }
        });
});

var jwtSettings = builder.Configuration.GetSection("Jwt").Get<JwtSettings>() ?? new JwtSettings();
var key = Encoding.UTF8.GetBytes(jwtSettings.Secret);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.MapInboundClaims = false;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero,
        ValidIssuer = jwtSettings.Issuer,
        ValidAudience = jwtSettings.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        RoleClaimType = "role",
        NameClaimType = "name"
    };
    options.Events = new JwtBearerEvents
    {
        OnTokenValidated = async context =>
        {
            var jti = context.Principal?.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
            if (string.IsNullOrWhiteSpace(jti))
            {
                context.Fail("Invalid token.");
                return;
            }

            var repository = context.HttpContext.RequestServices.GetRequiredService<IRefreshTokenRepository>();
            if (await repository.IsAccessTokenRevokedAsync(jti, context.HttpContext.RequestAborted))
            {
                context.Fail("Token has been revoked.");
            }
        },
        OnForbidden = context =>
        {
            context.Response.StatusCode = 403;
            context.Response.ContentType = "application/json";

            var endpoint = context.HttpContext.GetEndpoint();
            var authorizeAttributes = endpoint?.Metadata.GetOrderedMetadata<Microsoft.AspNetCore.Authorization.AuthorizeAttribute>();
            var requiredRoles = string.Join(", ", authorizeAttributes?.Where(a => !string.IsNullOrWhiteSpace(a.Roles)).Select(a => a.Roles) ?? Array.Empty<string>());

            var message = string.IsNullOrEmpty(requiredRoles)
                ? "Bạn không có quyền truy cập vào chức năng này."
                : $"Bạn không có quyền truy cập. Yêu cầu một trong các quyền sau: {requiredRoles}.";

            return Microsoft.AspNetCore.Http.HttpResponseJsonExtensions.WriteAsJsonAsync(context.Response, new { error = "Forbidden", message = message });
        }
    };
});

builder.Services.AddAuthorization();

var app = builder.Build();

app.UseStaticFiles();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Locker API v1");
        options.RoutePrefix = string.Empty;
        options.DocumentTitle = "Locker API";
    });
}

app.UseMiddleware<Locker.Backend.Middlewares.ExceptionHandlingMiddleware>();
app.UseCors("AllowAll");

app.Use(async (ctx, next) =>
{
    ctx.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    ctx.Response.Headers.Append("X-Frame-Options", "DENY");
    ctx.Response.Headers.Append("X-XSS-Protection", "1; mode=block");
    ctx.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");
    ctx.Response.Headers.Append("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
    await next();
});

app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers().RequireRateLimiting("api");

var seedEnabled = builder.Configuration.GetValue<bool>("Seed:Enabled", false);
if (seedEnabled)
{
    using var scope = app.Services.CreateScope();
    var serviceProvider = scope.ServiceProvider;
    await serviceProvider.UseDatabaseSeeder();
}

app.Run();

public partial class Program { } // Make Program class public for testing
