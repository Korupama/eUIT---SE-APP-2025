using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.Services;

namespace eUIT.API.Controllers;

/// <summary>
/// Admin Controller - Các endpoint dành cho Admin/Giảng viên
/// Tự động gửi notification khi có thay đổi dữ liệu
/// </summary>
// TODO: Bật lại [Authorize(Roles = "Admin,GiangVien")] khi deploy production
// [Authorize(Roles = "Admin,GiangVien")]
[ApiController]
[Route("api/admin")]
public class AdminController : ControllerBase
{
    private readonly eUITDbContext _context;
    private readonly INotificationClient _notificationClient;
    private readonly ILogger<AdminController> _logger;

    public AdminController(
        eUITDbContext context,
        INotificationClient notificationClient,
        ILogger<AdminController> logger)
    {
        _context = context;
        _notificationClient = notificationClient;
        _logger = logger;
    }

    #region Kết quả học tập

    /// <summary>
    /// Cập nhật điểm cho sinh viên - Tự động gửi notification
    /// </summary>
    [HttpPut("grades/{mssv}/{maLop}")]
    public async Task<IActionResult> UpdateGrade(int mssv, string maLop, [FromBody] UpdateGradeRequest request)
    {
        try
        {
            var sql = @"
                UPDATE ket_qua_hoc_tap 
                SET diem_qua_trinh = COALESCE(@p0, diem_qua_trinh),
                    diem_giua_ki = COALESCE(@p1, diem_giua_ki),
                    diem_thuc_hanh = COALESCE(@p2, diem_thuc_hanh),
                    diem_cuoi_ki = COALESCE(@p3, diem_cuoi_ki)
                WHERE ma_lop = @p4 AND mssv = @p5";

            var rowsAffected = await _context.Database.ExecuteSqlRawAsync(sql,
                request.DiemQuaTrinh, request.DiemGiuaKy, request.DiemThucHanh, 
                request.DiemCuoiKy, maLop, mssv);

            if (rowsAffected == 0)
                return NotFound(new { message = "Không tìm thấy bản ghi" });

            // Lấy thông tin môn học và học kỳ từ thoi_khoa_bieu
            var courseInfo = await _context.Database
                .SqlQueryRaw<CourseInfoWithSemester>(@"
                    SELECT mh.ten_mon_hoc_vn as tenmonhoc, 
                           mh.ma_mon_hoc as mamonhoc,
                           tkb.hoc_ky as hocky
                    FROM ket_qua_hoc_tap kqht
                    JOIN thoi_khoa_bieu tkb ON kqht.ma_lop = tkb.ma_lop
                    JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
                    WHERE kqht.ma_lop = @p0 AND kqht.mssv = @p1
                    LIMIT 1", maLop, mssv)
                .FirstOrDefaultAsync();

            // Parse học kỳ: "2023-2024_1" -> HocKy="1", NamHoc="2023-2024"
            var (hocKy, namHoc) = ParseHocKy(courseInfo?.hocky);

            // Gửi notification
            await _notificationClient.NotifyKetQuaHocTapAsync(mssv.ToString(), new KetQuaHocTapNotification(
                MaMonHoc: courseInfo?.mamonhoc ?? "",
                TenMonHoc: courseInfo?.tenmonhoc ?? maLop,
                MaLopHocPhan: maLop,
                DiemQuaTrinh: request.DiemQuaTrinh,
                DiemGiuaKy: request.DiemGiuaKy,
                DiemCuoiKy: request.DiemCuoiKy,
                DiemTongKet: null,
                DiemChu: null,
                HocKy: hocKy,
                NamHoc: namHoc
            ));

            _logger.LogInformation("Updated grade for MSSV {Mssv}, class {MaLop}", mssv, maLop);

            return Ok(new { message = "Cập nhật điểm thành công", notified = true });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating grade for {Mssv}", mssv);
            return StatusCode(500, new { message = "Lỗi khi cập nhật điểm" });
        }
    }

    /// <summary>
    /// Cập nhật điểm cho cả lớp - Tự động gửi notification tới tất cả sinh viên
    /// </summary>
    [HttpPut("grades/class/{maLop}")]
    public async Task<IActionResult> UpdateClassGrades(string maLop, [FromBody] BatchGradeUpdateRequest request)
    {
        var successCount = 0;
        var errors = new List<string>();

        // Lấy thông tin môn học và học kỳ một lần
        var courseInfo = await _context.Database
            .SqlQueryRaw<CourseInfoWithSemester>(@"
                SELECT mh.ten_mon_hoc_vn as tenmonhoc, 
                       mh.ma_mon_hoc as mamonhoc,
                       tkb.hoc_ky as hocky
                FROM thoi_khoa_bieu tkb
                JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
                WHERE tkb.ma_lop = @p0
                LIMIT 1", maLop)
            .FirstOrDefaultAsync();

        // Parse học kỳ
        var (hocKy, namHoc) = ParseHocKy(courseInfo?.hocky);

        foreach (var item in request.Grades)
        {
            try
            {
                var sql = @"
                    UPDATE ket_qua_hoc_tap 
                    SET diem_qua_trinh = COALESCE(@p0, diem_qua_trinh),
                        diem_giua_ki = COALESCE(@p1, diem_giua_ki),
                        diem_cuoi_ki = COALESCE(@p2, diem_cuoi_ki)
                    WHERE ma_lop = @p3 AND mssv = @p4";

                await _context.Database.ExecuteSqlRawAsync(sql,
                    item.DiemQuaTrinh, item.DiemGiuaKy, item.DiemCuoiKy, maLop, item.Mssv);

                // Gửi notification
                await _notificationClient.NotifyKetQuaHocTapAsync(item.Mssv.ToString(), new KetQuaHocTapNotification(
                    MaMonHoc: courseInfo?.mamonhoc ?? "",
                    TenMonHoc: courseInfo?.tenmonhoc ?? maLop,
                    MaLopHocPhan: maLop,
                    DiemQuaTrinh: item.DiemQuaTrinh,
                    DiemGiuaKy: item.DiemGiuaKy,
                    DiemCuoiKy: item.DiemCuoiKy,
                    DiemTongKet: null,
                    DiemChu: null,
                    HocKy: hocKy,
                    NamHoc: namHoc
                ));

                successCount++;
            }
            catch (Exception ex)
            {
                errors.Add($"MSSV {item.Mssv}: {ex.Message}");
            }
        }

        return Ok(new { 
            message = $"Đã cập nhật {successCount}/{request.Grades.Count} sinh viên",
            successCount,
            errors 
        });
    }

    #endregion

    #region Báo bù

    /// <summary>
    /// Thêm lịch học bù - Tự động notify tất cả sinh viên trong lớp
    /// </summary>
    [HttpPost("makeup-class")]
    public async Task<IActionResult> CreateMakeupClass([FromBody] CreateMakeupClassRequest request)
    {
        try
        {
            // Insert vào database
            var sql = @"
                INSERT INTO bao_hoc_bu (ma_lop, ly_do, ngay_hoc_bu, tiet_bat_dau, tiet_ket_thuc, tinh_trang)
                VALUES (@p0, @p1, @p2, @p3, @p4, 'Da duyet')";

            await _context.Database.ExecuteSqlRawAsync(sql,
                request.MaLop, request.LyDo, request.NgayHocBu, 
                request.TietBatDau, request.TietKetThuc);

            // Lấy danh sách sinh viên trong lớp
            var students = await _context.Database
                .SqlQueryRaw<StudentMssv>(@"
                    SELECT DISTINCT mssv as Mssv
                    FROM ket_qua_hoc_tap
                    WHERE ma_lop = @p0 OR ma_lop_goc = @p0", request.MaLop)
                .ToListAsync();

            // Lấy tên môn học
            var courseNameResult = await _context.Database
                .SqlQueryRaw<StringResult>(@"
                    SELECT mh.ten_mon_hoc_vn as ""Value""
                    FROM thoi_khoa_bieu tkb
                    JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
                    WHERE tkb.ma_lop = @p0
                    LIMIT 1", request.MaLop)
                .FirstOrDefaultAsync();
            var courseName = courseNameResult?.Value ?? request.MaLop;

            // Gửi notification tới tất cả sinh viên
            var notification = new BaoBuNotification(
                MaLopHocPhan: request.MaLop,
                TenMonHoc: courseName,
                NgayBu: request.NgayHocBu,
                TietBatDau: request.TietBatDau.ToString(),
                TietKetThuc: request.TietKetThuc.ToString(),
                PhongHoc: request.PhongHoc ?? "",
                GhiChu: request.LyDo
            );

            var notifiedCount = 0;
            foreach (var student in students)
            {
                try
                {
                    await _notificationClient.NotifyBaoBuAsync(student.Mssv.ToString(), notification);
                    notifiedCount++;
                }
                catch { /* Log but continue */ }
            }

            _logger.LogInformation("Created makeup class for {MaLop}, notified {Count} students", 
                request.MaLop, notifiedCount);

            return Ok(new { 
                message = "Đã thêm lịch học bù",
                studentsNotified = notifiedCount
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating makeup class");
            return StatusCode(500, new { message = "Lỗi khi thêm lịch học bù" });
        }
    }

    #endregion

    #region Báo nghỉ

    /// <summary>
    /// Thêm thông báo nghỉ học - Tự động notify tất cả sinh viên trong lớp
    /// </summary>
    [HttpPost("class-cancellation")]
    public async Task<IActionResult> CreateClassCancellation([FromBody] CreateCancellationRequest request)
    {
        try
        {
            // Tự động lấy mã giảng viên từ thời khóa biểu
            var maGvResult = await _context.Database
                .SqlQueryRaw<StringResult>(@"
                    SELECT ma_giang_vien as ""Value""
                    FROM thoi_khoa_bieu
                    WHERE ma_lop = @p0
                    LIMIT 1", request.MaLop)
                .FirstOrDefaultAsync();
            var maGv = maGvResult?.Value;

            // Insert vào database
            var sql = @"
                INSERT INTO bao_nghi_day (ma_lop, ma_giang_vien, ly_do, ngay_nghi, tinh_trang)
                VALUES (@p0, @p1, @p2, @p3, 'Da duyet')";

            await _context.Database.ExecuteSqlRawAsync(sql,
                request.MaLop, maGv, request.LyDo, request.NgayNghi);

            // Lấy danh sách sinh viên trong lớp
            var students = await _context.Database
                .SqlQueryRaw<StudentMssv>(@"
                    SELECT DISTINCT mssv as Mssv
                    FROM ket_qua_hoc_tap
                    WHERE ma_lop = @p0 OR ma_lop_goc = @p0", request.MaLop)
                .ToListAsync();

            // Lấy tên môn học
            var courseNameResult = await _context.Database
                .SqlQueryRaw<StringResult>(@"
                    SELECT mh.ten_mon_hoc_vn as ""Value""
                    FROM thoi_khoa_bieu tkb
                    JOIN mon_hoc mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
                    WHERE tkb.ma_lop = @p0
                    LIMIT 1", request.MaLop)
                .FirstOrDefaultAsync();
            var courseName = courseNameResult?.Value ?? request.MaLop;

            // Gửi notification tới tất cả sinh viên
            var notification = new BaoNghiNotification(
                MaLopHocPhan: request.MaLop,
                TenMonHoc: courseName,
                NgayNghi: request.NgayNghi,
                LyDo: request.LyDo,
                GhiChu: request.GhiChu
            );

            var notifiedCount = 0;
            foreach (var student in students)
            {
                try
                {
                    await _notificationClient.NotifyBaoNghiAsync(student.Mssv.ToString(), notification);
                    notifiedCount++;
                }
                catch { /* Log but continue */ }
            }

            _logger.LogInformation("Created class cancellation for {MaLop}, notified {Count} students", 
                request.MaLop, notifiedCount);

            return Ok(new { 
                message = "Đã thêm thông báo nghỉ học",
                studentsNotified = notifiedCount
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating class cancellation");
            return StatusCode(500, new { message = "Lỗi khi thêm thông báo nghỉ" });
        }
    }

    #endregion

    #region Điểm rèn luyện

    /// <summary>
    /// Cập nhật điểm rèn luyện - Tự động notify sinh viên
    /// </summary>
    [HttpPut("training-score/{mssv}")]
    public async Task<IActionResult> UpdateTrainingScore(int mssv, [FromBody] UpdateTrainingScoreRequest request)
    {
        try
        {
            // Tính xếp loại
            var xepLoai = request.DiemRenLuyen switch
            {
                >= 90 => "Xuất sắc",
                >= 80 => "Tốt",
                >= 65 => "Khá",
                >= 50 => "Trung bình",
                >= 35 => "Yếu",
                _ => "Kém"
            };

            // TODO: Insert/Update vào bảng diem_ren_luyen nếu có
            // var sql = "INSERT INTO diem_ren_luyen ...";

            // Gửi notification
            await _notificationClient.NotifyDiemRenLuyenAsync(mssv.ToString(), new DiemRenLuyenNotification(
                HocKy: request.HocKy,
                NamHoc: request.NamHoc,
                DiemRenLuyen: request.DiemRenLuyen,
                XepLoai: xepLoai
            ));

            _logger.LogInformation("Updated training score for MSSV {Mssv}: {Score}", mssv, request.DiemRenLuyen);

            return Ok(new { 
                message = "Đã cập nhật điểm rèn luyện",
                mssv,
                diemRenLuyen = request.DiemRenLuyen,
                xepLoai,
                notified = true
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating training score");
            return StatusCode(500, new { message = "Lỗi khi cập nhật điểm rèn luyện" });
        }
    }

    /// <summary>
    /// Cập nhật điểm rèn luyện cho nhiều sinh viên
    /// </summary>
    [HttpPut("training-score/batch")]
    public async Task<IActionResult> UpdateTrainingScoreBatch([FromBody] BatchTrainingScoreRequest request)
    {
        var successCount = 0;

        foreach (var item in request.Scores)
        {
            try
            {
                var xepLoai = item.DiemRenLuyen switch
                {
                    >= 90 => "Xuất sắc",
                    >= 80 => "Tốt",
                    >= 65 => "Khá",
                    >= 50 => "Trung bình",
                    >= 35 => "Yếu",
                    _ => "Kém"
                };

                await _notificationClient.NotifyDiemRenLuyenAsync(item.Mssv.ToString(), new DiemRenLuyenNotification(
                    HocKy: request.HocKy,
                    NamHoc: request.NamHoc,
                    DiemRenLuyen: item.DiemRenLuyen,
                    XepLoai: xepLoai
                ));

                successCount++;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to notify MSSV {Mssv}", item.Mssv);
            }
        }

        return Ok(new { 
            message = $"Đã thông báo {successCount}/{request.Scores.Count} sinh viên",
            successCount
        });
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Parse học kỳ từ định dạng "2023-2024_1" thành (HocKy: "1", NamHoc: "2023-2024")
    /// </summary>
    private static (string HocKy, string NamHoc) ParseHocKy(string? hocKyRaw)
    {
        if (string.IsNullOrEmpty(hocKyRaw))
            return ("", "");

        // Format: "2023-2024_1" hoặc "2024-2025_2"
        var parts = hocKyRaw.Trim().Split('_');
        if (parts.Length == 2)
        {
            return (parts[1], parts[0]); // HocKy = "1", NamHoc = "2023-2024"
        }
        
        return (hocKyRaw, "");
    }

    #endregion

    #region Helper Classes

    private class CourseInfo
    {
        public string TenMonHoc { get; set; } = "";
        public string MaMonHoc { get; set; } = "";
    }

    private class CourseInfoWithSemester
    {
        public string tenmonhoc { get; set; } = "";
        public string mamonhoc { get; set; } = "";
        public string hocky { get; set; } = "";
    }

    private class StudentMssv
    {
        public int Mssv { get; set; }
    }

    private class StringResult
    {
        public string Value { get; set; } = "";
    }

    #endregion
}

#region Request DTOs

public class UpdateGradeRequest
{
    public decimal? DiemQuaTrinh { get; set; }
    public decimal? DiemGiuaKy { get; set; }
    public decimal? DiemThucHanh { get; set; }
    public decimal? DiemCuoiKy { get; set; }
    // HocKy và NamHoc được lấy tự động từ thoi_khoa_bieu dựa vào ma_lop
}

public class BatchGradeUpdateRequest
{
    // HocKy và NamHoc được lấy tự động từ thoi_khoa_bieu dựa vào ma_lop
    public List<StudentGrade> Grades { get; set; } = new();
}

public class StudentGrade
{
    public int Mssv { get; set; }
    public decimal? DiemQuaTrinh { get; set; }
    public decimal? DiemGiuaKy { get; set; }
    public decimal? DiemCuoiKy { get; set; }
}

public class CreateMakeupClassRequest
{
    public string MaLop { get; set; } = "";
    public string LyDo { get; set; } = "";
    public DateTime NgayHocBu { get; set; }
    public int TietBatDau { get; set; }
    public int TietKetThuc { get; set; }
    public string? PhongHoc { get; set; }
}

public class CreateCancellationRequest
{
    public string MaLop { get; set; } = "";
    public string LyDo { get; set; } = "";
    public DateTime NgayNghi { get; set; }
    public string? GhiChu { get; set; }
}

public class UpdateTrainingScoreRequest
{
    public string HocKy { get; set; } = "";
    public string NamHoc { get; set; } = "";
    public int DiemRenLuyen { get; set; }
}

public class BatchTrainingScoreRequest
{
    public string HocKy { get; set; } = "";
    public string NamHoc { get; set; } = "";
    public List<StudentTrainingScore> Scores { get; set; } = new();
}

public class StudentTrainingScore
{
    public int Mssv { get; set; }
    public int DiemRenLuyen { get; set; }
}

#endregion
