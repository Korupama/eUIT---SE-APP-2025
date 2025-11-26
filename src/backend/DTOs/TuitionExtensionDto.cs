using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

public class TuitionExtensionRequestDto
{
    [Required(ErrorMessage = "Lý do gia hạn không được để trống")]
    public string Reason { get; set; } = string.Empty;

    [Required(ErrorMessage = "Thời gian mong muốn không được để trống")]
    public DateTime DesiredTime { get; set; }

    public IFormFile? SupportingDocs { get; set; }
}

public class TuitionExtensionUpdateDto
{
    public string? Reason { get; set; }
    public DateTime? DesiredTime { get; set; }
    public IFormFile? SupportingDocs { get; set; }
}

public class TuitionExtensionResponseDto
{
    public int Id { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string DesiredTime { get; set; } = string.Empty;
    public string? SupportingDocs { get; set; }
    public string Status { get; set; } = string.Empty;
    public string CreatedAt { get; set; } = string.Empty;
    public string UpdatedAt { get; set; } = string.Empty;
    public string? Message { get; set; }
}
