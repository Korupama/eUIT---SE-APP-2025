using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs;

public class QuickGpaDto
{
    public float Gpa { get; set; }

    public int SoTinChiTichLuy { get; set; } = 0;
}