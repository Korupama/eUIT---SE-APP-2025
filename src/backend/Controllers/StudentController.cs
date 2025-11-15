using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;
using System.Security.Claims;
using System.Runtime.CompilerServices;

namespace eUIT.API.Controllers;

[Authorize] // Yêu cầu tất cả các API trong controller này đều phải được xác thực
[ApiController]
[Route("api/[controller]")] // Đường dẫn sẽ là /api/students
public class StudentsController : ControllerBase
{
    private readonly eUITDbContext _context;

    public StudentsController(eUITDbContext context)
    {
        _context = context;
    }

    public class NextClassInfo
    {
        public string ma_lop { get; set; } = string.Empty;
        public string ten_mon_hoc_vn { get; set; } = string.Empty;
        public string thu { get; set; } = string.Empty;
        public int tiet_bat_dau { get; set; }
        public int tiet_ket_thuc { get; set; }
        public string phong_hoc { get; set; } = string.Empty;
        public DateTime ngay_hoc { get; set; }
    }
    private class CardInfoResult
    {
        public int mssv { get; set; }
        public string ho_ten { get; set; } = string.Empty;
        public int khoa_hoc { get; set; }
        public string nganh_hoc { get; set; } = string.Empty;
        public string? anh_the_url { get; set; }
    }

    private class QuickGpa
    {
        public float gpa { get; set; }

        public int so_tin_chi_tich_luy { get; set; } = 0;
    }

    // GET: api/students/nextclass
    [HttpGet("/nextclass")]
    public async Task<ActionResult<NextClassDto>> GetNextClass()
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null)
        {
            return Forbid();
        }

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        var NextClassResult = await
        _context.Database.SqlQuery<NextClassInfo>
        ($"SELECT * FROM func_get_next_class({mssvInt})")
        .FirstOrDefaultAsync();

        if (NextClassResult == null) return NoContent();

        var NextClass = new NextClassDto
        {
            MaLop = NextClassResult.ma_lop,
            TenLop = NextClassResult.ten_mon_hoc_vn,
            Thu = NextClassResult.thu,
            TietBatDau = NextClassResult.tiet_bat_dau,
            TietKetThuc = NextClassResult.tiet_ket_thuc,
            PhongHoc = NextClassResult.phong_hoc,
            NgayHoc = NextClassResult.ngay_hoc
        };

        return Ok(NextClass);
    }

    // GET: api/students/card
    [HttpGet("/card")]
    public async Task<ActionResult<StudentCardDto>> GetStudentCard()
    {
        // Bước 1: Xác định người dùng đang thực hiện yêu cầu từ Token
        // Lấy mssv của người dùng đã đăng nhập từ claim trong JWT
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null)
        {
            return Forbid();
        }

        // Bước 2: Truy vấn thông tin sinh viên từ database ===
        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        var student = await
            _context.Database.SqlQuery<CardInfoResult>(
            $"SELECT * FROM func_get_student_card_info({mssvInt})")
            .FirstOrDefaultAsync();

        if (student == null)
        {
            return NotFound(); // Không tìm thấy sinh viên với mssv này
        }

        // === Bước 3: Xây dựng đường dẫn URL đầy đủ cho ảnh thẻ ===
        string? avatarFullUrl = null;
        if (!string.IsNullOrEmpty(student.anh_the_url))
        {
            // Ghép địa chỉ server + request path + đường dẫn tương đối trong DB
            // Ví dụ: https://localhost:5093 + /files + /Students/Avatars/23520560.jpg
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            avatarFullUrl = $"{baseUrl}/files/{student.anh_the_url}";

        }

        // === Bước 4: Ánh xạ dữ liệu từ entity của database sang DTO để trả về ===
        var studentCard = new StudentCardDto
        {
            Mssv = student.mssv,
            HoTen = student.ho_ten,
            KhoaHoc = student.khoa_hoc,
            NganhHoc = student.nganh_hoc,
            AvatarFullUrl = avatarFullUrl
        };

        return Ok(studentCard);
    }

    /// <summary>
    /// Retrieves the quick GPA and accumulated credits for the currently authenticated student.
    /// </summary>
    [HttpGet("/quickgpa")]
    public async Task<ActionResult<QuickGpaDto>> GetQuickGpa()
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (loggedInMssv == null) return Forbid();

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        var result = await
            _context.Database.SqlQuery<QuickGpa>(
            $"SELECT * FROM func_calculate_gpa({mssvInt})")
            .FirstOrDefaultAsync();

        if (result == null)
        {
            return NotFound(); // Không tìm thấy sinh viên với mssv này
        }

        var gpaAndCredits = new QuickGpaDto
        {
            Gpa = result.gpa,
            SoTinChiTichLuy = result.so_tin_chi_tich_luy
        };

        return Ok(gpaAndCredits);
    }

    private class GradeResult
    {
        public string hoc_ky { get; set; } = string.Empty;
        public string ma_mon_hoc { get; set; } = string.Empty;
        public string ten_mon_hoc { get; set; } = string.Empty;
        public int so_tin_chi { get; set; }
        public float? diem_tong_ket { get; set; }
    }

    /// <summary>
    /// Retrieves the academic grades for the currently authenticated student.
    /// Can be filtered by semester using the filter_by_semester query parameter.
    /// </summary>
    /// <param name="filter_by_semester">Optional semester filter (e.g., "2025_2026_1")</param>
    [HttpGet("/grades")]
    public async Task<ActionResult<GradeListResponseDto>> GetGrades([FromQuery] string? filter_by_semester = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (loggedInMssv == null) return Forbid();

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        try
        {
            List<GradeResult> gradeResults;

            if (!string.IsNullOrEmpty(filter_by_semester))
            {
                // Get grades for a specific semester
                gradeResults = await _context.Database
                    .SqlQuery<GradeResult>($"SELECT * FROM func_get_student_semester_transcript({mssvInt}, {filter_by_semester})")
                    .ToListAsync();
            }
            else
            {
                // Get all grades (full transcript)
                gradeResults = await _context.Database
                    .SqlQuery<GradeResult>($"SELECT * FROM func_get_student_full_transcript({mssvInt})")
                    .ToListAsync();
            }

            if (gradeResults == null || gradeResults.Count == 0)
            {
                return Ok(new GradeListResponseDto
                {
                    Grades = new List<GradeDto>(),
                    Message = "Chưa có dữ liệu"
                });
            }

            var grades = gradeResults.Select(g => new GradeDto
            {
                HocKy = g.hoc_ky,
                MaMonHoc = g.ma_mon_hoc,
                TenMonHoc = g.ten_mon_hoc,
                SoTinChi = g.so_tin_chi,
                DiemTongKet = g.diem_tong_ket
            }).ToList();

            return Ok(new GradeListResponseDto
            {
                Grades = grades
            });
        }
        catch (Exception)
        {
            return StatusCode(500, new GradeListResponseDto
            {
                Grades = new List<GradeDto>(),
                Message = "Không thể tải dữ liệu"
            });
        }
    }

    private class TrainingScoreResult
    {
        public string hoc_ky { get; set; } = string.Empty;
        public int tong_diem { get; set; }
        public string xep_loai { get; set; } = string.Empty;
        public string tinh_trang { get; set; } = string.Empty;
    }

    /// <summary>
    /// Retrieves the training/conduct scores for the currently authenticated student.
    /// Can be filtered by semester using the filter_by_semester query parameter.
    /// </summary>
    /// <param name="filter_by_semester">Optional semester filter (e.g., "2025_2026_1")</param>
    [HttpGet("/training-scores")]
    public async Task<ActionResult<TrainingScoreListResponseDto>> GetTrainingScores([FromQuery] string? filter_by_semester = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (loggedInMssv == null) return Forbid();

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return Forbid();
        }

        try
        {
            // Note: This assumes you have a database function for training scores
            // If not available, this will need to query the training score tables directly
            List<TrainingScoreResult> trainingScoreResults;

            if (string.IsNullOrEmpty(filter_by_semester))
            {
                trainingScoreResults = await _context.Database
                    .SqlQuery<TrainingScoreResult>($"SELECT hoc_ky, tong_diem, xep_loai, 'Đã xác nhận' as tinh_trang FROM func_get_student_training_scores({mssvInt})")
                    .ToListAsync();
            }
            else
            {
                trainingScoreResults = await _context.Database
                    .SqlQuery<TrainingScoreResult>($"SELECT hoc_ky, tong_diem, xep_loai, 'Đã xác nhận' as tinh_trang FROM func_get_student_training_scores({mssvInt}) WHERE hoc_ky = {filter_by_semester}")
                    .ToListAsync();
            }

            if (trainingScoreResults == null || trainingScoreResults.Count == 0)
            {
                return Ok(new TrainingScoreListResponseDto
                {
                    TrainingScores = new List<TrainingScoreDto>(),
                    Message = "Đang chờ xác nhận"
                });
            }

            var trainingScores = trainingScoreResults.Select(ts => new TrainingScoreDto
            {
                HocKy = ts.hoc_ky,
                TongDiem = ts.tong_diem,
                XepLoai = ts.xep_loai,
                TinhTrang = ts.tinh_trang
            }).ToList();

            return Ok(new TrainingScoreListResponseDto
            {
                TrainingScores = trainingScores
            });
        }
        catch (Exception)
        {
            return Ok(new TrainingScoreListResponseDto
            {
                TrainingScores = new List<TrainingScoreDto>(),
                Message = "Đang chờ xác nhận"
            });
        }
    }
}
