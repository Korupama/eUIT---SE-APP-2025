namespace eUIT.API.DTOs;

/// <summary>
/// DTO cho một buổi học trong thời khóa biểu
/// </summary>
public class ScheduleClassDto
{
    public string HocKy { get; set; } = string.Empty;
    public string MaMonHoc { get; set; } = string.Empty;
    public string TenMonHoc { get; set; } = string.Empty;
    public string MaLop { get; set; } = string.Empty;
    public int SoTinChi { get; set; }
    public string MaGiangVien { get; set; } = string.Empty;
    public string TenGiangVien { get; set; } = string.Empty;
    public string Thu { get; set; } = string.Empty;
    public int? TietBatDau { get; set; }
    public int? TietKetThuc { get; set; }
    public int? CachTuan { get; set; }
    public DateTime? NgayBatDau { get; set; }
    public DateTime? NgayKetThuc { get; set; }
    public string PhongHoc { get; set; } = string.Empty;
    public int? SiSo { get; set; }
    public string HinhThucGiangDay { get; set; } = string.Empty;
    public string? GhiChu { get; set; }
}

/// <summary>
/// DTO cho danh sách lịch học với các phương thức hiển thị khác nhau
/// </summary>
public class ScheduleResponseDto
{
    public List<ScheduleClassDto> Classes { get; set; } = new List<ScheduleClassDto>();
    public string? Message { get; set; }
}
