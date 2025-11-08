using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.IdentityModel.Tokens;

// =================================================================================
// DTOs (Data Transfer Objects)
// =================================================================================

namespace eUIT.API.DTOs
{
    // DTO cho kết quả trả về khi đăng nhập thành công
    public class LoginResponseDto
    {
        public string AccessToken { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
    }

    // DTO cho yêu cầu làm mới token
    public class RefreshTokenRequestDto
    {
        public string RefreshToken { get; set; } = string.Empty;
    }
}
