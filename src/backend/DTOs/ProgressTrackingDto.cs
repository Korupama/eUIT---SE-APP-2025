namespace eUIT.API.DTOs;

public class ProgressTrackingDto
{
    public float OverallProgressPercentage { get; set; }
    public int TotalRequiredCredits { get; set; }
    public int CompletedCredits { get; set; }
    public int RemainingCredits { get; set; }
    public string? Message { get; set; } // Dùng cho thông báo "Đang chờ xác nhận"
    public List<CourseProgressDto> ProgressDetails { get; set; } = new();
}