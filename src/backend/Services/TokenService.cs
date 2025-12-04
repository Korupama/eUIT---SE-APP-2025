using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using System.Security.Cryptography;

namespace eUIT.API.Services;

public interface ITokenService
{
    string CreateToken(string userId, string role);
    string CreateAccessToken(string userId, string role, TimeSpan? expiry = null);
    string GenerateRefreshToken();
}

public sealed class TokenService : ITokenService
{
    private readonly IConfiguration _config;

    public TokenService(IConfiguration config)
    {
        _config = config;
    }

    public string CreateToken(string userId, string role)
    {
        return CreateAccessToken(userId, role);
    }

    public string CreateAccessToken(string userId, string role, TimeSpan? expiry = null)
    {
        // 1. Tạo danh sách các "thông tin" (Claims) để đưa vào token
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, userId),
            new Claim(ClaimTypes.Role, role)
        };
        
        // 2. Lấy key từ appsettings.json
        var jwtKey = _config["Jwt:Key"] ?? throw new InvalidOperationException("JWT:Key is not configured");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

        // 3. Tạo "chứng thực ký" bằng thuật toán an toàn
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

        // 4. Mô tả toàn bộ token: thông tin, ngày hết hạn, chứng thực
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.Add(expiry ?? TimeSpan.FromDays(1)), // Default 1 day, or custom expiry
            SigningCredentials = creds,
            Issuer = _config["Jwt:Issuer"],
            Audience = _config["Jwt:Audience"]
        };

        // 5. Tạo token dựa trên bản mô tả
        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);

        // 6. Trả về chuỗi token đã được mã hóa
        return tokenHandler.WriteToken(token);
    }

    public string GenerateRefreshToken()
    {
        // Logic to generate a refresh token
        // This is typically a long random string
        return Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
    }
}