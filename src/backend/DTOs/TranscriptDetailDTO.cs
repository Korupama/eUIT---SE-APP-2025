namespace eUIT.API.DTOs;

public class SubjectGradeDetailDto
{
    public string HocKy { get; set; } = string.Empty;
    public string MaMonHoc { get; set; } = string.Empty;
    public string TenMonHoc { get; set; } = string.Empty;
    public int SoTinChi { get; set; }
    public int? TrongSoQuaTrinh { get; set; }
    public int? TrongSoGiuaKi { get; set; }
    public int? TrongSoThucHanh { get; set; }
    public int? TrongSoCuoiKi { get; set; }
    public float? DiemQuaTrinh { get; set; }
    public float? DiemGiuaKi { get; set; }
    public float? DiemThucHanh { get; set; }
    public float? DiemCuoiKi { get; set; }
    public float? DiemTongKet { get; set; }
}

public class SemesterTranscriptDto
{
    public string HocKy { get; set; } = string.Empty;
    public List<SubjectGradeDetailDto> Subjects { get; set; } = new();
    public float? SemesterGpa { get; set; } // Optional per-semester GPA (computed client or server)
}

public class TranscriptOverviewDto
{
    public float OverallGpa { get; set; }
    public int AccumulatedCredits { get; set; }
    public List<SemesterTranscriptDto> Semesters { get; set; } = new();
}
