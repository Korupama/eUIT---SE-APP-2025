using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;
using System.Security.Claims;
using HtmlAgilityPack;
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
        public string thu { get; set; }
        public int tiet_bat_dau { get; set; }
        public int tiet_ket_thuc { get; set; }
        public string phong_hoc { get; set; }
        public DateTime next_date { get; set; }
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
    
    // Lớp private để ánh xạ kết quả từ hàm func_calculate_progress_tracking
    private class GroupProgressResult
    {
        // Cấu trúc này phải khớp chính xác với `RETURNS TABLE` của hàm SQL
        public int student_id_out { get; set; }
        public string nhom_mon_out { get; set; } = string.Empty;
        public int total_completed_credits_out { get; set; }
        public decimal gpa_nhom_mon_out { get; set; }
    }

    // GET: api/students/nextclass
    [HttpGet("/nextclass")]
    public async Task<ActionResult<NextClassDto>> GetNextClass()
    {
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;
        
        var mssvParam = new NpgsqlParameter("p_mssv", mssv);
        var NextClassResult = await
        _context.Database.SqlQueryRaw<NextClassInfo>("SELECT * FROM func_get_next_class(@p_mssv)", mssvParam)
        .FirstOrDefaultAsync();

        if (NextClassResult == null) return NoContent();

        var NextClass = new NextClassDto
        {
            MaLop = NextClassResult.ma_lop,
            Thu = NextClassResult.thu,
            TietBatDau = NextClassResult.tiet_bat_dau,
            TietKetThuc = NextClassResult.tiet_ket_thuc,
            PhongHoc = NextClassResult.phong_hoc,
            NgayHoc = NextClassResult.next_date
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

        var mssvParam = new NpgsqlParameter("p_mssv", mssv);
        var student = await
            _context.Database.SqlQueryRaw<CardInfoResult>(
            "SELECT * FROM func_get_student_card_info(@p_mssv)", mssvParam)
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

        var mssvParam = new NpgsqlParameter("p_mssv", mssv);
        var result = await
            _context.Database.SqlQueryRaw<QuickGpa>(
            "SELECT * FROM func_calculate_gpa(@p_mssv)", mssvParam)
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
    
    /// <summary>
    /// Retrieves the training progress for the currently authenticated student.
    /// </summary>
    /// <param name="filter_by_group">Optional filter for course group. Valid values: 'dai_cuong', 'co_so', 'chuyen_nganh', 'tot_nghiep'.</param>
    [HttpGet("progress")]
    public async Task<ActionResult<ProgressTrackingDto>> GetTrainingProgress([FromQuery] string? filter_by_group)
    {
        var (mssv, errorResult) = GetCurrentMssv();
        if (errorResult != null) return errorResult;

        var validGroups = new List<string> { "dai_cuong", "co_so", "chuyen_nganh", "tot_nghiep" };
        var groupsToQuery = new List<string>();

        // Xác định các nhóm môn cần truy vấn
        if (!string.IsNullOrEmpty(filter_by_group))
        {
            if (!validGroups.Contains(filter_by_group.ToLower()))
            {
                return BadRequest("Giá trị của 'filter_by_group' không hợp lệ.");
            }
            groupsToQuery.Add(filter_by_group);
        }
        else
        {
            // Nếu không lọc, truy vấn tất cả các nhóm
            groupsToQuery.AddRange(validGroups);
        }

        var progressByGroup = new List<GroupProgressDto>();
        
        // Lặp qua từng nhóm và gọi hàm DB
        foreach (var group in groupsToQuery)
        {
            var mssvParam = new NpgsqlParameter("p_student_id", mssv);
            var groupFilterParam = new NpgsqlParameter("p_filter_group", group);

            var result = await _context.Database
                .SqlQueryRaw<GroupProgressResult>(
                    "SELECT * FROM func_calculate_progress_tracking(@p_student_id, @p_filter_group)",
                    mssvParam, groupFilterParam)
                .FirstOrDefaultAsync();

            if (result != null)
            {
                progressByGroup.Add(new GroupProgressDto
                {
                    GroupName = result.nhom_mon_out,
                    CompletedCredits = result.total_completed_credits_out,
                    Gpa = result.gpa_nhom_mon_out
                });
            }
        }

        var response = new ProgressTrackingDto { ProgressByGroup = progressByGroup };
        return Ok(response);
    }

    /// <summary>
    /// Retrieves the academic year plan by scraping the university's website.
    /// </summary>
    /// <param name="download_image">This parameter is noted for future use but not implemented in the current logic.</param>
    /// <returns>A dictionary of image descriptions and their corresponding URLs.</returns>
    [AllowAnonymous] // Cho phép truy cập API này mà không cần đăng nhập
    [HttpGet("/api/public/academic-plan")]
    public async Task<ActionResult<Dictionary<string, string>>> GetAcademicPlan([FromQuery] bool download_image = false)
    {
        try
        {
            const string url = "https://student.uit.edu.vn/bieu-do-ke-hoach-dao-tao";
            var web = new HtmlWeb();
            var htmlDoc = await web.LoadFromWebAsync(url);

            var result = new Dictionary<string, string>();

            var imgNodes = htmlDoc.DocumentNode.SelectNodes("//img[@alt]");
            if (imgNodes == null || !imgNodes.Any())
            {
                // Exception: "Dữ liệu chưa được công bố"
                return NotFound("Dữ liệu chưa được công bố");
            }

            // Tìm node hình ảnh đầu tiên có cả 'src' và 'alt' không rỗng
            var validImgNode = imgNodes.FirstOrDefault(node =>
                !string.IsNullOrEmpty(node.GetAttributeValue("src", "")) &&
                !string.IsNullOrEmpty(node.GetAttributeValue("alt", "")));

            if (validImgNode == null)
            {
                // Nếu không tìm thấy node nào hợp lệ, cũng coi như dữ liệu chưa có
                return NotFound("Dữ liệu chưa được công bố");
            }

            string src = validImgNode.GetAttributeValue("src", string.Empty);
            string alt = validImgNode.GetAttributeValue("alt", string.Empty);
            result[alt] = src;

            return Ok(result);
        }
        catch (Exception ex)
        {
            // Trả về lỗi server nếu có vấn đề khi tải hoặc phân tích trang web
            return StatusCode(500, $"An error occurred: {ex.Message}");
        }
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
