﻿﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("confirmation_letters")]
public class ConfirmationLetter
{
    [Key]
    [Column("letter_id")]
    public int LetterId { get; set; }
    
    [Column("mssv")]
    public int Mssv { get; set; }
    
    [Column("purpose")]
    [MaxLength(500)]
    public string Purpose { get; set; } = string.Empty;
    
    [Column("language")]
    [MaxLength(2)]
    public string Language { get; set; } = "vi";
    
    [Column("serial_number")]
    public int SerialNumber { get; set; }
    
    [Column("expiry_date")]
    public DateTime? ExpiryDate { get; set; }
    
    [Column("requested_at")]
    public DateTime RequestedAt { get; set; }
}