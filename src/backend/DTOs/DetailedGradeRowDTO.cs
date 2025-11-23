namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from detailed transcript functions
/// </summary>
public class DetailedGradeRowDto
{
    public string hoc_ky { get; set; } = string.Empty;
    public string ma_mon_hoc { get; set; } = string.Empty;
    public string ten_mon_hoc { get; set; } = string.Empty;
    public int so_tin_chi { get; set; }
    public int trong_so_qua_trinh { get; set; }
    public int trong_so_giua_ki { get; set; }
    public int trong_so_thuc_hanh { get; set; }
    public int trong_so_cuoi_ki { get; set; }
    public float? diem_qua_trinh { get; set; }
    public float? diem_giua_ki { get; set; }
    public float? diem_thuc_hanh { get; set; }
    public float? diem_cuoi_ki { get; set; }
    public float? diem_tong_ket { get; set; }
}
