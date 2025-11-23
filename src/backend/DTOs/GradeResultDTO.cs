namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from transcript functions
/// </summary>
public class GradeResultDto
{
    public string hoc_ky { get; set; } = string.Empty;
    public string ma_mon_hoc { get; set; } = string.Empty;
    public string ten_mon_hoc { get; set; } = string.Empty;
    public int so_tin_chi { get; set; }
    public float? diem_tong_ket { get; set; }
}
