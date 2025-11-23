using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("parking_passes")]
public class ParkingPass
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("student_id")]
    public int StudentId { get; set; }

    [Column("license_plate")]
    public string LicensePlate { get; set; } = string.Empty;

    [Column("vehicle_type")]
    public string VehicleType { get; set; } = string.Empty;

    [Column("expiry_date")]
    public DateTime ExpiryDate { get; set; }

    [Column("registered_at")]
    public DateTime RegisteredAt { get; set; }
}