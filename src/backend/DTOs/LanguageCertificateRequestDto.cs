using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;

namespace eUIT.API.DTOs.LanguageCertificate
{
    public class LanguageCertificateRequestDto
    {
        [Required(ErrorMessage = "Vui lòng chọn loại chứng chỉ")]
        [FromForm(Name = "certificate_type")]
        public string CertificateType { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng nhập điểm số")]
        [FromForm(Name = "score")]
        public float Score { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập ngày cấp")]
        [FromForm(Name = "issue_date")]
        public DateTime IssueDate { get; set; }

        [FromForm(Name = "expiry_date")]
        public DateTime? ExpiryDate { get; set; }
    }
}