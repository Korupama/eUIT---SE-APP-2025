﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("language_certificates")]
public class LanguageCertificate
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("mssv")]
    public int Mssv { get; set; }

    [Column("certificate_type")]
    public string CertificateType { get; set; } = string.Empty;

    [Column("score")]
    public float Score { get; set; }

    [Column("issue_date")]
    public DateTime IssueDate { get; set; }

    [Column("expiry_date")]
    public DateTime? ExpiryDate { get; set; }

    [Column("file_path")]
    public string FilePath { get; set; } = string.Empty;

    [Column("status")]
    public string Status { get; set; } = string.Empty;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}