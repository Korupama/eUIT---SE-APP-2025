﻿using System.ComponentModel.DataAnnotations;

namespace eUIT.API.DTOs.ConfirmationLetter
{
    public class ConfirmationLetterRequestDto
    {
        [Required(ErrorMessage = "Vui lòng nhập lý do")]
        public string Purpose { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng chọn ngôn ngữ")]
        [RegularExpression("^(vi|en)$", ErrorMessage = "Ngôn ngữ phải là 'vi' hoặc 'en'")]
        public string Language { get; set; } = "vi"; // Default to Vietnamese
    }
}