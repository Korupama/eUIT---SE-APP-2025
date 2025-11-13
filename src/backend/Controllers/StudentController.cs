using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;
using System.Security.Claims;
using Npgsql;

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
        public string ma_lop { get; set; }
        public string ten_mon_hoc_vn { get; set; }
        public string thu { get; set; }
        public int tiet_bat_dau { get; set; }
        public int tiet_ket_thuc { get; set; }
        public string phong_hoc { get; set; }
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

    private class TuitionInfo
    {
        public string hoc_ky { get; set; } = string.Empty;
        public int so_tin_chi { get; set; }
        public long hoc_phi { get; set; }
        public long no_hoc_ky_truoc { get; set; }
        public long da_dong { get; set; }
        public long so_tien_con_lai { get; set; }
    }

    // GET: api/students/nextclass
    [HttpGet("/nextclass")]
    public async Task<ActionResult<NextClassDto>> GetNextClass()
    {
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        var NextClassResult = await
        _context.Database.SqlQuery<NextClassInfo>
        ($"SELECT * FROM func_get_next_class({mssv})")
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
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        var student = await
            _context.Database.SqlQuery<CardInfoResult>(
            $"SELECT * FROM func_get_student_card_info({mssv})")
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
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        var result = await
            _context.Database.SqlQuery<QuickGpa>(
            $"SELECT * FROM func_calculate_gpa({mssv})")
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

    /// <summary>
    /// Retrieves tuition fee information for the currently authenticated student.
    /// Can be filtered by academic year.
    /// </summary>
    /// <param name="filter_by_year">The academic year to filter by (e.g., "2023-2024"). If null, returns all tuition data.</param>
    [HttpGet("tuition")]
    public async Task<ActionResult<IEnumerable<TuitionDto>>> GetTuition([FromQuery] string? filter_by_year)
    {
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        // The database function func_get_student_tuition is expected to exist.
        // It should accept mssv (student id) and an optional year filter.
        // Use parameterized queries to prevent SQL injection.
        var mssvParam = new NpgsqlParameter("p_mssv", mssv);
        var yearParam = new NpgsqlParameter("p_year_filter", (object)filter_by_year ?? DBNull.Value);

        var tuitionInfos = await _context.Database
            .SqlQueryRaw<TuitionInfo>("SELECT * FROM func_get_student_tuition(@p_mssv, @p_year_filter)", mssvParam, yearParam)
            .ToListAsync();

        if (!tuitionInfos.Any())
        {
            return NotFound("Chưa phát sinh học phí");
        }

        var tuitionDtos = tuitionInfos.Select(t => new TuitionDto
        {
            HocKy = t.hoc_ky,
            SoTinChi = t.so_tin_chi,
            HocPhi = t.hoc_phi,
            NoHocKyTruoc = t.no_hoc_ky_truoc,
            DaDong = t.da_dong,
            SoTienConLai = t.so_tien_con_lai
        });

        return Ok(tuitionDtos);
    }
    
    private (int? mssv, ActionResult? errorResult) GetCurrentMssv()
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null)
        {
            return (null, Forbid());
        }

        if (!int.TryParse(loggedInMssv, out int mssvInt))
        {
            return (null, Forbid());
        }
        return (mssvInt, null);
    }
}
