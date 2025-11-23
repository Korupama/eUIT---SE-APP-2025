using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Npgsql;

// DTO namespaces
using eUIT.API.DTOs.ConfirmationLetter;
using eUIT.API.DTOs.LanguageCertificate;
using eUIT.API.DTOs;

// DbContext
using eUIT.API.Data;
// Models
using eUIT.API.Models;

[Authorize]
[ApiController]
[Route("api/service")]
public class ServiceController : ControllerBase
{
    private readonly eUITDbContext _context;
    private readonly IWebHostEnvironment _env;

    public ServiceController(eUITDbContext context, IWebHostEnvironment env)
    {
        _context = context;
        _env = env;
    }

    // =============================
    //      REQUEST CONFIRMATION
    // =============================
    [HttpPost("confirmation-letter")]
    public async Task<ActionResult<ConfirmationLetterResponseDto>> RequestConfirmationLetter(
        [FromBody] ConfirmationLetterRequestDto requestDto)
    {
        // Lấy MSSV từ token
        var (mssv, error) = GetCurrentMssv();
        if (error != null) return error;

        if (!ModelState.IsValid) return BadRequest(ModelState);

        try
        {
            var sql = "SELECT * FROM func_request_confirmation_letter(@p_mssv, @p_purpose)";
            
            var result = await _context.Database
                .SqlQueryRaw<ConfirmationLetterResult>(sql,
                    new NpgsqlParameter("p_mssv", mssv.Value),
                    new NpgsqlParameter("p_purpose", requestDto.Purpose))
                .ToListAsync();

            var record = result.FirstOrDefault();

            if (record == null)
                return StatusCode(500, new { error = "Không nhận được kết quả từ DB." });

            return Ok(new ConfirmationLetterResponseDto
            {
                SerialNumber = record.so_thu_tu,
                ExpiryDate = record.ngay_het_han.ToString("dd/MM/yyyy")
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    // =============================
    //     SUBMIT LANGUAGE CERT
    // =============================
    [HttpPost("language-certificate")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<IActionResult> SubmitLanguageCertificate(
        [FromForm] LanguageCertificateRequestDto requestDto, IFormFile file)
    {
        var (mssv, error) = GetCurrentMssv();
        if (error != null) return error;

        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        if (file == null || file.Length == 0)
            return BadRequest(new { file = "Vui lòng tải lên file chứng chỉ." });

        // Check extension
        var allowed = new[] { ".pdf", ".jpg", ".jpeg", ".png" };
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();

        if (!allowed.Contains(ext))
            return BadRequest(new { error = "File phải là PDF hoặc JPG/PNG." });

        // Generate folder & file name
        string root = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
        string folder = Path.Combine(root, "uploads", "certificates");

        Directory.CreateDirectory(folder);

        string unique = $"{mssv}_{DateTime.UtcNow:yyyyMMdd}_{Guid.NewGuid():N}{ext}";
        string filePath = Path.Combine(folder, unique);

        try
        {
            // Save file
            await using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Call SQL function
            // Call SQL function - chỉ truyền DATE, không truyền TIME
// Call SQL function với MSSV kiểu integer
            string sql = "SELECT func_submit_language_certificate(@mssv, @type, @score, @issue::date, @expiry::date, @path)";

            await _context.Database.ExecuteSqlRawAsync(
                sql,
                new NpgsqlParameter("mssv", mssv.Value), // Không cần ToString(), giữ nguyên integer
                new NpgsqlParameter("type", requestDto.CertificateType),
                new NpgsqlParameter("score", (float)requestDto.Score),
                new NpgsqlParameter("issue", requestDto.IssueDate),
                new NpgsqlParameter("expiry", requestDto.ExpiryDate.HasValue ? (object)requestDto.ExpiryDate.Value : DBNull.Value),
                new NpgsqlParameter("path", $"uploads/certificates/{unique}")
            );

            return Ok(new { message = "Nộp chứng chỉ thành công." });
        }
        catch (PostgresException pgEx)
        {
            if (System.IO.File.Exists(filePath))
                System.IO.File.Delete(filePath);

            // PostgreSQL raise exception
            if (pgEx.SqlState == "P0001")
                return BadRequest(new { error = pgEx.MessageText });

            return StatusCode(500, new { error = $"Lỗi Database: {pgEx.MessageText}" });
        }
        catch (Exception ex)
        {
            if (System.IO.File.Exists(filePath))
                System.IO.File.Delete(filePath);
                
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }
    /// <summary>
    /// GET: api/service/confirmation-letter/history
    /// Lấy lịch sử yêu cầu giấy xác nhận của sinh viên
    /// </summary>
    [HttpGet("confirmation-letter/history")]
    public async Task<ActionResult<IEnumerable<ConfirmationLetterHistoryDto>>> GetConfirmationLetterHistory()
    {
        // Bước 1: Lấy MSSV từ token JWT
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        try
        {
            // Bước 2: Gọi SQL function để lấy lịch sử
            var sql = "SELECT * FROM func_get_confirmation_letter_status(@p_mssv)";
            
            var results = await _context.Database
                .SqlQueryRaw<ConfirmationLetterHistoryResult>(sql, 
                    new NpgsqlParameter("p_mssv", mssv.Value))
                .ToListAsync();

            // Bước 3: Mapping từ SQL result sang DTO
            var history = results.Select(r => new ConfirmationLetterHistoryDto
            {
                SerialNumber = r.serial_number,
                Purpose = r.purpose,
                ExpiryDate = r.expiry_date?.ToString("dd/MM/yyyy") ?? "",
                RequestedAt = r.requested_at.ToString("dd/MM/yyyy HH:mm")
            }).ToList();

            // Bước 4: Trả về kết quả
            return Ok(history);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }
    /// <summary>
    /// GET: api/service/language-certificate/history
    /// Lấy lịch sử nộp chứng chỉ ngoại ngữ của sinh viên
    /// </summary>
    [HttpGet("language-certificate/history")]
    public async Task<ActionResult<IEnumerable<LanguageCertificateHistoryDto>>> GetLanguageCertificateHistory()
    {
        // Bước 1: Lấy MSSV từ token JWT
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        try
        {
            // Bước 2: Gọi SQL function để lấy lịch sử
            var sql = "SELECT * FROM func_get_language_certificate_status(@p_mssv)";
            
            var results = await _context.Database
                .SqlQueryRaw<LanguageCertificateHistoryResult>(sql,
                    new NpgsqlParameter("p_mssv", mssv.Value))
                .ToListAsync();

            // Bước 3: Mapping từ SQL result sang DTO
            var history = results.Select(r => new LanguageCertificateHistoryDto
            {
                Id = r.id,
                CertificateType = r.certificate_type,
                Score = r.score,
                IssueDate = r.issue_date.ToString("dd/MM/yyyy"),
                ExpiryDate = r.expiry_date?.ToString("dd/MM/yyyy"),
                Status = r.status,
                FilePath = r.file_path,
                CreatedAt = r.created_at.ToString("dd/MM/yyyy HH:mm")
            }).ToList();

            // Bước 4: Trả về kết quả
            return Ok(history);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    private class ParkingPassResult
    {
        public int id { get; set; }
        public string license_plate { get; set; } = string.Empty;
        public string vehicle_type { get; set; } = string.Empty;
        public DateTime expiry_date { get; set; }
        public DateTime registered_at { get; set; }
    }

    // =============================
    //      PARKING PASS REGISTRATION
    // =============================
    /// <summary>
    /// Đăng ký vé gửi xe tháng cho sinh viên.
    /// </summary>
    /// <param name="requestDto">Thông tin đăng ký vé xe.</param>
    /// <returns>Thông tin vé đã được tạo.</returns>
    [HttpPost("parking-pass")]
    public async Task<ActionResult<ParkingPassResponseDto>> RegisterParkingPass(
        [FromBody] ParkingPassRequestDto requestDto)
    {
        // Lấy MSSV từ token
        var (mssv, error) = GetCurrentMssv();
        if (error != null) return error;

        // Xác định biển số xe dựa trên loại xe
        string licensePlate;
        if (requestDto.VehicleType == "bicycle")
        {
            licensePlate = mssv.Value.ToString();
        }
        else // motorbike
        {
            if (string.IsNullOrWhiteSpace(requestDto.LicensePlate))
            {
                ModelState.AddModelError(nameof(requestDto.LicensePlate), "Biển số xe là bắt buộc cho xe máy.");
                return BadRequest(ModelState);
            }
            licensePlate = requestDto.LicensePlate;
        }

        try
        {
            var sql = "SELECT * FROM func_register_parking_pass(@p_mssv, @p_license_plate, @p_vehicle_type, @p_registration_months)";

            var result = await _context.Database
                .SqlQueryRaw<ParkingPassResult>(sql,
                    new NpgsqlParameter("p_mssv", mssv.Value),
                    new NpgsqlParameter("p_license_plate", licensePlate),
                    new NpgsqlParameter("p_vehicle_type", requestDto.VehicleType),
                    new NpgsqlParameter("p_registration_months", requestDto.RegistrationMonths))
                .FirstOrDefaultAsync();

            if (result == null)
            {
                return StatusCode(500, new { error = "Không thể đăng ký vé xe. Vui lòng thử lại." });
            }

            var responseDto = new ParkingPassResponseDto
            {
                Id = result.id,
                LicensePlate = result.license_plate,
                VehicleType = result.vehicle_type,
                RegisteredAt = result.registered_at.ToString("dd/MM/yyyy HH:mm"),
                ExpiryDate = result.expiry_date.ToString("dd/MM/yyyy")
            };

            return CreatedAtAction(nameof(RegisterParkingPass), new { id = result.id }, responseDto);
        }
        catch (PostgresException pgEx) when (pgEx.SqlState == "P0001")
        {
            // Bắt lỗi 'P0001' từ hàm SQL và trả về 409 Conflict
            return Conflict(new { error = pgEx.MessageText });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    // =============================
    //        GET CURRENT MSSV
    // =============================
    private (int? mssv, ActionResult? error) GetCurrentMssv()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier);

        if (claim == null)
            return (null, Unauthorized("Không tìm thấy thông tin người dùng."));

        if (!int.TryParse(claim.Value, out int mssv))
            return (null, BadRequest("MSSV không hợp lệ."));

        return (mssv, null);
    }
}
