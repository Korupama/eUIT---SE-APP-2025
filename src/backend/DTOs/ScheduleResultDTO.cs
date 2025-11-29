namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from schedule functions
/// </summary>
public class ScheduleResultDto
{
    public string hoc_ky { get; set; } = string.Empty;
    public string ma_mon_hoc { get; set; } = string.Empty;
    public string ten_mon_hoc { get; set; } = string.Empty;
    public string ma_lop { get; set; } = string.Empty;
    public int so_tin_chi { get; set; }
    public string ma_giang_vien { get; set; } = string.Empty;
    public string ho_ten { get; set; } = string.Empty;
    public string thu { get; set; } = string.Empty;
    public int? tiet_bat_dau { get; set; }
    public int? tiet_ket_thuc { get; set; }
    public int? cach_tuan { get; set; }
    public DateTime? ngay_bat_dau { get; set; }
    public DateTime? ngay_ket_thuc { get; set; }
    public string phong_hoc { get; set; } = string.Empty;
    public int? si_so { get; set; }
    public string hinh_thuc_giang_day { get; set; } = string.Empty;
    public string? ghi_chu { get; set; }
}
