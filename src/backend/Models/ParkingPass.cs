using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("dang_ky_gui_xe")]
public class ParkingPass
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("mssv")]
    public int StudentId { get; set; }

    [Column("license_plate")]
    [StringLength(50)]
    public string LicensePlate { get; set; } = string.Empty;

    [Column("vehicle_type")]
    public string VehicleType { get; set; } = string.Empty;

    [Column("expiry_date")]
    public DateTime ExpiryDate { get; set; }

    [Column("registered_at")]
    public DateTime RegisteredAt { get; set; }
}