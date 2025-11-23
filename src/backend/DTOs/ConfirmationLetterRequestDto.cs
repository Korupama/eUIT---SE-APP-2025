using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs.ConfirmationLetter
{
    public class ConfirmationLetterRequestDto
    {
        [Required(ErrorMessage = "Vui lòng nhập lý do")]
        public string Purpose { get; set; } = string.Empty;
    }
}