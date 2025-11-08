using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

public class LoginRequestDto
{
    [Required]
    public string role { get; set; } = string.Empty;

    [Required]
    public string userId { get; set; } = string.Empty;

    [Required]
    public string password { get; set; } = string.Empty;

}