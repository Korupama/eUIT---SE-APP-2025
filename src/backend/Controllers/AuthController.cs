using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore; 
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using eUIT.API.DTOs;
using eUIT.API.Data;
using eUIT.API.Services;

namespace eUIT.API.Controllers;

[ApiController]
[Route("api/[controller]")] // Đường dẫn sẽ là /api/auth
public class AuthController : ControllerBase
{
    private readonly eUITDbContext _context;
    private readonly ITokenService _tokenService;

    public AuthController(eUITDbContext context, ITokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto loginRequest)
    {
        // Kiểm tra input cơ bản
        var role = loginRequest.role.Trim().ToLower();
        if (role != "student" && role != "lecturer" && role != "admin")
            return BadRequest(new { error = "Invalid role" });

        var userId = loginRequest.userId;
        var password = loginRequest.password;

        // Sử dụng kết nối ADO.NET có tham số để tránh SQL injection và để ép kiểu enum bên phía Postgres
        await using var connection = _context.Database.GetDbConnection();
        await connection.OpenAsync();
        await using var cmd = connection.CreateCommand();
        cmd.CommandText = "SELECT auth_authenticate(@role::auth_user_role, @userId, @password)";

        var pRole = cmd.CreateParameter();
        pRole.ParameterName = "role";
        pRole.Value = role;
        cmd.Parameters.Add(pRole);

        var pUser = cmd.CreateParameter();
        pUser.ParameterName = "userId";
        pUser.Value = userId;
        cmd.Parameters.Add(pUser);

        var pPass = cmd.CreateParameter();
        pPass.ParameterName = "password";
        pPass.Value = password;
        cmd.Parameters.Add(pPass);

        var scalar = await cmd.ExecuteScalarAsync();
        var isAuth = scalar is bool b && b;

        if (!isAuth)
            return Unauthorized(new { message = "Invalid credentials" });

        // Tạo access token (ngắn hạn)
        var accessToken = _tokenService.CreateAccessToken(userId, role, TimeSpan.FromMinutes(15)); // 15 phút
        
        // Tạo refresh token (dài hạn)
        var refreshTokenValue = _tokenService.GenerateRefreshToken();
        var refreshTokenHash = refreshTokenValue; // Trong thực tế nên hash, nhưng để đơn giản
        
        // Lưu refresh token vào database
        await using var saveCmd = connection.CreateCommand();
        saveCmd.CommandText = @"
            INSERT INTO auth_refresh_tokens (user_role, user_id, token_hash, expires_at)
            VALUES (@role::auth_user_role, @userId, @tokenHash, @expiresAt)";
        
        var pRoleSave = saveCmd.CreateParameter();
        pRoleSave.ParameterName = "role";
        pRoleSave.Value = role;
        saveCmd.Parameters.Add(pRoleSave);
        
        var pUserIdSave = saveCmd.CreateParameter();
        pUserIdSave.ParameterName = "userId";
        pUserIdSave.Value = userId;
        saveCmd.Parameters.Add(pUserIdSave);
        
        var pTokenHash = saveCmd.CreateParameter();
        pTokenHash.ParameterName = "tokenHash";
        pTokenHash.Value = refreshTokenHash;
        saveCmd.Parameters.Add(pTokenHash);
        
        var pExpiresAt = saveCmd.CreateParameter();
        pExpiresAt.ParameterName = "expiresAt";
        pExpiresAt.Value = DateTime.UtcNow.AddDays(30);
        saveCmd.Parameters.Add(pExpiresAt);
        
        await saveCmd.ExecuteNonQueryAsync();

        return Ok(new LoginResponseDto
        {
            AccessToken = accessToken,
            RefreshToken = refreshTokenValue
        });
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDto refreshRequest)
    {
        var refreshToken = refreshRequest.RefreshToken;
        
        // Validate refresh token from database
        await using var connection = _context.Database.GetDbConnection();
        await connection.OpenAsync();
        await using var cmd = connection.CreateCommand();
        cmd.CommandText = @"
            SELECT user_role, user_id 
            FROM auth_refresh_tokens 
            WHERE token_hash = @tokenHash 
              AND expires_at > NOW() 
              AND revoked = false";
        
        var pToken = cmd.CreateParameter();
        pToken.ParameterName = "tokenHash";
        pToken.Value = refreshToken;
        cmd.Parameters.Add(pToken);
        
        await using var reader = await cmd.ExecuteReaderAsync();
        if (!await reader.ReadAsync())
        {
            return Unauthorized(new { message = "Invalid or expired refresh token" });
        }
        
        var role = reader.GetString(0);
        var userId = reader.GetString(1);
        
        // Generate new access token
        var newAccessToken = _tokenService.CreateAccessToken(userId, role, TimeSpan.FromMinutes(15));
        
        // Optionally, rotate refresh token (create new one and revoke old)
        var newRefreshToken = _tokenService.GenerateRefreshToken();
        
        // Update database: revoke old token and insert new one
        await using var updateCmd = connection.CreateCommand();
        updateCmd.CommandText = @"
            UPDATE auth_refresh_tokens SET revoked = true WHERE token_hash = @oldToken;
            INSERT INTO auth_refresh_tokens (user_role, user_id, token_hash, expires_at)
            VALUES (@role::auth_user_role, @userId, @newToken, @expiresAt)";
        
        var pOldToken = updateCmd.CreateParameter();
        pOldToken.ParameterName = "oldToken";
        pOldToken.Value = refreshToken;
        updateCmd.Parameters.Add(pOldToken);
        
        var pRoleUpdate = updateCmd.CreateParameter();
        pRoleUpdate.ParameterName = "role";
        pRoleUpdate.Value = role;
        updateCmd.Parameters.Add(pRoleUpdate);
        
        var pUserIdUpdate = updateCmd.CreateParameter();
        pUserIdUpdate.ParameterName = "userId";
        pUserIdUpdate.Value = userId;
        updateCmd.Parameters.Add(pUserIdUpdate);
        
        var pNewToken = updateCmd.CreateParameter();
        pNewToken.ParameterName = "newToken";
        pNewToken.Value = newRefreshToken;
        updateCmd.Parameters.Add(pNewToken);
        
        var pExpiresAtUpdate = updateCmd.CreateParameter();
        pExpiresAtUpdate.ParameterName = "expiresAt";
        pExpiresAtUpdate.Value = DateTime.UtcNow.AddDays(30);
        updateCmd.Parameters.Add(pExpiresAtUpdate);
        
        await updateCmd.ExecuteNonQueryAsync();
        
        return Ok(new LoginResponseDto
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken
        });
    }

    [HttpGet("profile")]
    [Authorize] 
    public async Task<ActionResult<StudentProfileDto>> GetProfile()
    {
        // Lấy thông tin người dùng đã được giải mã từ token
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var role = User.FindFirst(ClaimTypes.Role)?.Value;

        if (userId == null || role == null)
        {
            return Unauthorized();
        }

        // Chỉ hỗ trợ sinh viên
        if (role.ToLower() != "student")
        {
            return BadRequest(new { error = "Only students can access this endpoint" });
        }

        if (!int.TryParse(userId, out int mssv))
        {
            return BadRequest(new { error = "Invalid student ID" });
        }

        // Lấy thông tin sinh viên từ database
        var sinhVien = await _context.SinhViens
            .Where(sv => sv.Mssv == mssv)
            .FirstOrDefaultAsync();

        if (sinhVien == null)
        {
            return NotFound(new { error = "Student not found" });
        }

        // Map sang DTO
        var profile = new StudentProfileDto
        {
            Mssv = sinhVien.Mssv,
            HoTen = sinhVien.HoTen,
            NgaySinh = sinhVien.NgaySinh,
            NganhHoc = sinhVien.NganhHoc,
            KhoaHoc = sinhVien.KhoaHoc,
            LopSinhHoat = sinhVien.LopSinhHoat,
            NoiSinh = sinhVien.NoiSinh,
            Cccd = sinhVien.Cccd,
            NgayCapCccd = sinhVien.NgayCapCccd,
            NoiCapCccd = sinhVien.NoiCapCccd,
            DanToc = sinhVien.DanToc,
            TonGiao = sinhVien.TonGiao,
            SoDienThoai = sinhVien.SoDienThoai,
            DiaChiThuongTru = sinhVien.DiaChiThuongTru,
            TinhThanhPho = sinhVien.TinhThanhPho,
            PhuongXa = sinhVien.PhuongXa,
            QuaTrinhHocTapCongTac = sinhVien.QuaTrinhHocTapCongTac,
            ThanhTich = sinhVien.ThanhTich,
            EmailCaNhan = sinhVien.EmailCaNhan,
            MaNganHang = sinhVien.MaNganHang,
            TenNganHang = sinhVien.TenNganHang,
            SoTaiKhoan = sinhVien.SoTaiKhoan,
            ChiNhanh = sinhVien.ChiNhanh,
            HoTenCha = sinhVien.HoTenCha,
            QuocTichCha = sinhVien.QuocTichCha,
            DanTocCha = sinhVien.DanTocCha,
            TonGiaoCha = sinhVien.TonGiaoCha,
            SdtCha = sinhVien.SdtCha,
            EmailCha = sinhVien.EmailCha,
            DiaChiThuongTruCha = sinhVien.DiaChiThuongTruCha,
            CongViecCha = sinhVien.CongViecCha,
            HoTenMe = sinhVien.HoTenMe,
            QuocTichMe = sinhVien.QuocTichMe,
            DanTocMe = sinhVien.DanTocMe,
            TonGiaoMe = sinhVien.TonGiaoMe,
            SdtMe = sinhVien.SdtMe,
            EmailMe = sinhVien.EmailMe,
            DiaChiThuongTruMe = sinhVien.DiaChiThuongTruMe,
            CongViecMe = sinhVien.CongViecMe,
            HoTenNgh = sinhVien.HoTenNgh,
            QuocTichNgh = sinhVien.QuocTichNgh,
            DanTocNgh = sinhVien.DanTocNgh,
            TonGiaoNgh = sinhVien.TonGiaoNgh,
            SdtNgh = sinhVien.SdtNgh,
            EmailNgh = sinhVien.EmailNgh,
            DiaChiThuongTruNgh = sinhVien.DiaChiThuongTruNgh,
            CongViecNgh = sinhVien.CongViecNgh,
            ThongTinNguoiCanBaoTin = sinhVien.ThongTinNguoiCanBaoTin,
            SoDienThoaiBaoTin = sinhVien.SoDienThoaiBaoTin,
            AnhTheUrl = sinhVien.AnhTheUrl
        };

        return Ok(profile);                                                            
    }
}