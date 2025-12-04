﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;
using eUIT.API.Services;
using System.Security.Claims;

namespace eUIT.API.Controllers;

/// <summary>
/// Lecturer Controller - Các endpoint dành cho Giảng viên
/// Quản lý lớp học, điểm số, phúc khảo, và tài liệu giảng dạy
/// Rewritten to match REAL PostgreSQL schema
/// </summary>
[Authorize(Roles = "lecturer")]
[ApiController]
[Route("api/lecturer")]
public sealed class LecturerController : ControllerBase
{
    private readonly eUITDbContext _context;
    private readonly INotificationClient _notificationClient;
    private readonly ILogger<LecturerController> _logger;

    public LecturerController(
        eUITDbContext context,
        INotificationClient notificationClient,
        ILogger<LecturerController> logger)
    {
        _context = context;
        _notificationClient = notificationClient;
        _logger = logger;
    }

    #region Helper Methods

    private (string? LecturerId, UnauthorizedObjectResult? ErrorResult) GetCurrentLecturerId()
    {
        var lecturerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(lecturerId))
            return (null, Unauthorized(new { error = "Lecturer ID not found in token" }));
        return (lecturerId, null);
    }

    #endregion

    #region Profile Management

    /// <summary>
    /// GET /api/lecturer/profile - Lấy thông tin hồ sơ giảng viên
    /// </summary>
    [HttpGet("profile")]
    public async Task<ActionResult<LecturerProfileDto>> GetProfile()
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var profile = await _context.Database
                .SqlQueryRaw<LecturerProfileDto>(
                    "SELECT * FROM func_get_lecturer_profile({0})",
                    lecturerId)
                .FirstOrDefaultAsync();

            if (profile == null)
                return NotFound(new { error = "Profile not found" });

            return Ok(profile);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting lecturer profile");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// PUT /api/lecturer/profile - Cập nhật thông tin cá nhân
    /// </summary>
    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateLecturerProfileDto request)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            await _context.Database
                .ExecuteSqlRawAsync(
                    "SELECT func_update_lecturer_profile({0}, {1}, {2})",
                    lecturerId,
                    request.Phone ?? "",
                    request.Address ?? "");

            return Ok(new { message = "Profile updated successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating lecturer profile");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion

    #region Course Management

    /// <summary>
    /// GET /api/lecturer/courses - Lấy danh sách các môn/lớp giảng viên đảm nhiệm
    /// </summary>
    [HttpGet("courses")]
    public async Task<ActionResult<IEnumerable<LecturerCourseDto>>> GetCourses(
        [FromQuery] string? semester = null)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var courses = await _context.Database
                .SqlQueryRaw<LecturerCourseDto>(
                    "SELECT * FROM func_get_lecturer_courses({0}, {1})",
                    lecturerId,
                    semester ?? "")
                .ToListAsync();

            return Ok(courses);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting lecturer courses");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/courses/{classCode} - Lấy chi tiết thông tin 1 lớp
    /// </summary>
    [HttpGet("courses/{classCode}")]
    public async Task<ActionResult<LecturerCourseDetailDto>> GetCourseDetail(string classCode)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var courseDetail = await _context.Database
                .SqlQueryRaw<LecturerCourseDetailDto>(
                    "SELECT * FROM func_get_lecturer_course_detail({0}, {1})",
                    lecturerId,
                    classCode)
                .FirstOrDefaultAsync();

            if (courseDetail == null)
                return NotFound(new { error = "Course not found or access denied" });

            return Ok(courseDetail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting course detail");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/schedule - Lấy lịch dạy
    /// </summary>
    [HttpGet("schedule")]
    public async Task<ActionResult<IEnumerable<LecturerScheduleDto>>> GetSchedule(
        [FromQuery] string? semester = null,
        [FromQuery] DateTime? startDate = null,
        [FromQuery] DateTime? endDate = null)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var schedule = await _context.Database
                .SqlQueryRaw<LecturerScheduleDto>(
                    "SELECT * FROM func_get_lecturer_schedule({0}, {1}, {2}, {3})",
                    lecturerId,
                    semester ?? "",
                    startDate?.ToUniversalTime() ?? DateTime.UtcNow,
                    endDate?.ToUniversalTime() ?? DateTime.UtcNow.AddDays(7))
                .ToListAsync();

            return Ok(schedule);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting lecturer schedule");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion

    #region Grade Management

    /// <summary>
    /// GET /api/lecturer/grades - Tra cứu điểm học tập của sinh viên lớp mình dạy
    /// </summary>
    [HttpGet("grades")]
    public async Task<ActionResult<IEnumerable<LecturerGradeViewDto>>> GetGrades(
        [FromQuery] string classCode)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (string.IsNullOrEmpty(classCode))
            return BadRequest(new { error = "Class code is required" });

        try
        {
            var grades = await _context.Database
                .SqlQueryRaw<LecturerGradeViewDto>(
                    "SELECT * FROM func_get_lecturer_class_grades({0}, {1})",
                    lecturerId,
                    classCode)
                .ToListAsync();

            return Ok(grades);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting class grades");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/grades/{mssv} - Xem chi tiết bảng điểm của 1 sinh viên
    /// </summary>
    [HttpGet("grades/{mssv}")]
    public async Task<ActionResult<StudentGradeDetailDto>> GetStudentGrade(
        int mssv,
        [FromQuery] string classCode)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (string.IsNullOrEmpty(classCode))
            return BadRequest(new { error = "Class code is required" });

        try
        {
            var gradeDetail = await _context.Database
                .SqlQueryRaw<StudentGradeDetailDto>(
                    "SELECT * FROM func_get_lecturer_student_grade({0}, {1}, {2})",
                    lecturerId,
                    mssv,
                    classCode)
                .FirstOrDefaultAsync();

            if (gradeDetail == null)
                return NotFound(new { error = "Student grade not found or access denied" });

            return Ok(gradeDetail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting student grade");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// PUT /api/lecturer/grades/{mssv} - Nhập/chỉnh sửa điểm
    /// </summary>
    [HttpPut("grades/{mssv}")]
    public async Task<IActionResult> UpdateStudentGrade(
        int mssv,
        [FromBody] LecturerUpdateGradeDto request)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (string.IsNullOrEmpty(request.MaLop))
            return BadRequest(new { error = "Class code is required" });

        try
        {
            var result = await _context.Database
                .SqlQueryRaw<UpdateGradeResultDto>(
                    @"SELECT * FROM func_lecturer_update_grade({0}, {1}, {2}, {3}, {4}, {5}, {6})",
                    lecturerId,
                    mssv,
                    request.MaLop,
                    request.DiemQuaTrinh,
                    request.DiemGiuaKy,
                    request.DiemThucHanh,
                    request.DiemCuoiKy)
                .FirstOrDefaultAsync();

            if (result == null || !result.Success)
                return BadRequest(new { error = result?.Message ?? "Failed to update grade" });

            // Notify student
            try
            {
                await _notificationClient.NotifyKetQuaHocTapAsync(
                    mssv.ToString(),
                    new KetQuaHocTapNotification(
                        MaMonHoc: result.MaMonHoc ?? "",
                        TenMonHoc: result.TenMonHoc ?? "",
                        MaLopHocPhan: request.MaLop,
                        DiemQuaTrinh: request.DiemQuaTrinh,
                        DiemGiuaKy: request.DiemGiuaKy,
                        DiemCuoiKy: request.DiemCuoiKy,
                        DiemTongKet: result.DiemTongKet,
                        DiemChu: result.DiemChu,
                        HocKy: result.HocKy ?? "",
                        NamHoc: ""
                    ));
            }
            catch (Exception notifyEx)
            {
                _logger.LogWarning(notifyEx, "Failed to send notification");
            }

            _logger.LogInformation(
                "Lecturer {LecturerId} updated grade for student {Mssv} in class {ClassCode}",
                lecturerId, mssv, request.MaLop);

            return Ok(new { message = "Grade updated successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating student grade");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion

    #region Exam Management

    /// <summary>
    /// GET /api/lecturer/exams - Xem danh sách lịch thi các lớp mình phụ trách
    /// </summary>
    [HttpGet("exams")]
    public async Task<ActionResult<IEnumerable<LecturerExamDto>>> GetExams(
        [FromQuery] string? semester = null,
        [FromQuery] string? examType = null)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var exams = await _context.Database
                .SqlQueryRaw<LecturerExamDto>(
                    "SELECT * FROM func_get_lecturer_exams({0}, {1}, {2})",
                    lecturerId,
                    semester ?? "",
                    examType ?? "")
                .ToListAsync();

            return Ok(exams);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting lecturer exams");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/exams/{maLop} - Xem chi tiết lịch thi của lớp
    /// </summary>
    [HttpGet("exams/{maLop}")]
    public async Task<ActionResult<LecturerExamDetailDto>> GetExamDetail(string maLop)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var examDetail = await _context.Database
                .SqlQueryRaw<LecturerExamDetailDto>(
                    "SELECT * FROM func_get_lecturer_exam_detail({0}, {1})",
                    lecturerId,
                    maLop)
                .FirstOrDefaultAsync();

            if (examDetail == null)
                return NotFound(new { error = "Exam not found or access denied" });

            return Ok(examDetail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting exam detail");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/exams/{maLop}/students - Lấy danh sách sinh viên dự thi
    /// </summary>
    [HttpGet("exams/{maLop}/students")]
    public async Task<ActionResult<IEnumerable<ExamStudentDto>>> GetExamStudents(string maLop)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var students = await _context.Database
                .SqlQueryRaw<ExamStudentDto>(
                    "SELECT * FROM func_get_exam_students({0}, {1})",
                    lecturerId,
                    maLop)
                .ToListAsync();

            return Ok(students);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting exam students");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion

    #region Administrative Services

    /// <summary>
    /// POST /api/lecturer/confirmation-letter - Tạo Giấy xác nhận cho sinh viên
    /// </summary>
    [HttpPost("confirmation-letter")]
    public async Task<IActionResult> CreateConfirmationLetter(
        [FromBody] LecturerConfirmationLetterDto request)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (request.Mssv <= 0)
            return BadRequest(new { error = "Valid MSSV is required" });

        try
        {
            var result = await _context.Database
                .SqlQueryRaw<ConfirmationLetterResultDto>(
                    "SELECT * FROM func_lecturer_create_confirmation_letter({0}, {1}, {2})",
                    lecturerId,
                    request.Mssv,
                    request.Purpose ?? "")
                .FirstOrDefaultAsync();

            if (result == null)
                return StatusCode(500, new { error = "Failed to create confirmation letter" });

            _logger.LogInformation(
                "Lecturer {LecturerId} created confirmation letter for student {Mssv}",
                lecturerId, request.Mssv);

            return Ok(new
            {
                message = "Confirmation letter created successfully",
                serialNumber = result.SerialNumber,
                expiryDate = result.ExpiryDate
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating confirmation letter");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/tuition - Xem thông tin học phí của sinh viên
    /// </summary>
    [HttpGet("tuition")]
    public async Task<ActionResult<StudentTuitionDto>> GetStudentTuition(
        [FromQuery] int mssv,
        [FromQuery] string? hocKy = null)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (mssv <= 0)
            return BadRequest(new { error = "Valid MSSV is required" });

        try
        {
            var tuition = await _context.Database
                .SqlQueryRaw<StudentTuitionDto>(
                    "SELECT * FROM func_get_student_tuition({0}, {1})",
                    mssv,
                    hocKy ?? "")
                .FirstOrDefaultAsync();

            if (tuition == null)
                return NotFound(new { error = "No tuition information found" });

            return Ok(tuition);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting student tuition");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion

    #region Appeals Management

    /// <summary>
    /// GET /api/lecturer/appeals - Lấy danh sách các yêu cầu phúc khảo
    /// </summary>
    [HttpGet("appeals")]
    public async Task<ActionResult<IEnumerable<LecturerAppealDto>>> GetAppeals(
        [FromQuery] string? status = null)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var appeals = await _context.Database
                .SqlQueryRaw<LecturerAppealDto>(
                    "SELECT * FROM func_get_lecturer_appeals({0}, {1})",
                    lecturerId,
                    status ?? "")
                .ToListAsync();

            return Ok(appeals);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting lecturer appeals");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/appeals/{appealId} - Xem chi tiết 1 yêu cầu phúc khảo
    /// </summary>
    [HttpGet("appeals/{appealId}")]
    public async Task<ActionResult<LecturerAppealDetailDto>> GetAppealDetail(int appealId)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var appealDetail = await _context.Database
                .SqlQueryRaw<LecturerAppealDetailDto>(
                    "SELECT * FROM func_get_lecturer_appeal_detail({0}, {1})",
                    lecturerId,
                    appealId)
                .FirstOrDefaultAsync();

            if (appealDetail == null)
                return NotFound(new { error = "Appeal not found or access denied" });

            return Ok(appealDetail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting appeal detail");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// PUT /api/lecturer/appeals/{appealId} - Xử lý phúc khảo (chấp nhận/từ chối)
    /// </summary>
    [HttpPut("appeals/{appealId}")]
    public async Task<IActionResult> ProcessAppeal(
        int appealId,
        [FromBody] ProcessAppealDto request)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (string.IsNullOrEmpty(request.Status))
            return BadRequest(new { error = "Status is required (approved/rejected)" });

        try
        {
            var result = await _context.Database
                .SqlQueryRaw<AppealProcessResultDto>(
                    "SELECT * FROM func_lecturer_process_appeal({0}, {1}, {2}, {3})",
                    lecturerId,
                    appealId,
                    request.Status,
                    request.Comment ?? "")
                .FirstOrDefaultAsync();

            if (result == null || !result.Success)
                return BadRequest(new { error = result?.Message ?? "Failed to process appeal" });

            _logger.LogInformation(
                "Lecturer {LecturerId} processed appeal {AppealId} with status {Status}",
                lecturerId, appealId, request.Status);

            return Ok(new { message = result.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing appeal");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion

    #region Notifications

    /// <summary>
    /// GET /api/lecturer/notifications - Lấy thông báo gửi tới giảng viên
    /// </summary>
    [HttpGet("notifications")]
    public async Task<ActionResult<IEnumerable<NotificationDto>>> GetNotifications(
        [FromQuery] int limit = 50,
        [FromQuery] int offset = 0)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var notifications = await _context.Database
                .SqlQueryRaw<NotificationDto>(
                    "SELECT * FROM func_get_lecturer_notifications({0}, {1}, {2})",
                    lecturerId,
                    limit,
                    offset)
                .ToListAsync();

            return Ok(notifications);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting notifications");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// PUT /api/lecturer/notifications/{id}/read - Đánh dấu thông báo đã đọc
    /// </summary>
    [HttpPut("notifications/{id}/read")]
    public async Task<IActionResult> MarkNotificationAsRead(int id)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            await _context.Database
                .ExecuteSqlRawAsync(
                    "SELECT func_mark_notification_read({0}, {1})",
                    lecturerId,
                    id);

            return Ok(new { message = "Notification marked as read" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error marking notification as read");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion

    #region Attendance & Absence Management

    /// <summary>
    /// POST /api/lecturer/absence - Báo nghỉ dạy
    /// </summary>
    [HttpPost("absence")]
    public async Task<IActionResult> ReportAbsence([FromBody] LecturerAbsenceDto request)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (string.IsNullOrEmpty(request.MaLop) || request.NgayNghi == default)
            return BadRequest(new { error = "Class code and absence date are required" });

        try
        {
            var result = await _context.Database
                .SqlQueryRaw<AbsenceResultDto>(
                    "SELECT * FROM func_lecturer_report_absence({0}, {1}, {2}, {3})",
                    lecturerId,
                    request.MaLop,
                    DateTime.SpecifyKind(request.NgayNghi, DateTimeKind.Utc),
                    request.LyDo ?? "")
                .FirstOrDefaultAsync();

            if (result == null || !result.Success)
                return BadRequest(new { error = result?.Message ?? "Failed to report absence" });

            _logger.LogInformation(
                "Lecturer {LecturerId} reported absence for class {MaLop} on {NgayNghi}",
                lecturerId, request.MaLop, request.NgayNghi);

            return Ok(new { message = "Absence reported successfully", absenceId = result.AbsenceId });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reporting absence");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// POST /api/lecturer/makeup-class - Báo học bù
    /// </summary>
    [HttpPost("makeup-class")]
    public async Task<IActionResult> ScheduleMakeupClass([FromBody] LecturerMakeupClassDto request)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        if (string.IsNullOrEmpty(request.MaLop) || request.NgayHocBu == default)
            return BadRequest(new { error = "Class code and makeup date are required" });

        try
        {
            var result = await _context.Database
                .SqlQueryRaw<MakeupClassResultDto>(
                    "SELECT * FROM func_lecturer_schedule_makeup({0}, {1}, {2}, {3}, {4}, {5}, {6})",
                    lecturerId,
                    request.MaLop,
                    DateTime.SpecifyKind(request.NgayHocBu, DateTimeKind.Utc),
                    request.TietBatDau,
                    request.TietKetThuc,
                    request.PhongHoc ?? "",
                    request.LyDo ?? "")
                .FirstOrDefaultAsync();

            if (result == null || !result.Success)
                return BadRequest(new { error = result?.Message ?? "Failed to schedule makeup class" });

            _logger.LogInformation(
                "Lecturer {LecturerId} scheduled makeup class for {MaLop} on {NgayHocBu}",
                lecturerId, request.MaLop, request.NgayHocBu);

            return Ok(new { message = "Makeup class scheduled successfully", makeupId = result.MakeupId });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error scheduling makeup class");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/absences - Xem lịch sử báo nghỉ
    /// </summary>
    [HttpGet("absences")]
    public async Task<ActionResult<IEnumerable<LecturerAbsenceHistoryDto>>> GetAbsences(
        [FromQuery] string? semester = null)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var absences = await _context.Database
                .SqlQueryRaw<LecturerAbsenceHistoryDto>(
                    "SELECT * FROM func_get_lecturer_absences({0}, {1})",
                    lecturerId,
                    semester ?? "")
                .ToListAsync();

            return Ok(absences);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting absences");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    /// <summary>
    /// GET /api/lecturer/makeup-classes - Xem lịch học bù
    /// </summary>
    [HttpGet("makeup-classes")]
    public async Task<ActionResult<IEnumerable<LecturerMakeupClassHistoryDto>>> GetMakeupClasses(
        [FromQuery] string? semester = null)
    {
        var (lecturerId, errorResult) = GetCurrentLecturerId();
        if (errorResult != null) return errorResult;

        try
        {
            var makeupClasses = await _context.Database
                .SqlQueryRaw<LecturerMakeupClassHistoryDto>(
                    "SELECT * FROM func_get_lecturer_makeup_classes({0}, {1})",
                    lecturerId,
                    semester ?? "")
                .ToListAsync();

            return Ok(makeupClasses);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting makeup classes");
            return StatusCode(500, new { error = $"Lỗi Server: {ex.Message}" });
        }
    }

    #endregion
}
