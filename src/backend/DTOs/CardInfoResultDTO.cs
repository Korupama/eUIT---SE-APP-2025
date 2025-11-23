namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from func_get_student_card_info
/// </summary>
public class CardInfoResultDto
{
    public int mssv { get; set; }
    public string ho_ten { get; set; } = string.Empty;
    public int khoa_hoc { get; set; }
    public string nganh_hoc { get; set; } = string.Empty;
    public string? anh_the_url { get; set; }
}
