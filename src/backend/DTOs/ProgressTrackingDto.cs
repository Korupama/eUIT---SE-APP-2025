namespace eUIT.API.DTOs;

public class ProgressTrackingDto
{
    public List<GroupProgressDto> ProgressByGroup { get; set; } = new();
    public string? Message { get; set; }
}