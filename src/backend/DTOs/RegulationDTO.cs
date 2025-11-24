namespace eUIT.API.DTOs;

public class RegulationDto
{
    public string TenVanBan { get; set; } = string.Empty;
    public string UrlVanBan { get; set; } = string.Empty;
    public DateTime? NgayBanHanh { get; set; }
}

public class RegulationListResponseDto
{
    public List<RegulationDto> Regulations { get; set; } = new();
    public string? Message { get; set; }
}
