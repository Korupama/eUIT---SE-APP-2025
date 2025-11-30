using Microsoft.AspNetCore.SignalR;

namespace eUIT.Socket.Hubs;

/// <summary>
/// SignalR hub for student notifications
/// Handles real-time updates for: ket_qua_hoc_tap, bao_bu, bao_nghi, diem_ren_luyen
/// </summary>
public class NotificationHub : Hub
{
    private static readonly Dictionary<string, HashSet<string>> _userConnections = new();
    private static readonly object _lock = new();

    public override async Task OnConnectedAsync()
    {
        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] Client connected: {Context.ConnectionId}");
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var connectionId = Context.ConnectionId;
        
        // Remove connection from all user mappings
        lock (_lock)
        {
            foreach (var kvp in _userConnections.ToList())
            {
                kvp.Value.Remove(connectionId);
                if (kvp.Value.Count == 0)
                    _userConnections.Remove(kvp.Key);
            }
        }

        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] Client disconnected: {connectionId}");
        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Subscribe to notifications for a student
    /// </summary>
    /// <param name="maSinhVien">Student ID (mã sinh viên)</param>
    public async Task Subscribe(string maSinhVien)
    {
        var connectionId = Context.ConnectionId;

        // Add to student group
        await Groups.AddToGroupAsync(connectionId, $"student_{maSinhVien}");

        // Track connection
        lock (_lock)
        {
            if (!_userConnections.ContainsKey(maSinhVien))
                _userConnections[maSinhVien] = new HashSet<string>();
            _userConnections[maSinhVien].Add(connectionId);
        }

        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] Student {maSinhVien} subscribed");

        await Clients.Caller.SendAsync("Subscribed", new
        {
            maSinhVien,
            message = "Đã đăng ký nhận thông báo",
            timestamp = DateTimeOffset.UtcNow
        });
    }

    /// <summary>
    /// Unsubscribe from notifications
    /// </summary>
    public async Task Unsubscribe(string maSinhVien)
    {
        var connectionId = Context.ConnectionId;

        await Groups.RemoveFromGroupAsync(connectionId, $"student_{maSinhVien}");

        lock (_lock)
        {
            if (_userConnections.ContainsKey(maSinhVien))
            {
                _userConnections[maSinhVien].Remove(connectionId);
                if (_userConnections[maSinhVien].Count == 0)
                    _userConnections.Remove(maSinhVien);
            }
        }

        Console.WriteLine($"[{DateTime.UtcNow:HH:mm:ss}] Student {maSinhVien} unsubscribed");

        await Clients.Caller.SendAsync("Unsubscribed", new
        {
            maSinhVien,
            timestamp = DateTimeOffset.UtcNow
        });
    }

    /// <summary>
    /// Check if student is online
    /// </summary>
    public static bool IsStudentOnline(string maSinhVien)
    {
        lock (_lock)
        {
            return _userConnections.ContainsKey(maSinhVien) && _userConnections[maSinhVien].Count > 0;
        }
    }

    /// <summary>
    /// Get count of online students
    /// </summary>
    public static int GetOnlineCount()
    {
        lock (_lock)
        {
            return _userConnections.Count;
        }
    }
}
