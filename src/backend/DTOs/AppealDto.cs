using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

public class AppealRequestDto
{
    [Required(ErrorMessage = "Mã môn học không được để trống")]
    [MaxLength(20, ErrorMessage = "Mã môn học không được vượt quá 20 ký tự")]
    public string CourseId { get; set; } = string.Empty;

    [Required(ErrorMessage = "Lý do phúc khảo không được để trống")]
    public string Reason { get; set; } = string.Empty;

    [Required(ErrorMessage = "Phương thức thanh toán không được để trống")]
    [RegularExpression("^(banking|momo|vnpay|cash)$", ErrorMessage = "Phương thức thanh toán không hợp lệ")]
    public string PaymentMethod { get; set; } = string.Empty;
}

public class AppealResponseDto
{
    public int Id { get; set; }
    public string CourseId { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
    public string PaymentStatus { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string CreatedAt { get; set; } = string.Empty;
    public string? Message { get; set; }
}
