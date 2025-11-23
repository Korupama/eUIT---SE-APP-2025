namespace eUIT.API.DTOs.LanguageCertificate
{
    /// <summary>
    /// DTO for Language Certificate History Response
    /// </summary>
    public class LanguageCertificateHistoryDto
    {
        public int Id { get; set; }
        public string CertificateType { get; set; } = string.Empty;
        public float Score { get; set; }
        public string IssueDate { get; set; } = string.Empty;
        public string? ExpiryDate { get; set; }
        public string Status { get; set; } = string.Empty;
        public string FilePath { get; set; } = string.Empty;
        public string CreatedAt { get; set; } = string.Empty;
    }

    /// <summary>
    /// SQL Result mapping for language certificate history query
    /// </summary>
    public class LanguageCertificateHistoryResult
    {
        public int id { get; set; }
        public int mssv { get; set; }
        public string certificate_type { get; set; } = string.Empty;
        public float score { get; set; }
        public DateTime issue_date { get; set; }
        public DateTime? expiry_date { get; set; }
        public string file_path { get; set; } = string.Empty;
        public string status { get; set; } = string.Empty;
        public DateTime created_at { get; set; }
    }
}