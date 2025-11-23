namespace eUIT.API.DTOs;

/// <summary>
/// Internal DTO for mapping database query results from func_get_student_training_scores
/// </summary>
public class TrainingScoreResultDto
{
    public string hoc_ky { get; set; } = string.Empty;
    public int tong_diem { get; set; }
    public string xep_loai { get; set; } = string.Empty;
    public string tinh_trang { get; set; } = string.Empty;
}
