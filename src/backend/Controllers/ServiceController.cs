using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using Npgsql;
using System.Security.Claims;
using System.ComponentModel.DataAnnotations;

namespace eUIT.API.Controllers;

// DTO for the request body of the confirmation letter endpoint
public class ConfirmationLetterRequestDto
{
    [Required(ErrorMessage = "Vui lòng điền đầy đủ thông tin")]
    public string Purpose { get; set; } = string.Empty;
}

// DTO for the response of the confirmation letter endpoint
public class ConfirmationLetterResponseDto
{
    public int SerialNumber { get; set; }
    public DateTime ExpiryDate { get; set; }
}

// Public class to map the result from the database function
public class ConfirmationLetterResult
{
    public int so_thu_tu { get; set; }
    public DateTime ngay_het_han { get; set; }
}


[Authorize]
[ApiController]
[Route("api/service")]
public class ServiceController : ControllerBase
{
    private readonly eUITDbContext _context;

    public ServiceController(eUITDbContext context)
    {
        _context = context;
    }

    /// <summary>
    /// Submits a request for a student confirmation letter.
    /// </summary>
    /// <param name="requestDto">The request payload containing the purpose of the letter.</param>
    /// <returns>The serial number for pickup and the expiry date.</returns>
    [HttpPost("confirmation-letter")]
    public async Task<ActionResult<ConfirmationLetterResponseDto>> RequestConfirmationLetter([FromBody] ConfirmationLetterRequestDto requestDto)
    {
        // Pre-condition: Student is logged in. Get student ID (mssv).
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null)
        {
            return errorResult;
        }

        // Exception: Form not complete. Handled by [ApiController] and ModelState.
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Main Flow: System processing
        var mssvParam = new NpgsqlParameter("p_mssv", mssv.Value);
        var purposeParam = new NpgsqlParameter("p_purpose", requestDto.Purpose);

        var sql = "SELECT * FROM func_request_confirmation_letter(@p_mssv, @p_purpose)";
        var result = await _context.Database
            .SqlQueryRaw<ConfirmationLetterResult>(sql, mssvParam, purposeParam)
            .SingleOrDefaultAsync();

        if (result == null)
        {
            return StatusCode(500, "Hệ thống không thể xử lý yêu cầu của bạn.");
        }

        // Post-condition: Return the serial number and expiry date.
        var response = new ConfirmationLetterResponseDto
        {
            SerialNumber = result.so_thu_tu,
            ExpiryDate = result.ngay_het_han
        };

        // In a real-world application, a notification would be sent to the student here.

        return Ok(response);
    }

    /// <summary>
    /// Helper method to get the student ID (mssv) from the authenticated user's claims.
    /// </summary>
    private (int? mssv, ActionResult? errorResult) GetCurrentMssv()
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null)
        {
            return (null, Unauthorized("Không thể xác định người dùng. Vui lòng đăng nhập lại."));
        }

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return (null, BadRequest("Mã số sinh viên trong tài khoản không hợp lệ."));
        }
        return (mssvInt, null);
    }
}
