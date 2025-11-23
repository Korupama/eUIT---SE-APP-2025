namespace eUIT.API.DTOs.ConfirmationLetter
{
    public class ConfirmationLetterResponseDto
    {
        public int SerialNumber { get; set; }
        public string ExpiryDate { get; set; } = string.Empty;
    }
}