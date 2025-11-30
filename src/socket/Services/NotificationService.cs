using Microsoft.AspNetCore.SignalR;
using eUIT.Socket.Hubs;

namespace eUIT.Socket.Services;

/// <summary>
/// Service for sending notifications to students
/// </summary>
public interface INotificationService
{
    /// <summary>
    /// Notify student about grade update (kết quả học tập)
    /// </summary>
    Task NotifyKetQuaHocTapAsync(string maSinhVien, KetQuaHocTapNotification data);

    /// <summary>
    /// Notify student about make-up class (báo bù)
    /// </summary>
    Task NotifyBaoBuAsync(string maSinhVien, BaoBuNotification data);

    /// <summary>
    /// Notify student about class cancellation (báo nghỉ)
    /// </summary>
    Task NotifyBaoNghiAsync(string maSinhVien, BaoNghiNotification data);

    /// <summary>
    /// Notify student about training score update (điểm rèn luyện)
    /// </summary>
    Task NotifyDiemRenLuyenAsync(string maSinhVien, DiemRenLuyenNotification data);

    /// <summary>
    /// Notify multiple students (batch)
    /// </summary>
    Task NotifyStudentsAsync(IEnumerable<string> maSinhViens, string eventName, object data);

    /// <summary>
    /// Broadcast to all connected students
    /// </summary>
    Task BroadcastAsync(string title, string message, object? data = null);
}

public class NotificationService : INotificationService
{
    private readonly IHubContext<NotificationHub> _hubContext;

    public NotificationService(IHubContext<NotificationHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public async Task NotifyKetQuaHocTapAsync(string maSinhVien, KetQuaHocTapNotification data)
    {
        var payload = new
        {
            type = "ket_qua_hoc_tap",
            title = "Cập nhật điểm",
            message = $"Điểm môn {data.TenMonHoc} đã được cập nhật",
            data,
            timestamp = DateTimeOffset.UtcNow
        };

        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] KetQuaHocTap -> {maSinhVien}: {data.TenMonHoc}");

        await _hubContext.Clients.Group($"student_{maSinhVien}")
            .SendAsync("ReceiveKetQuaHocTap", payload);
    }

    public async Task NotifyBaoBuAsync(string maSinhVien, BaoBuNotification data)
    {
        var payload = new
        {
            type = "bao_bu",
            title = "Thông báo học bù",
            message = $"Lớp {data.TenMonHoc} có lịch học bù vào {data.NgayBu:dd/MM/yyyy}",
            data,
            timestamp = DateTimeOffset.UtcNow
        };

        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] BaoBu -> {maSinhVien}: {data.TenMonHoc}");

        await _hubContext.Clients.Group($"student_{maSinhVien}")
            .SendAsync("ReceiveBaoBu", payload);
    }

    public async Task NotifyBaoNghiAsync(string maSinhVien, BaoNghiNotification data)
    {
        var payload = new
        {
            type = "bao_nghi",
            title = "Thông báo nghỉ học",
            message = $"Lớp {data.TenMonHoc} nghỉ học ngày {data.NgayNghi:dd/MM/yyyy}",
            data,
            timestamp = DateTimeOffset.UtcNow
        };

        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] BaoNghi -> {maSinhVien}: {data.TenMonHoc}");

        await _hubContext.Clients.Group($"student_{maSinhVien}")
            .SendAsync("ReceiveBaoNghi", payload);
    }

    public async Task NotifyDiemRenLuyenAsync(string maSinhVien, DiemRenLuyenNotification data)
    {
        var payload = new
        {
            type = "diem_ren_luyen",
            title = "Cập nhật điểm rèn luyện",
            message = $"Điểm rèn luyện {data.HocKy} đã được cập nhật: {data.DiemRenLuyen} điểm ({data.XepLoai})",
            data,
            timestamp = DateTimeOffset.UtcNow
        };

        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] DiemRenLuyen -> {maSinhVien}: {data.HocKy}");

        await _hubContext.Clients.Group($"student_{maSinhVien}")
            .SendAsync("ReceiveDiemRenLuyen", payload);
    }

    public async Task NotifyStudentsAsync(IEnumerable<string> maSinhViens, string eventName, object data)
    {
        var tasks = maSinhViens.Select(msv =>
            _hubContext.Clients.Group($"student_{msv}").SendAsync(eventName, data));

        await Task.WhenAll(tasks);
    }

    public async Task BroadcastAsync(string title, string message, object? data = null)
    {
        var payload = new
        {
            type = "broadcast",
            title,
            message,
            data,
            timestamp = DateTimeOffset.UtcNow
        };

        await _hubContext.Clients.All.SendAsync("Broadcast", payload);
    }
}

#region Notification DTOs

/// <summary>
/// Grade update notification data (Kết quả học tập)
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

/// <summary>
/// Make-up class notification data (Báo bù)
/// </summary>
public record BaoBuNotification(
    string MaLopHocPhan,
    string TenMonHoc,
    DateTime NgayBu,
    string TietBatDau,
    string TietKetThuc,
    string PhongHoc,
    string? GhiChu
);

/// <summary>
/// Class cancellation notification data (Báo nghỉ)
/// </summary>
public record BaoNghiNotification(
    string MaLopHocPhan,
    string TenMonHoc,
    DateTime NgayNghi,
    string LyDo,
    string? GhiChu
);

/// <summary>
/// Training score notification data (Điểm rèn luyện)
/// </summary>
public record DiemRenLuyenNotification(
    string HocKy,
    string NamHoc,
    int DiemRenLuyen,
    string XepLoai
);

#endregion
