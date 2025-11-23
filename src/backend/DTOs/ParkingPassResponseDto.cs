namespace eUIT.API.DTOs;

public class ParkingPassResponseDto
{
    public int Id { get; set; }
    public string LicensePlate { get; set; } = string.Empty;
    public string VehicleType { get; set; } = string.Empty;
    public string ExpiryDate { get; set; } = string.Empty;
    public string RegisteredAt { get; set; } = string.Empty;
}