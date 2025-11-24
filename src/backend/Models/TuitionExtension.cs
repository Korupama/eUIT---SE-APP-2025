using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("tuition_extensions")]
public class TuitionExtension
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Required]
    [Column("mssv")]
    public int Mssv { get; set; }

    [Required]
    [Column("reason")]
    public string Reason { get; set; } = string.Empty;

    [Required]
    [Column("desired_time")]
    public DateTime DesiredTime { get; set; }

    [Column("supporting_docs")]
    public string? SupportingDocs { get; set; }

    [Required]
    [MaxLength(20)]
    [Column("status")]
    public string Status { get; set; } = "pending"; // pending, approved, rejected

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
