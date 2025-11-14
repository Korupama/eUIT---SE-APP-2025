namespace eUIT.API.DTOs;

public class GradeDto
{
    public string HocKy { get; set; } = string.Empty;
    public string MaMonHoc { get; set; } = string.Empty;
    public string TenMonHoc { get; set; } = string.Empty;
    public int SoTinChi { get; set; }
    public float? DiemTongKet { get; set; }
}

public class GradeListResponseDto
{
    public List<GradeDto> Grades { get; set; } = new();
    public string? Message { get; set; }
}
