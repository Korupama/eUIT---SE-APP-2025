using System.Net.Http.Json;

namespace eUIT.API.Services;

/// <summary>
/// DTOs for notification payloads
/// </summary>
public record KetQuaHocTapNotification(
    string MaMonHoc,
    string TenMonHoc,
    string MaLopHocPhan,
    decimal? DiemQuaTrinh,
    decimal? DiemGiuaKy,
    decimal? DiemCuoiKy,
    decimal? DiemTongKet,
    string? DiemChu,
    string HocKy,
    string NamHoc
);

public record BaoBuNotification(
    string MaLopHocPhan,
    string TenMonHoc,
    DateTime NgayBu,
    string TietBatDau,
    string TietKetThuc,
    string PhongHoc,
    string? GhiChu
);

public record BaoNghiNotification(
    string MaLopHocPhan,
    string TenMonHoc,
    DateTime NgayNghi,
    string LyDo,
    string? GhiChu
);

public record DiemRenLuyenNotification(
    string HocKy,
    string NamHoc,
    int DiemRenLuyen,
    string XepLoai
);

/// <summary>
/// Service interface for sending notifications to students via SignalR socket server
/// </summary>
public interface INotificationClient
{
    /// <summary>
    /// Notify about grade update (kết quả học tập)
    /// </summary>
    Task NotifyKetQuaHocTapAsync(string maSinhVien, KetQuaHocTapNotification data);

    /// <summary>
    /// Notify about make-up class (báo bù)
    /// </summary>
    Task NotifyBaoBuAsync(string maSinhVien, BaoBuNotification data);

    /// <summary>
    /// Notify about class cancellation (báo nghỉ)
    /// </summary>
    Task NotifyBaoNghiAsync(string maSinhVien, BaoNghiNotification data);

    /// <summary>
    /// Notify about training score update (điểm rèn luyện)
    /// </summary>
    Task NotifyDiemRenLuyenAsync(string maSinhVien, DiemRenLuyenNotification data);

    /// <summary>
    /// Notify multiple students at once
    /// </summary>
    Task NotifyStudentsAsync(IEnumerable<string> maSinhViens, string eventName, object data);

    /// <summary>
    /// Broadcast to all connected students
    /// </summary>
    Task BroadcastAsync(string title, string message, object? data = null);
}

/// <summary>
/// HTTP client implementation for sending notifications to socket server
/// </summary>
public class NotificationClient : INotificationClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<NotificationClient> _logger;
    private readonly string _baseUrl;

    public NotificationClient(HttpClient httpClient, IConfiguration configuration, ILogger<NotificationClient> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
        _baseUrl = configuration["NotificationServer:BaseUrl"] ?? "http://localhost:5000";
        _httpClient.BaseAddress = new Uri(_baseUrl);
        _httpClient.Timeout = TimeSpan.FromSeconds(10);
    }

    public async Task NotifyKetQuaHocTapAsync(string maSinhVien, KetQuaHocTapNotification data)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync($"/api/notify/ket-qua-hoc-tap/{maSinhVien}", data);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Failed to send KetQuaHocTap notification to {MaSinhVien}: {StatusCode}", 
                    maSinhVien, response.StatusCode);
            }
            else
            {
                _logger.LogInformation("KetQuaHocTap notification sent to {MaSinhVien}: {TenMonHoc}", 
                    maSinhVien, data.TenMonHoc);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending KetQuaHocTap notification to {MaSinhVien}", maSinhVien);
        }
    }

    public async Task NotifyBaoBuAsync(string maSinhVien, BaoBuNotification data)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync($"/api/notify/bao-bu/{maSinhVien}", data);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Failed to send BaoBu notification to {MaSinhVien}: {StatusCode}", 
                    maSinhVien, response.StatusCode);
            }
            else
            {
                _logger.LogInformation("BaoBu notification sent to {MaSinhVien}: {TenMonHoc} on {NgayBu}", 
                    maSinhVien, data.TenMonHoc, data.NgayBu);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending BaoBu notification to {MaSinhVien}", maSinhVien);
        }
    }

    public async Task NotifyBaoNghiAsync(string maSinhVien, BaoNghiNotification data)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync($"/api/notify/bao-nghi/{maSinhVien}", data);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Failed to send BaoNghi notification to {MaSinhVien}: {StatusCode}", 
                    maSinhVien, response.StatusCode);
            }
            else
            {
                _logger.LogInformation("BaoNghi notification sent to {MaSinhVien}: {TenMonHoc} on {NgayNghi}", 
                    maSinhVien, data.TenMonHoc, data.NgayNghi);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending BaoNghi notification to {MaSinhVien}", maSinhVien);
        }
    }

    public async Task NotifyDiemRenLuyenAsync(string maSinhVien, DiemRenLuyenNotification data)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync($"/api/notify/diem-ren-luyen/{maSinhVien}", data);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Failed to send DiemRenLuyen notification to {MaSinhVien}: {StatusCode}", 
                    maSinhVien, response.StatusCode);
            }
            else
            {
                _logger.LogInformation("DiemRenLuyen notification sent to {MaSinhVien}: {HocKy} - {Diem}", 
                    maSinhVien, data.HocKy, data.DiemRenLuyen);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending DiemRenLuyen notification to {MaSinhVien}", maSinhVien);
        }
    }

    public async Task NotifyStudentsAsync(IEnumerable<string> maSinhViens, string eventName, object data)
    {
        try
        {
            var payload = new { MaSinhViens = maSinhViens, EventName = eventName, Data = data };
            var response = await _httpClient.PostAsJsonAsync("/api/notify/batch", payload);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Failed to send batch notification: {StatusCode}", response.StatusCode);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending batch notification");
        }
    }

    public async Task BroadcastAsync(string title, string message, object? data = null)
    {
        try
        {
            var payload = new { Title = title, Message = message, Data = data };
            var response = await _httpClient.PostAsJsonAsync("/api/notify/broadcast", payload);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Failed to send broadcast: {StatusCode}", response.StatusCode);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending broadcast notification");
        }
    }
}

/// <summary>
/// Extension methods for registering notification services
/// </summary>
public static class NotificationServiceExtensions
{
    public static IServiceCollection AddNotificationClient(this IServiceCollection services)
    {
        services.AddHttpClient<INotificationClient, NotificationClient>();
        return services;
    }
}
