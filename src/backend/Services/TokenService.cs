using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace eUIT.API.Services;

public interface ITokenService
{
    string CreateToken(string userID, string role);
}
public class TokenService : ITokenService
{
    private readonly IConfiguration _config;

    public TokenService(IConfiguration config)
    {
        _config = config;
    }

    public string CreateToken(string userID, string role)
    {
        // 1. Tạo danh sách các "thông tin" (Claims) để đưa vào token
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, userID),
            new Claim(ClaimTypes.Role, role)
        };
        // 2. Lấy key từ appsettings.json
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));

        // 3. Tạo "chứng thực ký" bằng thuật toán an toàn
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

        // 4. Mô tả toàn bộ token: thông tin, ngày hết hạn, chứng thực
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.Now.AddDays(1), // Token sẽ hết hạn sau 1 ngày
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

}