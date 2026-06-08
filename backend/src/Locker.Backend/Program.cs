using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.RateLimiting;
using FluentValidation;
using FluentValidation.AspNetCore;
using Locker.Backend;
using Locker.Backend.Application;
using Locker.Backend.Application.Interfaces;
using Locker.Backend.Infrastructure;
using Locker.Backend.Infrastructure.Security;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
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
        Description = "JWT Authorization header using the Bearer scheme."
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

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddFluentValidationClientsideAdapters();
builder.Services.AddValidatorsFromAssemblyContaining<Locker.Backend.Application.Validators.AuthRequestValidator>();

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
        RoleClaimType = ClaimTypes.Role,
        NameClaimType = ClaimTypes.Name
    };
    options.Events = new JwtBearerEvents
    {
        OnTokenValidated = async context =>
        {
            var jwt = context.SecurityToken as JwtSecurityToken;
            var jti = jwt?.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti)?.Value;
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
        options.InjectStylesheet("/swagger-ui/cyberpunk.css");
        options.DocumentTitle = "Locker API - Cyberpunk";
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

await app.Services.UseDatabaseSeeder();

app.Run();
