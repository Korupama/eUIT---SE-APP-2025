namespace eUIT.API.DTOs;

public class GraduationProgressDto
{
    public int TotalCreditsRequired { get; set; }
    public int TotalCreditsCompleted { get; set; }
    public double CompletionPercentage { get; set; }
}

public class ProgressTrackingDto
{
    public List<GroupProgressDto> ProgressByGroup { get; set; } = new();
    public GraduationProgressDto? GraduationProgress { get; set; }
}