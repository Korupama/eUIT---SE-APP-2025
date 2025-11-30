using eUIT.Socket.Hubs;
using eUIT.Socket.Services;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel for cloud deployment
var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// CORS configuration
var allowedOriginsEnv = Environment.GetEnvironmentVariable("ALLOWED_ORIGINS");
var allowedOrigins = !string.IsNullOrEmpty(allowedOriginsEnv) 
    ? allowedOriginsEnv.Split(',', StringSplitOptions.RemoveEmptyEntries)
    : new[] { "http://localhost:3000", "http://localhost:5000", "http://localhost:8080" };

builder.Services.AddCors(options =>
{
    options.AddPolicy("SignalRPolicy", policy =>
    {
        if (allowedOriginsEnv == "*")
        {
            policy.SetIsOriginAllowed(_ => true)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        }
        else
        {
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        }
    });
});

// Add SignalR with camelCase JSON serialization for Flutter compatibility
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
}).AddJsonProtocol(options =>
{
    options.PayloadSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});

// Register notification service
builder.Services.AddSingleton<INotificationService, NotificationService>();

// Health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseCors("SignalRPolicy");
app.MapHealthChecks("/health");

// Server info
app.MapGet("/", () => new
{
    service = "eUIT Notification Server",
    version = "1.0.0",
    hub = "/notifications",
    health = "/health",
    onlineStudents = NotificationHub.GetOnlineCount(),
    serverTime = DateTimeOffset.UtcNow
});

// SignalR hub
app.MapHub<NotificationHub>("/notifications");

// === API Endpoints for Backend Integration ===

// Kết quả học tập (Grade updates)
app.MapPost("/api/notify/ket-qua-hoc-tap/{maSinhVien}", async (
    string maSinhVien,
    KetQuaHocTapNotification data,
    INotificationService notificationService) =>
{
    await notificationService.NotifyKetQuaHocTapAsync(maSinhVien, data);
    return Results.Ok(new { success = true, type = "ket_qua_hoc_tap", maSinhVien });
});

// Báo bù (Make-up class)
app.MapPost("/api/notify/bao-bu/{maSinhVien}", async (
    string maSinhVien,
    BaoBuNotification data,
    INotificationService notificationService) =>
{
    await notificationService.NotifyBaoBuAsync(maSinhVien, data);
    return Results.Ok(new { success = true, type = "bao_bu", maSinhVien });
});

// Báo nghỉ (Class cancellation)
app.MapPost("/api/notify/bao-nghi/{maSinhVien}", async (
    string maSinhVien,
    BaoNghiNotification data,
    INotificationService notificationService) =>
{
    await notificationService.NotifyBaoNghiAsync(maSinhVien, data);
    return Results.Ok(new { success = true, type = "bao_nghi", maSinhVien });
});

// Điểm rèn luyện (Training score)
app.MapPost("/api/notify/diem-ren-luyen/{maSinhVien}", async (
    string maSinhVien,
    DiemRenLuyenNotification data,
    INotificationService notificationService) =>
{
    await notificationService.NotifyDiemRenLuyenAsync(maSinhVien, data);
    return Results.Ok(new { success = true, type = "diem_ren_luyen", maSinhVien });
});

// Batch notify multiple students
app.MapPost("/api/notify/batch", async (
    BatchNotificationRequest request,
    INotificationService notificationService) =>
{
    await notificationService.NotifyStudentsAsync(request.MaSinhViens, request.EventName, request.Data);
    return Results.Ok(new { success = true, count = request.MaSinhViens.Count() });
});

// Broadcast to all
app.MapPost("/api/notify/broadcast", async (
    BroadcastRequest request,
    INotificationService notificationService) =>
{
    await notificationService.BroadcastAsync(request.Title, request.Message, request.Data);
    return Results.Ok(new { success = true, type = "broadcast" });
});

// Check if student is online
app.MapGet("/api/status/{maSinhVien}", (string maSinhVien) =>
{
    return Results.Ok(new
    {
        maSinhVien,
        online = NotificationHub.IsStudentOnline(maSinhVien)
    });
});

Console.WriteLine($"╔═══════════════════════════════════════════════════════╗");
Console.WriteLine($"║      eUIT Notification Server - Port {port,-5}            ║");
Console.WriteLine($"╠═══════════════════════════════════════════════════════╣");
Console.WriteLine($"║  Hub:  /notifications                                 ║");
Console.WriteLine($"║  API:  /api/notify/ket-qua-hoc-tap/{{maSinhVien}}       ║");
Console.WriteLine($"║        /api/notify/bao-bu/{{maSinhVien}}                ║");
Console.WriteLine($"║        /api/notify/bao-nghi/{{maSinhVien}}              ║");
Console.WriteLine($"║        /api/notify/diem-ren-luyen/{{maSinhVien}}        ║");
Console.WriteLine($"╚═══════════════════════════════════════════════════════╝");

app.Run();

// Request DTOs
record BatchNotificationRequest(IEnumerable<string> MaSinhViens, string EventName, object Data);
record BroadcastRequest(string Title, string Message, object? Data = null);
