using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

public class StudentCardDto
{
    public int Mssv { get; set; }

    public string HoTen { get; set; }

    public int KhoaHoc { get; set; }

    public string NganhHoc { get; set; }

    public string? AvatarFullUrl { get; set; } // Đường dẫn đầy đủ, có thể null

}

