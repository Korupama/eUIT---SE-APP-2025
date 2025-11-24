namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from func_get_next_class
/// </summary>
public class NextClassInfoDto
{
    public string ma_lop { get; set; } = string.Empty;
    public string ten_mon_hoc_vn { get; set; } = string.Empty;
    public string ho_ten { get; set; } = string.Empty;
    public string thu { get; set; } = string.Empty;
    public int tiet_bat_dau { get; set; }
    public int tiet_ket_thuc { get; set; }
    public string phong_hoc { get; set; } = string.Empty;
    public DateTime ngay_hoc { get; set; }
    public int countdown_minutes { get; set; }
}
