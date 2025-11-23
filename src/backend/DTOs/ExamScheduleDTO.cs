namespace eUIT.API.DTOs;

/// <summary>
/// DTO cho lịch thi của sinh viên
/// </summary>
public class ExamScheduleDto
{
    public string MaMonHoc { get; set; } = string.Empty;
    public string TenMonHoc { get; set; } = string.Empty;
    public string MaLop { get; set; } = string.Empty;
    public string? MaGiangVien { get; set; }
    public string? TenGiangVien { get; set; }
    public DateTime NgayThi { get; set; }
    public int CaThi { get; set; }
    public string PhongThi { get; set; } = string.Empty;
    public string? HinhThucThi { get; set; }
    public string GkCk { get; set; } = string.Empty; // "GK" hoặc "CK"
    public int SoTinChi { get; set; }
}

/// <summary>
/// DTO cho response danh sách lịch thi
/// </summary>
public class ExamScheduleResponseDto
{
    public List<ExamScheduleDto> Exams { get; set; } = new List<ExamScheduleDto>();
    public string? Message { get; set; }
}
