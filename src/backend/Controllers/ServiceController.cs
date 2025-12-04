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
            var sql = "SELECT * FROM func_request_confirmation_letter(@p_mssv, @p_purpose, @p_language)";
            
            var result = await _context.Database
                .SqlQueryRaw<ConfirmationLetterResult>(sql,
                    new NpgsqlParameter("p_mssv", mssv ?? 0),
                    new NpgsqlParameter("p_purpose", requestDto.Purpose ?? string.Empty),
                    new NpgsqlParameter("p_language", requestDto.Language))
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
                new NpgsqlParameter("mssv", mssv ?? 0),
                new NpgsqlParameter("type", requestDto.CertificateType ?? string.Empty),
                new NpgsqlParameter("score", requestDto.Score),
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
            var sql = "SELECT * FROM func_get_confirmation_letter_history(@p_mssv)";
            
            var results = await _context.Database
                .SqlQueryRaw<ConfirmationLetterHistoryResult>(sql, 
                    new NpgsqlParameter("p_mssv", mssv ?? 0))
                .ToListAsync();

            // Bước 3: Mapping từ SQL result sang DTO
            var history = results.Select(r => new ConfirmationLetterHistoryDto
            {
                SerialNumber = r.serial_number,
                Purpose = r.purpose,
                Language = r.language,
                Status = r.status,
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
                    new NpgsqlParameter("p_mssv", mssv ?? 0))
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
        public int out_id { get; set; }
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
            licensePlate = (mssv ?? 0).ToString();
        }
        else // motorbike
        {
            ModelState.AddModelError(nameof(requestDto.LicensePlate), "Biển số xe là bắt buộc cho xe máy.");
            return BadRequest(ModelState);
        }

        try
        {
            var sql = "SELECT * FROM func_register_parking_pass(@p_mssv, @p_license_plate, @p_vehicle_type, @p_registration_months)";

            var result = await _context.Database
                .SqlQueryRaw<ParkingPassResult>(sql,
                    new NpgsqlParameter("p_mssv", mssv ?? 0),
                    new NpgsqlParameter("p_license_plate", licensePlate ?? string.Empty),
                    new NpgsqlParameter("p_vehicle_type", requestDto.VehicleType ?? string.Empty),
                    new NpgsqlParameter("p_registration_months", requestDto.RegistrationMonths))
                .FirstOrDefaultAsync();

            if (result == null)
            {
                return StatusCode(500, new { error = "Không thể đăng ký vé xe. Vui lòng thử lại." });
            }

            var responseDto = new ParkingPassResponseDto
            {
                Id = result.out_id,
                LicensePlate = result.license_plate,
                VehicleType = result.vehicle_type,
                RegisteredAt = result.registered_at.ToString("dd/MM/yyyy HH:mm"),
                ExpiryDate = result.expiry_date.ToString("dd/MM/yyyy")
            };

            return CreatedAtAction(nameof(RegisterParkingPass), new { id = result.out_id }, responseDto);
        }
        catch (PostgresException pgEx) when (pgEx.SqlState == "P0001")
        {
            // Catch 'P0001' error from the SQL function and return 409 Conflict
            return Conflict(new { error = pgEx.MessageText });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    // =============================
    //      APPEAL (PHÚ C KHẢO)
    // =============================
    /// <summary>
    /// POST: api/service/appeal
    /// Nộp đơn phúc khảo điểm
    /// </summary>
    [HttpPost("appeal")]
    public async Task<ActionResult<AppealResponseDto>> SubmitAppeal([FromBody] AppealRequestDto requestDto)
    {
        var (mssv, error) = GetCurrentMssv();
        if (error != null) return error;

        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        try
        {
            // Kiểm tra thời hạn phúc khảo (ví dụ: trong vòng 7 ngày sau khi công bố điểm)
            var appealDeadline = DateTime.UtcNow.AddDays(-7); // Giả sử deadline là 7 ngày trước
            
            // TODO: Kiểm tra thời gian công bố điểm môn học từ DB
            // Tạm thời bỏ qua check này, có thể implement sau
            
            // Kiểm tra xem đã nộp phúc khảo cho môn này chưa
            var existingAppeal = await _context.Appeals
                .Where(a => a.Mssv == (mssv ?? 0) && a.CourseId == (requestDto.CourseId ?? string.Empty))
                .FirstOrDefaultAsync();

            if (existingAppeal != null)
            {
                return BadRequest(new { error = "Bạn đã nộp đơn phúc khảo cho môn học này rồi." });
            }

            // Xử lý thanh toán (giả lập)
            string paymentStatus = "pending";
            if (requestDto.PaymentMethod == "cash")
            {
                // Thanh toán tiền mặt cần xác nhận sau
                paymentStatus = "pending";
            }
            else
            {
                // Giả lập thanh toán online thành công
                // TODO: Tích hợp payment gateway thực tế
                paymentStatus = "completed";
            }

            // Tạo đơn phúc khảo
            var appeal = new Appeal
            {
                Mssv = mssv ?? 0,
                CourseId = requestDto.CourseId ?? string.Empty,
                Reason = requestDto.Reason ?? string.Empty,
                PaymentMethod = requestDto.PaymentMethod ?? "cash",
                PaymentStatus = paymentStatus,
                Status = paymentStatus == "completed" ? "pending" : "awaiting_payment",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Appeals.Add(appeal);
            await _context.SaveChangesAsync();

            var response = new AppealResponseDto
            {
                Id = appeal.Id,
                CourseId = appeal.CourseId,
                Reason = appeal.Reason,
                PaymentMethod = appeal.PaymentMethod,
                PaymentStatus = appeal.PaymentStatus,
                Status = appeal.Status,
                CreatedAt = appeal.CreatedAt.ToString("dd/MM/yyyy HH:mm"),
                Message = paymentStatus == "completed" 
                    ? "Nộp đơn phúc khảo thành công. Đơn của bạn đang được xử lý."
                    : "Đơn phúc khảo đã được tạo. Vui lòng hoàn thành thanh toán để đơn được xử lý."
            };

            return Ok(response);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    // =============================
    //      TUITION EXTENSION
    // =============================
    /// <summary>
    /// POST: api/service/tuition-extension
    /// Đăng ký gia hạn học phí
    /// </summary>
    [HttpPost("tuition-extension")]
    [RequestSizeLimit(10 * 1024 * 1024)] // Max 10MB
    public async Task<ActionResult<TuitionExtensionResponseDto>> RequestTuitionExtension(
        [FromForm] TuitionExtensionRequestDto requestDto)
    {
        var (mssv, error) = GetCurrentMssv();
        if (error != null) return error;

        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        try
        {
            // Kiểm tra thời hạn đăng ký gia hạn (ví dụ: trước 15 ngày so với hạn đóng học phí)
            var extensionDeadline = new DateTime(2025, 12, 15); // TODO: Lấy từ DB
            if (DateTime.UtcNow > extensionDeadline)
            {
                return BadRequest(new { error = "Đã hết thời hạn đăng ký gia hạn học phí." });
            }

            // Kiểm tra thời gian gia hạn mong muốn có hợp lệ không
            var maxExtensionDate = extensionDeadline.AddMonths(2); // Tối đa gia hạn 2 tháng
            if (requestDto.DesiredTime > maxExtensionDate)
            {
                return BadRequest(new { error = "Thời gian gia hạn không hợp lệ. Vượt quá quy định cho phép." });
            }

            if (requestDto.DesiredTime <= DateTime.UtcNow)
            {
                return BadRequest(new { error = "Thời gian gia hạn phải sau thời điểm hiện tại." });
            }

            // Xử lý file minh chứng nếu có
            string? filePath = null;
            if (requestDto.SupportingDocs != null && requestDto.SupportingDocs.Length > 0)
            {
                var allowed = new[] { ".pdf", ".jpg", ".jpeg", ".png" };
                var ext = Path.GetExtension(requestDto.SupportingDocs.FileName).ToLowerInvariant();

                if (!allowed.Contains(ext))
                    return BadRequest(new { error = "File phải là PDF hoặc JPG/PNG." });

                string root = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
                string folder = Path.Combine(root, "uploads", "tuition-extensions");
                Directory.CreateDirectory(folder);

                string unique = $"{mssv}_{DateTime.UtcNow:yyyyMMdd}_{Guid.NewGuid():N}{ext}";
                filePath = Path.Combine(folder, unique);

                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await requestDto.SupportingDocs.CopyToAsync(stream);
                }

                filePath = $"uploads/tuition-extensions/{unique}";
            }

            // Tạo đơn gia hạn
            var extension = new TuitionExtension
            {
                Mssv = mssv ?? 0,
                Reason = requestDto.Reason ?? string.Empty,
                DesiredTime = requestDto.DesiredTime,
                SupportingDocs = filePath,
                Status = "pending",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.TuitionExtensions.Add(extension);
            await _context.SaveChangesAsync();

            var response = new TuitionExtensionResponseDto
            {
                Id = extension.Id,
                Reason = extension.Reason,
                DesiredTime = extension.DesiredTime.ToString("dd/MM/yyyy"),
                SupportingDocs = extension.SupportingDocs,
                Status = extension.Status,
                CreatedAt = extension.CreatedAt.ToString("dd/MM/yyyy HH:mm"),
                UpdatedAt = extension.UpdatedAt.ToString("dd/MM/yyyy HH:mm"),
                Message = "Đăng ký gia hạn học phí thành công. Đơn của bạn đang chờ Phòng KHTC xét duyệt."
            };

            return Ok(response);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// PUT: api/service/tuition-extension/{request_id}
    /// Chỉnh sửa đơn gia hạn học phí (chỉ khi chưa được duyệt)
    /// </summary>
    [HttpPut("tuition-extension/{request_id}")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<ActionResult<TuitionExtensionResponseDto>> UpdateTuitionExtension(
        int request_id,
        [FromForm] TuitionExtensionUpdateDto requestDto)
    {
        var (mssv, error) = GetCurrentMssv();
        if (error != null) return error;

        try
        {
            // Tìm đơn gia hạn
            var extension = await _context.TuitionExtensions
                .FirstOrDefaultAsync(e => e.Id == request_id && e.Mssv == (mssv ?? 0));

            if (extension == null)
            {
                return NotFound(new { error = "Không tìm thấy đơn gia hạn hoặc bạn không có quyền chỉnh sửa." });
            }

            // Chỉ cho phép chỉnh sửa nếu đơn chưa được duyệt
            if (extension.Status != "pending")
            {
                return BadRequest(new 
                { 
                    error = $"Không thể chỉnh sửa đơn gia hạn đã được {(extension.Status == "approved" ? "phê duyệt" : "từ chối")}." 
                });
            }

            // Cập nhật các trường nếu được cung cấp
            if (!string.IsNullOrEmpty(requestDto.Reason))
            {
                extension.Reason = requestDto.Reason;
            }

            if (requestDto.DesiredTime.HasValue)
            {
                // Kiểm tra thời gian gia hạn hợp lệ
                var extensionDeadline = new DateTime(2025, 12, 15);
                var maxExtensionDate = extensionDeadline.AddMonths(2);
                
                if (requestDto.DesiredTime.Value > maxExtensionDate)
                {
                    return BadRequest(new { error = "Thời gian gia hạn không hợp lệ. Vượt quá quy định cho phép." });
                }

                if (requestDto.DesiredTime.Value <= DateTime.UtcNow)
                {
                    return BadRequest(new { error = "Thời gian gia hạn phải sau thời điểm hiện tại." });
                }

                extension.DesiredTime = requestDto.DesiredTime.Value;
            }

            // Xử lý file minh chứng mới nếu có
            if (requestDto.SupportingDocs != null && requestDto.SupportingDocs.Length > 0)
            {
                var allowed = new[] { ".pdf", ".jpg", ".jpeg", ".png" };
                var ext = Path.GetExtension(requestDto.SupportingDocs.FileName).ToLowerInvariant();

                if (!allowed.Contains(ext))
                    return BadRequest(new { error = "File phải là PDF hoặc JPG/PNG." });

                // Xóa file cũ nếu có
                if (!string.IsNullOrEmpty(extension.SupportingDocs))
                {
                    string root = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
                    string oldFilePath = Path.Combine(root, extension.SupportingDocs);
                    if (System.IO.File.Exists(oldFilePath))
                    {
                        System.IO.File.Delete(oldFilePath);
                    }
                }

                // Lưu file mới
                string rootPath = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
                string folder = Path.Combine(rootPath, "uploads", "tuition-extensions");
                Directory.CreateDirectory(folder);

                string unique = $"{mssv}_{DateTime.UtcNow:yyyyMMdd}_{Guid.NewGuid():N}{ext}";
                string filePath = Path.Combine(folder, unique);

                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await requestDto.SupportingDocs.CopyToAsync(stream);
                }

                extension.SupportingDocs = $"uploads/tuition-extensions/{unique}";
            }

            extension.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var response = new TuitionExtensionResponseDto
            {
                Id = extension.Id,
                Reason = extension.Reason,
                DesiredTime = extension.DesiredTime.ToString("dd/MM/yyyy"),
                SupportingDocs = extension.SupportingDocs,
                Status = extension.Status,
                CreatedAt = extension.CreatedAt.ToString("dd/MM/yyyy HH:mm"),
                UpdatedAt = extension.UpdatedAt.ToString("dd/MM/yyyy HH:mm"),
                Message = "Cập nhật đơn gia hạn thành công."
            };

            return Ok(response);
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
