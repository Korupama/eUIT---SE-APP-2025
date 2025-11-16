namespace eUIT.API.DTOs;

public class GroupProgressDto
{
    public string GroupName { get; set; } = string.Empty;
    public int CompletedCredits { get; set; }
    public decimal Gpa { get; set; }
}