namespace eUIT.API.DTOs;

public class TotalTuitionDto
{
    public long TongHocPhi { get; set; }
    public long TongDaDong { get; set; }
    public long TongConLai { get; set; }
    public List<TuitionDto> ChiTietHocPhi { get; set; } = new();
}