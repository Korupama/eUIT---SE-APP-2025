namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from exam schedule functions
/// </summary>
public class ExamResultDto
{
    public string ma_mon_hoc { get; set; } = string.Empty;
    public string ten_mon_hoc { get; set; } = string.Empty;
    public string ma_lop { get; set; } = string.Empty;
    public string? ma_giang_vien { get; set; }
    public string? ho_ten { get; set; }
    public DateTime ngay_thi { get; set; }
    public int ca_thi { get; set; }
    public string phong_thi { get; set; } = string.Empty;
    public string? hinh_thuc_thi { get; set; }
    public string gk_ck { get; set; } = string.Empty;
    public int so_tin_chi { get; set; }
}
