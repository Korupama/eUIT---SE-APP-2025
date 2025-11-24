namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from func_calculate_gpa
/// </summary>
public class QuickGpaResultDto
{
    public float gpa { get; set; }
    public int so_tin_chi_tich_luy { get; set; } = 0;
}
