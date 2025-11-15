using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;
public class NextClassDto
{
    public string MaLop { get; set; }
    public string TenLop { get; set; }
    public string Thu { get; set; }
    public int TietBatDau { get; set; }
    public int TietKetThuc { get; set; }
    public string PhongHoc { get; set; }
    public DateTime NgayHoc { get; set; }
}