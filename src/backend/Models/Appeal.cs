using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("appeals")]
public class Appeal
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Required]
    [Column("mssv")]
    public int Mssv { get; set; }

    [Required]
    [MaxLength(20)]
    [Column("course_id")]
    public string CourseId { get; set; } = string.Empty;

    [Required]
    [Column("reason")]
    public string Reason { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    [Column("payment_method")]
    public string PaymentMethod { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    [Column("payment_status")]
    public string PaymentStatus { get; set; } = "pending"; // pending, completed, failed

    [MaxLength(20)]
    [Column("status")]
    public string Status { get; set; } = "pending"; // pending, approved, rejected

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
