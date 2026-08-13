# User Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thêm tính năng feedback full-stack trực tiếp trong E-box để mỗi tài khoản gửi hoặc cập nhật một review công khai, đồng thời giúp admin chứng minh đã thu thập phản hồi từ tối thiểu 10 người dùng duy nhất.

**Architecture:** Backend bổ sung bounded module `Feedback` theo Domain/Application/Infrastructure/API và dùng MongoDB atomic upsert với unique index `UserId`. Frontend có API client riêng, widget đặt trong authenticated route outlet, section review công khai trên trang chủ và dashboard admin riêng. Việc xác minh chỉ dùng build và kiểm thử thủ công với frontend, API, MongoDB và tài khoản thật.

**Tech Stack:** .NET 10, ASP.NET Core, MediatR, FluentValidation, MongoDB.Driver, React 18, TypeScript, React Router 7, Tailwind CSS, Framer Motion, Lucide React.

## Global Constraints

- Chỉ tài khoản đã đăng nhập được tạo hoặc cập nhật feedback.
- Mỗi `UserId` có đúng một feedback; lần gửi sau cập nhật bản ghi hiện có.
- Rating là số nguyên từ 1 đến 5; topic thuộc `General`, `BookingOrder`, `Payment`, `Delivery`, `Interface`, `Other`.
- Content bắt buộc sau khi trim và dài tối đa 2.000 ký tự.
- Page URL chỉ là pathname nội bộ bắt đầu bằng `/`, không có query hoặc fragment và dài tối đa 500 ký tự.
- Review được công khai ngay bằng username, không qua duyệt trước và không lộ `UserId` hoặc email.
- Admin được xem dashboard, lọc, phân trang, xuất CSV và ẩn/hiện review; không xóa vĩnh viễn.
- Feedback bị ẩn vẫn tính vào tiến độ `x/10` nhưng không xuất hiện ở dữ liệu public.
- Người dùng cập nhật feedback đang bị ẩn không được tự bật lại `IsVisible`.
- CSV dùng UTF-8 BOM và chống formula injection cho ô bắt đầu bằng `=`, `+`, `-`, `@`.
- Không tạo unit test, integration test, UI automation test hoặc mock test; chỉ build và kiểm thử thủ công trên hệ thống thật.

---

## File Structure

### Backend files to create

- `backend/src/Locker.Backend.Domain/Enums/FeedbackTopic.cs`: danh sách topic hợp lệ.
- `backend/src/Locker.Backend.Domain/Entities/Feedback.cs`: document MongoDB của feedback.
- `backend/src/Locker.Backend.Application/Models/FeedbackModels.cs`: request, response, filters, summary và distribution DTO.
- `backend/src/Locker.Backend.Application/Interfaces/IFeedbackRepository.cs`: hợp đồng atomic upsert, public query, admin query, visibility và export.
- `backend/src/Locker.Backend.Application/Validators/FeedbackValidators.cs`: validation cho request upsert.
- `backend/src/Locker.Backend.Application/Features/Feedback/Commands/UpsertMyFeedback/UpsertMyFeedbackCommand.cs`: lưu feedback của user hiện tại.
- `backend/src/Locker.Backend.Application/Features/Feedback/Commands/SetFeedbackVisibility/SetFeedbackVisibilityCommand.cs`: admin ẩn/hiện review.
- `backend/src/Locker.Backend.Application/Features/Feedback/Queries/GetMyFeedback/GetMyFeedbackQuery.cs`: lấy feedback của user hiện tại.
- `backend/src/Locker.Backend.Application/Features/Feedback/Queries/GetPublicFeedback/GetPublicFeedbackQuery.cs`: summary và tối đa 6 review public.
- `backend/src/Locker.Backend.Application/Features/Feedback/Queries/GetAdminFeedback/GetAdminFeedbackQuery.cs`: danh sách phân trang và dashboard summary.
- `backend/src/Locker.Backend.Application/Features/Feedback/Queries/ExportFeedback/ExportFeedbackQuery.cs`: tạo CSV an toàn.
- `backend/src/Locker.Backend.Infrastructure/Repositories/FeedbackRepository.cs`: MongoDB implementation.
- `backend/src/Locker.Backend/Controllers/FeedbacksController.cs`: endpoint user và public.
- `backend/src/Locker.Backend/Controllers/AdminFeedbacksController.cs`: endpoint admin.

### Backend files to modify

- `backend/src/Locker.Backend.Infrastructure/Mongo/MongoSettings.cs`: khai báo collection `feedbacks`.
- `backend/src/Locker.Backend.Infrastructure/Mongo/MongoContext.cs`: tạo unique index `UserId` và index phục vụ public/admin query.
- `backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs`: đăng ký `IFeedbackRepository`.

### Frontend files to create

- `web/src/features/feedback/types.ts`: type và label dùng chung.
- `web/src/features/feedback/api/feedbackApi.ts`: API functions và download CSV.
- `web/src/features/feedback/components/StarRating.tsx`: input sao có accessibility.
- `web/src/features/feedback/components/FeedbackModal.tsx`: load, validate, submit và giữ form khi lỗi.
- `web/src/features/feedback/components/FeedbackButton.tsx`: pill cố định và modal host.
- `web/src/features/feedback/components/PublicReviewsSection.tsx`: review public trên trang chủ.
- `web/src/features/feedback/pages/AdminFeedbackPage.tsx`: dashboard quản trị.

### Frontend files to modify

- `web/src/lib/api.ts`: tự gắn Bearer token và dùng lại cho download.
- `web/src/components/layout/ProtectedRoute.tsx`: render feedback widget một lần cho authenticated route.
- `web/src/components/layout/AppHeader.tsx`: thêm link admin tới feedback dashboard.
- `web/src/features/home/pages/HomePage.tsx`: thêm section review public.
- `web/src/routes/index.tsx`: đăng ký `/admin/feedbacks`.

### Verification artifact to create

- `docs/testing/user-feedback-manual-test.md`: ghi môi trường, tài khoản test, thao tác và kết quả quan sát thực tế; không chứa dữ liệu nhạy cảm hoặc token.

---

### Task 1: Define Feedback Domain and Application Contracts

**Files:**
- Create: `backend/src/Locker.Backend.Domain/Enums/FeedbackTopic.cs`
- Create: `backend/src/Locker.Backend.Domain/Entities/Feedback.cs`
- Create: `backend/src/Locker.Backend.Application/Models/FeedbackModels.cs`
- Create: `backend/src/Locker.Backend.Application/Interfaces/IFeedbackRepository.cs`
- Create: `backend/src/Locker.Backend.Application/Validators/FeedbackValidators.cs`

**Interfaces:**
- Produces: `FeedbackTopic`, `Feedback`, `UpsertFeedbackRequest`, `FeedbackDto`, `PublicFeedbackDto`, `PublicFeedbackResponse`, `FeedbackFilter`, `FeedbackSummaryDto`, `AdminFeedbackResponse`, `ExportFeedbackResult`, `IFeedbackRepository`.
- Consumes: existing `BaseEntity`, `PaginatedResult<T>` and FluentValidation registration by assembly scan.

- [ ] **Step 1: Add the enum and entity**

```csharp
namespace Locker.Backend.Domain.Enums;

public enum FeedbackTopic
{
    General,
    BookingOrder,
    Payment,
    Delivery,
    Interface,
    Other
}
```

```csharp
using Locker.Backend.Domain.Enums;

namespace Locker.Backend.Domain.Entities;

public class Feedback : BaseEntity
{
    public Guid UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public int Rating { get; set; }
    public FeedbackTopic Topic { get; set; }
    public string Content { get; set; } = string.Empty;
    public string PageUrl { get; set; } = string.Empty;
    public bool IsVisible { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
```

- [ ] **Step 2: Add exact API and repository models**

Create records/classes with these signatures in `FeedbackModels.cs`:

```csharp
public sealed record UpsertFeedbackRequest(
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl);

public sealed record FeedbackDto(
    Guid Id,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl,
    bool IsVisible,
    DateTime CreatedAt,
    DateTime UpdatedAt);

public sealed record PublicFeedbackDto(
    string Username,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    DateTime UpdatedAt);

public sealed record RatingDistributionDto(int Rating, int Count);
public sealed record TopicDistributionDto(FeedbackTopic Topic, int Count);

public sealed record FeedbackSummaryDto(
    int TotalReviewers,
    double AverageRating,
    int VisibleReviewers,
    IReadOnlyList<RatingDistributionDto> RatingDistribution,
    IReadOnlyList<TopicDistributionDto> TopicDistribution);

public sealed record PublicFeedbackResponse(
    double AverageRating,
    int TotalVisibleReviewers,
    IReadOnlyList<PublicFeedbackDto> Reviews);

public sealed record FeedbackFilter(
    int? Rating,
    FeedbackTopic? Topic,
    bool? IsVisible,
    string? Search);

public sealed record AdminFeedbackItemDto(
    Guid Id,
    string Username,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl,
    bool IsVisible,
    DateTime CreatedAt,
    DateTime UpdatedAt);

public sealed record AdminFeedbackResponse(
    PaginatedResult<AdminFeedbackItemDto> Page,
    FeedbackSummaryDto Summary);

public sealed record ExportFeedbackResult(byte[] Content, string FileName);
```

- [ ] **Step 3: Define the repository boundary**

```csharp
public interface IFeedbackRepository
{
    Task<Feedback?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<Feedback> UpsertByUserIdAsync(
        Guid userId,
        string username,
        int rating,
        FeedbackTopic topic,
        string content,
        string pageUrl,
        CancellationToken cancellationToken);
    Task<IReadOnlyList<Feedback>> GetPublicAsync(int limit, CancellationToken cancellationToken);
    Task<FeedbackSummaryDto> GetSummaryAsync(FeedbackFilter filter, CancellationToken cancellationToken);
    Task<PaginatedResult<Feedback>> GetAdminPageAsync(
        FeedbackFilter filter,
        int page,
        int pageSize,
        CancellationToken cancellationToken);
    Task<IReadOnlyList<Feedback>> GetForExportAsync(FeedbackFilter filter, CancellationToken cancellationToken);
    Task<bool> SetVisibilityAsync(Guid id, bool isVisible, CancellationToken cancellationToken);
}
```

- [ ] **Step 4: Add request/filter validators**

`UpsertFeedbackRequestValidator` must apply:

```csharp
RuleFor(x => x.Rating).InclusiveBetween(1, 5);
RuleFor(x => x.Topic).IsInEnum();
RuleFor(x => x.Content).NotEmpty().MaximumLength(2000);
RuleFor(x => x.PageUrl)
    .NotEmpty()
    .MaximumLength(500)
    .Must(path => Uri.TryCreate(path, UriKind.Relative, out _) &&
                  path.StartsWith('/') &&
                  !path.Contains('?') &&
                  !path.Contains('#'))
    .WithMessage("PageUrl must be an internal pathname without query or fragment.");
```

- [ ] **Step 5: Build the backend contracts**

Run: `dotnet build backend/Locker.Backend.sln`

Expected: build succeeds with 0 errors; no test project is run.

- [ ] **Step 6: Commit the domain contracts**

```powershell
git add backend/src/Locker.Backend.Domain/Enums/FeedbackTopic.cs backend/src/Locker.Backend.Domain/Entities/Feedback.cs backend/src/Locker.Backend.Application/Models/FeedbackModels.cs backend/src/Locker.Backend.Application/Interfaces/IFeedbackRepository.cs backend/src/Locker.Backend.Application/Validators/FeedbackValidators.cs
git commit -m "feat: define feedback domain contracts"
```

---

### Task 2: Implement MongoDB Persistence and Indexes

**Files:**
- Create: `backend/src/Locker.Backend.Infrastructure/Repositories/FeedbackRepository.cs`
- Modify: `backend/src/Locker.Backend.Infrastructure/Mongo/MongoSettings.cs`
- Modify: `backend/src/Locker.Backend.Infrastructure/Mongo/MongoContext.cs`
- Modify: `backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs`

**Interfaces:**
- Consumes: `IFeedbackRepository`, `Feedback`, `FeedbackFilter`, `FeedbackSummaryDto`, `PaginatedResult<Feedback>` from Task 1.
- Produces: atomic `FeedbackRepository` registered as scoped dependency.

- [ ] **Step 1: Register the collection name and indexes**

Add to `MongoSettings`:

```csharp
public string FeedbacksCollection { get; set; } = "feedbacks";
```

Add to `MongoContext.EnsureIndexes()`:

```csharp
var feedbacks = Database.GetCollection<Feedback>(Settings.FeedbacksCollection);
feedbacks.Indexes.CreateMany(new[]
{
    new CreateIndexModel<Feedback>(
        Builders<Feedback>.IndexKeys.Ascending(x => x.UserId),
        new CreateIndexOptions { Unique = true }),
    new CreateIndexModel<Feedback>(
        Builders<Feedback>.IndexKeys.Ascending(x => x.IsVisible).Descending(x => x.UpdatedAt)),
    new CreateIndexModel<Feedback>(
        Builders<Feedback>.IndexKeys.Ascending(x => x.Rating).Ascending(x => x.Topic))
});
```

- [ ] **Step 2: Implement atomic upsert without changing visibility on update**

Use `FindOneAndUpdateAsync` with `IsUpsert = true` and `ReturnDocument = After`:

```csharp
var now = DateTime.UtcNow;
var update = Builders<Feedback>.Update
    .Set(x => x.Username, username)
    .Set(x => x.Rating, rating)
    .Set(x => x.Topic, topic)
    .Set(x => x.Content, content.Trim())
    .Set(x => x.PageUrl, pageUrl)
    .Set(x => x.UpdatedAt, now)
    .SetOnInsert(x => x.Id, Guid.CreateVersion7())
    .SetOnInsert(x => x.UserId, userId)
    .SetOnInsert(x => x.IsVisible, true)
    .SetOnInsert(x => x.CreatedAt, now);

return await _collection.FindOneAndUpdateAsync(
    x => x.UserId == userId,
    update,
    new FindOneAndUpdateOptions<Feedback> { IsUpsert = true, ReturnDocument = ReturnDocument.After },
    cancellationToken);
```

- [ ] **Step 3: Implement one shared Mongo filter builder**

`BuildFilter(FeedbackFilter filter)` starts with `Filter.Empty`, then combines:

```csharp
if (filter.Rating.HasValue)
    parts.Add(Builders<Feedback>.Filter.Eq(x => x.Rating, filter.Rating.Value));
if (filter.Topic.HasValue)
    parts.Add(Builders<Feedback>.Filter.Eq(x => x.Topic, filter.Topic.Value));
if (filter.IsVisible.HasValue)
    parts.Add(Builders<Feedback>.Filter.Eq(x => x.IsVisible, filter.IsVisible.Value));
if (!string.IsNullOrWhiteSpace(filter.Search))
{
    var safe = Regex.Escape(filter.Search.Trim());
    var regex = new BsonRegularExpression(safe, "i");
    parts.Add(Builders<Feedback>.Filter.Or(
        Builders<Feedback>.Filter.Regex(x => x.Username, regex),
        Builders<Feedback>.Filter.Regex(x => x.Content, regex)));
}
return parts.Count == 0
    ? Builders<Feedback>.Filter.Empty
    : Builders<Feedback>.Filter.And(parts);
```

Use this builder for admin page, filtered summary and export. Sort admin/export by `UpdatedAt` descending. Apply `.Skip((page - 1) * pageSize).Limit(pageSize)` only to the admin page.

- [ ] **Step 4: Implement summaries with explicit empty-data behavior**

Count `TotalReviewers` against `Filter.Empty` so progress is global and never changes with rating, topic, visibility or search filters. Compute `AverageRating`, `VisibleReviewers`, rating distribution and topic distribution against the complete `FeedbackFilter` supplied to `GetSummaryAsync`; these four values therefore describe the same filtered result set as the admin table. Return `AverageRating = 0` when that set is empty and round non-empty averages to two decimals. Return all five rating buckets and all six topic buckets, filling missing buckets with `0`.

For `GetPublicAsync`, enforce `IsVisible = true`, sort by `UpdatedAt` descending and limit to the validated value. For the public summary, call `GetSummaryAsync(new FeedbackFilter(null, null, true, null), cancellationToken)`.

- [ ] **Step 5: Implement visibility and register dependency injection**

Visibility update must target only the requested ID:

```csharp
var result = await _collection.UpdateOneAsync(
    x => x.Id == id,
    Builders<Feedback>.Update.Set(x => x.IsVisible, isVisible),
    cancellationToken: cancellationToken);
return result.MatchedCount == 1;
```

Register:

```csharp
services.AddScoped<IFeedbackRepository, FeedbackRepository>();
```

- [ ] **Step 6: Build and inspect index creation manually**

Run: `dotnet build backend/Locker.Backend.sln`

Then start MongoDB/backend and inspect collection indexes with Mongo shell or Compass. Expected indexes include a unique `userId_1` plus public sort and rating/topic indexes. Do not insert mock documents.

- [ ] **Step 7: Commit persistence**

```powershell
git add backend/src/Locker.Backend.Infrastructure/Mongo/MongoSettings.cs backend/src/Locker.Backend.Infrastructure/Mongo/MongoContext.cs backend/src/Locker.Backend.Infrastructure/Repositories/FeedbackRepository.cs backend/src/Locker.Backend.Infrastructure/DependencyInjection.cs
git commit -m "feat: persist feedback in mongodb"
```

---

### Task 3: Add User and Public Feedback Use Cases

**Files:**
- Create: `backend/src/Locker.Backend.Application/Features/Feedback/Commands/UpsertMyFeedback/UpsertMyFeedbackCommand.cs`
- Create: `backend/src/Locker.Backend.Application/Features/Feedback/Queries/GetMyFeedback/GetMyFeedbackQuery.cs`
- Create: `backend/src/Locker.Backend.Application/Features/Feedback/Queries/GetPublicFeedback/GetPublicFeedbackQuery.cs`
- Create: `backend/src/Locker.Backend/Controllers/FeedbacksController.cs`

**Interfaces:**
- Consumes: `IFeedbackRepository`, `IIdentityService`, Task 1 DTOs.
- Produces: `GET /api/feedbacks/me`, `PUT /api/feedbacks/me`, `GET /api/feedbacks/public?limit=6`.

- [ ] **Step 1: Implement mapping local to the feature**

Each handler maps only fields its response allows. The public mapper must not include `Id`, `UserId`, `PageUrl` or `IsVisible`:

```csharp
private static PublicFeedbackDto ToPublic(Feedback item) => new(
    item.Username,
    item.Rating,
    item.Topic,
    item.Content,
    item.UpdatedAt);
```

- [ ] **Step 2: Implement get-my and upsert commands**

Use these request signatures:

```csharp
public sealed record GetMyFeedbackQuery(Guid UserId) : IRequest<FeedbackDto?>;

public sealed record UpsertMyFeedbackCommand(
    Guid UserId,
    int Rating,
    FeedbackTopic Topic,
    string Content,
    string PageUrl) : IRequest<FeedbackDto?>;
```

The upsert handler must load the user with `IIdentityService.FindByIdAsync(request.UserId.ToString())`; return `null` if missing. Set the display name to `user.UserName`, falling back to `user.FullName`, then `"Người dùng"`. Pass trimmed content and exact pathname to `UpsertByUserIdAsync`.

- [ ] **Step 3: Implement the public query**

```csharp
public sealed record GetPublicFeedbackQuery(int Limit = 6) : IRequest<PublicFeedbackResponse>;
```

Clamp `Limit` to 1–6, get visible reviews and visible summary, and return `AverageRating`, `VisibleReviewers` as `TotalVisibleReviewers`, and mapped public items.

- [ ] **Step 4: Add the controller with claim-derived identity**

```csharp
[ApiController]
[Route("api/feedbacks")]
public sealed class FeedbacksController : ControllerBase
{
    private readonly ISender _sender;
    public FeedbacksController(ISender sender) => _sender = sender;

    [Authorize]
    [HttpGet("me")]
    public async Task<IActionResult> GetMine(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();
        var feedback = await _sender.Send(new GetMyFeedbackQuery(userId), cancellationToken);
        return feedback is null ? NoContent() : Ok(feedback);
    }

    [Authorize]
    [HttpPut("me")]
    public async Task<IActionResult> Upsert(
        [FromBody] UpsertFeedbackRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized();
        var feedback = await _sender.Send(new UpsertMyFeedbackCommand(
            userId, request.Rating, request.Topic, request.Content, request.PageUrl), cancellationToken);
        return feedback is null ? NotFound() : Ok(feedback);
    }

    [AllowAnonymous]
    [HttpGet("public")]
    public async Task<IActionResult> GetPublic([FromQuery] int limit = 6, CancellationToken cancellationToken = default)
        => Ok(await _sender.Send(new GetPublicFeedbackQuery(limit), cancellationToken));

    private Guid GetUserId()
    {
        var value = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return Guid.TryParse(value, out var userId) ? userId : Guid.Empty;
    }
}
```

- [ ] **Step 5: Build and exercise the endpoints through Swagger**

Run: `dotnet build backend/Locker.Backend.sln`, then `dotnet run --project backend/src/Locker.Backend/Locker.Backend.csproj`.

Manually verify:

- `GET /api/feedbacks/public` returns `200` without a token.
- `GET /api/feedbacks/me` returns `401` without a token.
- Authenticated `GET /me` returns `204` before first submission.
- Valid `PUT /me` returns `200`; a second `PUT /me` returns the same feedback ID.
- Invalid rating, topic, empty content, overlong content and unsafe page URL each return `400`.

- [ ] **Step 6: Commit user/public APIs**

```powershell
git add backend/src/Locker.Backend.Application/Features/Feedback backend/src/Locker.Backend/Controllers/FeedbacksController.cs
git commit -m "feat: expose user feedback api"
```

---

### Task 4: Add Admin Dashboard Queries, Visibility and CSV

**Files:**
- Create: `backend/src/Locker.Backend.Application/Features/Feedback/Commands/SetFeedbackVisibility/SetFeedbackVisibilityCommand.cs`
- Create: `backend/src/Locker.Backend.Application/Features/Feedback/Queries/GetAdminFeedback/GetAdminFeedbackQuery.cs`
- Create: `backend/src/Locker.Backend.Application/Features/Feedback/Queries/ExportFeedback/ExportFeedbackQuery.cs`
- Create: `backend/src/Locker.Backend/Controllers/AdminFeedbacksController.cs`

**Interfaces:**
- Consumes: `IFeedbackRepository`, `FeedbackFilter`, `AdminFeedbackResponse`, `ExportFeedbackResult`.
- Produces: `GET /api/admin/feedbacks`, `PATCH /api/admin/feedbacks/{id}/visibility`, and `GET /api/admin/feedbacks/export`, all protected by role `Admin`.

- [ ] **Step 1: Implement admin page query**

Use the exact signature:

```csharp
public sealed record GetAdminFeedbackQuery(
    int Page,
    int PageSize,
    int? Rating,
    FeedbackTopic? Topic,
    bool? IsVisible,
    string? Search) : IRequest<AdminFeedbackResponse>;
```

The handler creates one `FeedbackFilter`, calls `GetAdminPageAsync` and `GetSummaryAsync`, maps `Feedback` to `AdminFeedbackItemDto`, and returns a `PaginatedResult<AdminFeedbackItemDto>` preserving `TotalCount`, `PageNumber`, and `PageSize`.

Define `GetAdminFeedbackQueryValidator` in the same file:

```csharp
RuleFor(x => x.Page).GreaterThanOrEqualTo(1);
RuleFor(x => x.PageSize).InclusiveBetween(1, 100);
RuleFor(x => x.Rating).InclusiveBetween(1, 5).When(x => x.Rating.HasValue);
RuleFor(x => x.Topic).IsInEnum().When(x => x.Topic.HasValue);
RuleFor(x => x.Search).MaximumLength(200).When(x => x.Search is not null);
```

- [ ] **Step 2: Implement visibility command**

```csharp
public sealed record SetFeedbackVisibilityCommand(Guid Id, bool IsVisible) : IRequest<bool>;

public sealed class SetFeedbackVisibilityCommandHandler
    : IRequestHandler<SetFeedbackVisibilityCommand, bool>
{
    private readonly IFeedbackRepository _repository;
    public SetFeedbackVisibilityCommandHandler(IFeedbackRepository repository) => _repository = repository;
    public Task<bool> Handle(SetFeedbackVisibilityCommand request, CancellationToken cancellationToken)
        => _repository.SetVisibilityAsync(request.Id, request.IsVisible, cancellationToken);
}
```

- [ ] **Step 3: Implement CSV encoding and injection protection**

The export handler obtains filtered rows, writes this fixed header, quotes every field, applies CSV formula injection protection, and returns bytes prefixed with UTF-8 BOM:

```text
Username,Rating,Topic,Content,PageUrl,IsVisible,CreatedAtUtc,UpdatedAtUtc
```

Use this sanitizer before CSV quoting:

```csharp
private static string CsvCell(string value)
{
    var safe = value;
    if (safe.Length > 0 && "=+-@".Contains(safe[0]))
        safe = "'" + safe;
    return $"\"{safe.Replace("\"", "\"\"")}\"";
}
```

Serialize dates with format `O`, booleans as `true`/`false`, and build bytes with:

```csharp
var preamble = Encoding.UTF8.GetPreamble();
var body = Encoding.UTF8.GetBytes(csv.ToString());
var content = preamble.Concat(body).ToArray();
return new ExportFeedbackResult(content, $"feedback-{DateTime.UtcNow:yyyyMMdd-HHmmss}.csv");
```

Define `ExportFeedbackQueryValidator` beside the query with the same optional rating, topic and 200-character search rules as the admin list query.

- [ ] **Step 4: Add the admin controller**

Use `[Route("api/admin/feedbacks")]` and `[Authorize(Roles = "Admin")]`. Add:

```csharp
[HttpGet]
public async Task<IActionResult> GetAll(
    [FromQuery] int page = 1,
    [FromQuery] int pageSize = 20,
    [FromQuery] int? rating = null,
    [FromQuery] FeedbackTopic? topic = null,
    [FromQuery] bool? visibility = null,
    [FromQuery] string? search = null,
    CancellationToken cancellationToken = default)
```

```csharp
public sealed record SetFeedbackVisibilityRequest(bool IsVisible);
```

```csharp
[HttpPatch("{id:guid}/visibility")]
public async Task<IActionResult> SetVisibility(
    Guid id,
    [FromBody] SetFeedbackVisibilityRequest request,
    CancellationToken cancellationToken)
```

```csharp
[HttpGet("export")]
public async Task<IActionResult> Export(
    [FromQuery] int? rating = null,
    [FromQuery] FeedbackTopic? topic = null,
    [FromQuery] bool? visibility = null,
    [FromQuery] string? search = null,
    CancellationToken cancellationToken = default)
```

Return the export with `File(result.Content, "text/csv; charset=utf-8", result.FileName)`.

- [ ] **Step 5: Manually verify authorization and CSV**

With the real backend and real accounts:

- User token receives `403` for all `/api/admin/feedbacks` endpoints.
- Admin token receives `200` for list/export and `204` for a valid visibility change.
- Unknown feedback ID returns `404` on visibility change.
- Open the CSV in Excel and verify Vietnamese text, fixed columns and that a content value beginning with `=` displays as text.

- [ ] **Step 6: Build and commit admin APIs**

Run: `dotnet build backend/Locker.Backend.sln`

```powershell
git add backend/src/Locker.Backend.Application/Features/Feedback backend/src/Locker.Backend/Controllers/AdminFeedbacksController.cs
git commit -m "feat: add feedback administration api"
```

---

### Task 5: Add the Frontend Feedback API Client

**Files:**
- Modify: `web/src/lib/api.ts`
- Create: `web/src/features/feedback/types.ts`
- Create: `web/src/features/feedback/api/feedbackApi.ts`

**Interfaces:**
- Produces: authenticated `apiFetch`, `getMyFeedback`, `upsertMyFeedback`, `getPublicFeedback`, `getAdminFeedback`, `setFeedbackVisibility`, `downloadFeedbackCsv`.
- Consumes: backend JSON contracts from Tasks 3–4.

- [ ] **Step 1: Add Bearer authentication centrally without breaking login/public calls**

Build headers with `Headers` so a caller can override them:

```ts
const headers = new Headers(customHeaders);
if (!headers.has('Content-Type') && data !== undefined) {
  headers.set('Content-Type', 'application/json');
}
const token = localStorage.getItem('token');
if (token && !headers.has('Authorization')) {
  headers.set('Authorization', `Bearer ${token}`);
}
```

Keep endpoints relative to `VITE_API_BASE_URL || '/api'`, for example `/feedbacks/me`, so `/api` is not duplicated.

- [ ] **Step 2: Define TypeScript contracts and topic labels**

```ts
export type FeedbackTopic =
  | 'General'
  | 'BookingOrder'
  | 'Payment'
  | 'Delivery'
  | 'Interface'
  | 'Other';

export const FEEDBACK_TOPIC_LABELS: Record<FeedbackTopic, string> = {
  General: 'Trải nghiệm chung',
  BookingOrder: 'Đặt tủ / đơn hàng',
  Payment: 'Thanh toán',
  Delivery: 'Giao nhận',
  Interface: 'Giao diện',
  Other: 'Khác',
};

export interface UpsertFeedbackInput {
  rating: number;
  topic: FeedbackTopic;
  content: string;
  pageUrl: string;
}
```

Mirror every backend response from `FeedbackModels.cs` using camelCase property names. Define `FeedbackFilters` with optional `rating`, `topic`, `visibility`, `search`, `page`, and `pageSize`.

- [ ] **Step 3: Implement response handling once**

```ts
async function readJson<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const body = await response.json().catch(() => null);
    throw new Error(body?.message ?? 'Không thể xử lý yêu cầu.');
  }
  return response.json() as Promise<T>;
}
```

`getMyFeedback` treats `204` as `null`. Other functions use `readJson`. `downloadFeedbackCsv` checks `response.ok`, creates an object URL from `response.blob()`, reads the filename from `Content-Disposition` when present, clicks a temporary anchor, then revokes the URL.

- [ ] **Step 4: Build the web app**

Run: `npm run build` in `web`.

Expected: TypeScript and Vite build succeed without installing any test package.

- [ ] **Step 5: Commit the API client**

```powershell
git add web/src/lib/api.ts web/src/features/feedback/types.ts web/src/features/feedback/api/feedbackApi.ts
git commit -m "feat: add feedback web api client"
```

---

### Task 6: Build the Authenticated Feedback Widget

**Files:**
- Create: `web/src/features/feedback/components/StarRating.tsx`
- Create: `web/src/features/feedback/components/FeedbackModal.tsx`
- Create: `web/src/features/feedback/components/FeedbackButton.tsx`
- Modify: `web/src/components/layout/ProtectedRoute.tsx`

**Interfaces:**
- Consumes: `getMyFeedback`, `upsertMyFeedback`, `FeedbackTopic`, `useToast`, `useLocation`.
- Produces: one floating widget for every matched authenticated route.

- [ ] **Step 1: Implement accessible star selection**

`StarRating` accepts:

```ts
interface StarRatingProps {
  value: number;
  onChange: (value: number) => void;
  disabled?: boolean;
}
```

Render five `button type="button"` elements with `aria-label={`${value} sao`}`, `aria-pressed={selected}`, filled orange stars for selected positions and gray outlines otherwise. Arrow Left/Down decrements, Arrow Right/Up increments, Home selects 1 and End selects 5.

- [ ] **Step 2: Implement modal state and load behavior**

On each transition from closed to open:

```ts
setLoadState('loading');
getMyFeedback()
  .then((existing) => {
    setRating(existing?.rating ?? 0);
    setTopic(existing?.topic ?? 'General');
    setContent(existing?.content ?? '');
    setLoadState('ready');
  })
  .catch((error: Error) => {
    setLoadError(error.message);
    setLoadState('error');
  });
```

If load state is `error`, show retry and close actions but do not render an editable empty form.

- [ ] **Step 3: Implement validation and submit**

Before submit, enforce rating 1–5 and trimmed content length 1–2,000. Send:

```ts
await upsertMyFeedback({
  rating,
  topic,
  content: content.trim(),
  pageUrl: location.pathname,
});
```

Disable all controls while submitting. On success call `showToast('Cảm ơn bạn đã gửi feedback!', 'success')` and close. On failure keep all values and show the returned message inline.

- [ ] **Step 4: Implement modal accessibility and responsive layout**

Use `role="dialog"`, `aria-modal="true"`, a labelled heading, a backdrop, `max-h-[90vh]`, mobile padding and a content scroll area. Save `document.activeElement` before opening, focus the heading or first input after mount, close on `Escape`, lock body scrolling while open, and return focus to the trigger on close.

- [ ] **Step 5: Add the pill button once at the protected outlet**

Change `ProtectedRoute` success return to:

```tsx
return (
  <>
    <Outlet />
    <FeedbackButton />
  </>
);
```

The button uses `fixed bottom-5 right-5 z-40`, an orange pill, a small message icon and visible text `Feedback`. The modal uses a higher z-index than the button and header.

- [ ] **Step 6: Build and manually inspect core widget states**

Run: `npm run build` in `web`, then start web/backend. Verify the button on `/dashboard`, `/orders`, `/wallet` and a mobile viewport. Verify it is absent on `/`, `/login` and `/register`. Verify loading, first submit, reopen/update, retry after an intentionally stopped backend, keyboard controls and 2,000-character boundary.

- [ ] **Step 7: Commit the widget**

```powershell
git add web/src/features/feedback/components web/src/components/layout/ProtectedRoute.tsx
git commit -m "feat: add authenticated feedback widget"
```

---

### Task 7: Add Public Reviews to the Home Page

**Files:**
- Create: `web/src/features/feedback/components/PublicReviewsSection.tsx`
- Modify: `web/src/features/home/pages/HomePage.tsx`

**Interfaces:**
- Consumes: `getPublicFeedback(6)`, `FEEDBACK_TOPIC_LABELS`.
- Produces: public section showing only backend-approved public response fields.

- [ ] **Step 1: Implement loading, empty, success and failure states**

Fetch once on mount. While loading, show three neutral skeleton cards. If there are no visible reviews, render a compact section inviting signed-in users to use the Feedback button. If the request fails, keep the rest of the home page usable and show a small retry button inside the section.

- [ ] **Step 2: Render the summary and newest six reviews**

Use semantic section heading `Người dùng nói gì`. Render `averageRating.toFixed(1)`, `totalVisibleReviewers`, five visual stars, then a responsive `grid gap-4 md:grid-cols-2 lg:grid-cols-3`. Each card renders username, rating, topic label, content using normal JSX text interpolation, and localized `updatedAt`. Do not render raw HTML.

- [ ] **Step 3: Add the section before the footer**

```tsx
<LocationsSection />
<PublicReviewsSection />
<Footer />
```

- [ ] **Step 4: Build and verify visibility manually**

Run: `npm run build` in `web`. With one visible and one hidden real review, confirm only the visible review appears. Confirm the page shows no user ID, email, page URL or admin state in DOM-visible content.

- [ ] **Step 5: Commit public reviews**

```powershell
git add web/src/features/feedback/components/PublicReviewsSection.tsx web/src/features/home/pages/HomePage.tsx
git commit -m "feat: show public feedback on home page"
```

---

### Task 8: Build the Admin Feedback Dashboard

**Files:**
- Create: `web/src/features/feedback/pages/AdminFeedbackPage.tsx`
- Modify: `web/src/routes/index.tsx`
- Modify: `web/src/components/layout/AppHeader.tsx`

**Interfaces:**
- Consumes: `getAdminFeedback`, `setFeedbackVisibility`, `downloadFeedbackCsv`, `FeedbackFilters`.
- Produces: `/admin/feedbacks`, visible only through admin navigation and protected by role route.

- [ ] **Step 1: Register protected routing and navigation**

Add the page import and route inside the admin-only `ProtectedRoute`:

```tsx
<Route element={<ProtectedRoute allowedRoles={['Admin']} />}>
  <Route path="/admin/feedbacks" element={<AdminFeedbackPage />} />
</Route>
```

Add `{ to: '/admin/feedbacks', label: 'Feedback' }` to the Admin navigation links in `AppHeader`, including the mobile list through the existing shared `NAV_LINKS` mapping.

- [ ] **Step 2: Keep filters in one query state**

Initialize:

```ts
const [filters, setFilters] = useState<FeedbackFilters>({ page: 1, pageSize: 20 });
```

Changing rating, topic, visibility or search resets `page` to 1. Debounce search by 300 ms. Use `URLSearchParams` in `feedbackApi` and omit empty values. Refetch after visibility changes while retaining current filters.

- [ ] **Step 3: Render evidence summary and distributions**

Render cards for:

- `Đã có {totalReviewers}/10 người dùng đánh giá`, green when `totalReviewers >= 10`.
- `Điểm trung bình`, formatted to one decimal.
- `Review đang hiển thị`, using `visibleReviewers`.

Render five rating distribution bars and six topic distribution bars from the complete bucket arrays returned by the backend. Use text counts alongside CSS bars so the information is not color-only.

- [ ] **Step 4: Render filter controls and paginated table**

Provide selects for all rating/topic/visibility values, a search input, reset button and CSV button. The table columns are username, sao, chủ đề, nội dung, trang gửi, tạo lúc, cập nhật lúc, trạng thái and action. Long content uses a constrained cell with accessible full-text expansion or `title`. Page controls use `hasPreviousPage`, `hasNextPage`, `pageNumber`, `totalPages` from the response.

- [ ] **Step 5: Implement hide/show with failure recovery**

On action, disable only the affected row, call `setFeedbackVisibility(id, !isVisible)`, show a success toast, and refetch. If it fails, leave the current row state unchanged and show an error toast. Do not optimistically remove the row before the API succeeds.

- [ ] **Step 6: Implement CSV export using current filters**

Pass `rating`, `topic`, `visibility` and debounced `search`, but omit page/pageSize. Disable the export button during download and show an error toast on failure.

- [ ] **Step 7: Build and manually verify role behavior**

Run: `npm run build` in `web`. Verify admin navigation and route work; a user navigating directly to `/admin/feedbacks` is redirected by `ProtectedRoute`. Verify loading, empty state, combined filters, pagination, hide/show refresh and CSV download.

- [ ] **Step 8: Commit the dashboard**

```powershell
git add web/src/features/feedback/pages/AdminFeedbackPage.tsx web/src/routes/index.tsx web/src/components/layout/AppHeader.tsx
git commit -m "feat: add admin feedback dashboard"
```

---

### Task 9: Execute and Record the Manual Acceptance Run

**Files:**
- Create: `docs/testing/user-feedback-manual-test.md`

**Interfaces:**
- Consumes: completed backend, web app, real MongoDB and at least 10 distinct real user accounts.
- Produces: reproducible manual evidence without passwords, tokens, emails or other secrets.

- [ ] **Step 1: Verify clean production builds**

Run:

```powershell
dotnet build backend/Locker.Backend.sln
Set-Location web
npm run build
```

Expected: both commands exit `0`; record timestamp, commit SHA and command result in the evidence document.

- [ ] **Step 2: Record the single-user lifecycle**

Using one real user account, record:

- Authenticated routes where the button appears and public/auth routes where it does not.
- First submission result and returned feedback ID.
- Update result showing the same feedback ID.
- MongoDB count for that `UserId` equal to `1`.
- Behavior when backend is unavailable and after retry.

Mask the account as `user-01`; do not record its password, token or email.

- [ ] **Step 3: Record validation and authorization results**

Use Swagger or an API client against the running backend. Record the observed status codes for invalid rating, invalid topic, empty content, 2,001-character content, unsafe page URL, missing token, user token on admin route and unknown visibility ID. Expected codes are `400`, `401`, `403` and `404` according to the spec.

- [ ] **Step 4: Collect and verify 10 distinct users**

Have 10 real user accounts submit feedback through the E-box UI. Record them only as `user-01` through `user-10`, with rating/topic and submission timestamp. Verify:

```javascript
db.feedbacks.aggregate([
  { $group: { _id: "$userId", count: { $sum: 1 } } },
  { $group: { _id: null, distinctUsers: { $sum: 1 }, duplicateUsers: { $sum: { $cond: [{ $gt: ["$count", 1] }, 1, 0] } } } }
])
```

Expected: `distinctUsers >= 10`, `duplicateUsers = 0`, and dashboard progress shows at least `10/10`.

- [ ] **Step 5: Verify moderation invariants**

Hide one real review and record that it disappears from the home page while admin progress remains unchanged. Update that hidden review as its owner and record that it stays hidden. Show it again and record that it returns to the public section.

- [ ] **Step 6: Verify filters, pagination, CSV and responsive behavior**

Record at least one result for each filter, one combined filter, search, previous/next pagination, CSV row count under a filter, Vietnamese text in Excel, a formula-like content cell displayed as text, desktop layout and mobile layout. Attach screenshot filenames or externally managed evidence references without committing personal data.

- [ ] **Step 7: Run final repository checks**

Run:

```powershell
dotnet build backend/Locker.Backend.sln
Set-Location web
npm run build
Set-Location ..
git diff --check
git status --short
```

Expected: builds exit `0`; `git diff --check` reports no whitespace errors; status contains only the manual evidence document before its commit.

- [ ] **Step 8: Commit manual verification evidence**

```powershell
git add docs/testing/user-feedback-manual-test.md
git commit -m "docs: record manual feedback verification"
```
