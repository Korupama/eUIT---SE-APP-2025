using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

// Custom validation attribute for allowed months
public class AllowedMonthsAttribute : ValidationAttribute
{
    private static readonly int[] ValidMonths = { 1, 3, 6, 9, 12 };
    public override bool IsValid(object? value) => value is int months && ValidMonths.Contains(months);
}

public class ParkingPassRequestDto
{
    // LicensePlate is optional here because it's only required for motorbikes,
    // which is handled in the controller logic.
    public string? LicensePlate { get; set; }

    [Required(ErrorMessage = "Loại xe là bắt buộc.")]
    [RegularExpression("^(bicycle|motorbike)$", ErrorMessage = "Loại xe phải là 'bicycle' hoặc 'motorbike'.")]
    public string VehicleType { get; set; } = string.Empty;

    [Required(ErrorMessage = "Số tháng đăng ký là bắt buộc.")]
    [AllowedMonths(ErrorMessage = "Số tháng đăng ký phải là 1, 3, 6, 9, hoặc 12.")]
    public int RegistrationMonths { get; set; }
}