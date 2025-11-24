using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("personal_events")]
public class PersonalEvent
{
    [Key]
    [Column("event_id")]
    public int EventId { get; set; }

    [Required]
    [Column("mssv")]
    public int Mssv { get; set; }

    [Required]
    [MaxLength(255)]
    [Column("event_name")]
    public string EventName { get; set; } = string.Empty;

    [Required]
    [Column("time")]
    public DateTime Time { get; set; }

    [MaxLength(255)]
    [Column("location")]
    public string? Location { get; set; }

    [Column("description")]
    public string? Description { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
