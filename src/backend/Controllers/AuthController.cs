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
            var token = _tokenService.CreateToken(loginRequest.userId, loginRequest.role);
            return Ok(new { token = token });
        }
        return Unauthorized(new { message = "Invalid credentials" });
    }

    [HttpGet("profile")]
    [Authorize] 
    public IActionResult GetProfile()
    {
        // Lấy thông tin người dùng đã được giải mã từ token
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var role = User.FindFirst(ClaimTypes.Role)?.Value;

        if (userId == null || role == null)
        {
            return Unauthorized();
        }

        return Ok(new { UserId = userId, Role = role });                                                            
    }
}