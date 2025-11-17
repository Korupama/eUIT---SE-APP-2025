using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Data
{
    public enum RequestStatus
    {
        Pending,
        Processed,
        Canceled,
        Expired
    }

    [Table("ConfirmationLetterRequests")]
    public class ConfirmationLetterRequest
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Required]
        public int StudentId { get; set; }

        [Required]
        [MaxLength(255)]
        public string Purpose { get; set; } = string.Empty;

        [Required]
        public int SerialNumber { get; set; }

        [Required]
        public RequestStatus Status { get; set; } = RequestStatus.Pending;

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        public DateTime ExpiryDate { get; set; }
    }
}
