using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

public class NewsDTO
{
    public string TieuDe { get; set; } = string.Empty;
    public string URL { get; set; } = string.Empty;
    public DateTime NgayDang { get; set; }
}