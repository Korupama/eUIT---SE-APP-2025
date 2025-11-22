using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;
public class NextClassDto
{
    public string MaLop { get; set; } = string.Empty;
    public string TenMonHoc { get; set; } = string.Empty;
    public string TenGiangVien { get; set; } = string.Empty;
    public string Thu { get; set; } = string.Empty;
    public int TietBatDau { get; set; }
    public int TietKetThuc { get; set; }
    public string PhongHoc { get; set; } = string.Empty;
    public DateTime NgayHoc { get; set; }
}