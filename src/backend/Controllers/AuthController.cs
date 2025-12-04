using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore; 
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;


using System.Data.Common;
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
        var role = (loginRequest.role ?? string.Empty).Trim().ToLower();
        if (role != "student" && role != "lecturer" && role != "admin")
            return BadRequest(new { error = "Invalid role" });

        var userId = loginRequest.userId ?? string.Empty;
        var password = loginRequest.password ?? string.Empty;

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

        if (isAuth)
        {
            if (string.IsNullOrEmpty(loginRequest.userId))
                throw new InvalidOperationException("User ID is required");
            var token = _tokenService.CreateToken(loginRequest.userId, loginRequest.role ?? "student");
            return Ok(new { token = token });
        }
        return Unauthorized(new { message = "Invalid credentials" });
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