﻿namespace eUIT.API.DTOs.ConfirmationLetter
{
    /// <summary>
    /// DTO for Confirmation Letter History Response
    /// </summary>
    public class ConfirmationLetterHistoryDto
    {
        public int SerialNumber { get; set; }
        public string Purpose { get; set; } = string.Empty;
        public string Language { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string ExpiryDate { get; set; } = string.Empty;
        public string RequestedAt { get; set; } = string.Empty;
    }

    /// <summary>
    /// SQL Result mapping for confirmation letter history query
    /// </summary>
    public class ConfirmationLetterHistoryResult
    {
        public int letter_id { get; set; }
        public int mssv { get; set; }
        public string purpose { get; set; } = string.Empty;
        public string language { get; set; } = string.Empty;
        public int serial_number { get; set; }
        public DateTime? expiry_date { get; set; }
        public DateTime requested_at { get; set; }
        public string status { get; set; } = string.Empty;
    }
}