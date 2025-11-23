using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;
using System.Security.Claims;

namespace eUIT.API.Controllers;

[Authorize]
[ApiController]
[Route("api/student/schedule")]
public class ScheduleController : ControllerBase
{
    private readonly eUITDbContext _context;

    public ScheduleController(eUITDbContext context)
    {
        _context = context;
    }

    // GET: api/student/schedule/classes
    [HttpGet("classes")]
    public async Task<ActionResult<ScheduleResponseDto>> GetSchedule(
        [FromQuery] string? view_mode = "week",
        [FromQuery] string? filter_by_course = null,
        [FromQuery] string? filter_by_lecturer = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null) return Forbid();
        if (!int.TryParse(loggedInMssv, out int mssvInt)) return Forbid();

        try
        {
            // Get all schedule for the student
            var scheduleResults = await _context.Database
                .SqlQuery<ScheduleResultDto>($"SELECT * FROM func_get_student_schedule({mssvInt})")
                .ToListAsync();

            if (scheduleResults == null || scheduleResults.Count == 0)
            {
                return Ok(new ScheduleResponseDto
                {
                    Classes = new List<ScheduleClassDto>(),
                    Message = "Chưa có lịch học"
                });
            }

            // Apply filters
            var filteredResults = scheduleResults.AsQueryable();

            if (!string.IsNullOrEmpty(filter_by_course))
            {
                filteredResults = filteredResults.Where(s => 
                    s.ma_mon_hoc.Contains(filter_by_course, StringComparison.OrdinalIgnoreCase) ||
                    s.ten_mon_hoc.Contains(filter_by_course, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrEmpty(filter_by_lecturer))
            {
                filteredResults = filteredResults.Where(s => 
                    s.ho_ten.Contains(filter_by_lecturer, StringComparison.OrdinalIgnoreCase) ||
                    s.ma_giang_vien.Contains(filter_by_lecturer, StringComparison.OrdinalIgnoreCase));
            }

            // Apply view mode filtering
            var now = DateTime.Now;
            switch (view_mode?.ToLower())
            {
                case "day":
                    // Show today's classes
                    filteredResults = filteredResults.Where(s => 
                        IsClassOnDate(s, now));
                    break;
                case "week":
                    // Show this week's classes
                    var startOfWeek = now.Date.AddDays(-(int)now.DayOfWeek + (int)DayOfWeek.Monday);
                    var endOfWeek = startOfWeek.AddDays(6);
                    filteredResults = filteredResults.Where(s => 
                        s.ngay_bat_dau <= endOfWeek && s.ngay_ket_thuc >= startOfWeek);
                    break;
                case "month":
                    // Show this month's classes
                    var startOfMonth = new DateTime(now.Year, now.Month, 1);
                    var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);
                    filteredResults = filteredResults.Where(s => 
                        s.ngay_bat_dau <= endOfMonth && s.ngay_ket_thuc >= startOfMonth);
                    break;
                case "all":
                    // Show all classes from now until the end
                    filteredResults = filteredResults.Where(s => 
                        s.ngay_ket_thuc >= now.Date);
                    break;
            }

            var classes = filteredResults.Select(s => new ScheduleClassDto
            {
                HocKy = s.hoc_ky,
                MaMonHoc = s.ma_mon_hoc,
                TenMonHoc = s.ten_mon_hoc,
                MaLop = s.ma_lop,
                SoTinChi = s.so_tin_chi,
                MaGiangVien = s.ma_giang_vien,
                TenGiangVien = s.ho_ten,
                Thu = s.thu,
                TietBatDau = s.tiet_bat_dau,
                TietKetThuc = s.tiet_ket_thuc,
                CachTuan = s.cach_tuan,
                NgayBatDau = s.ngay_bat_dau,
                NgayKetThuc = s.ngay_ket_thuc,
                PhongHoc = s.phong_hoc,
                SiSo = s.si_so,
                HinhThucGiangDay = s.hinh_thuc_giang_day,
                GhiChu = s.ghi_chu
            }).ToList();

            return Ok(new ScheduleResponseDto
            {
                Classes = classes
            });
        }
        catch (Exception)
        {
            return StatusCode(500, new ScheduleResponseDto
            {
                Classes = new List<ScheduleClassDto>(),
                Message = "Không thể tải lịch học"
            });
        }
    }

    // Helper method to check if a class occurs on a specific date
    private bool IsClassOnDate(ScheduleResultDto schedule, DateTime date)
    {
        if (date < schedule.ngay_bat_dau || date > schedule.ngay_ket_thuc)
            return false;

        // Check if the day of week matches
        var dayOfWeek = date.DayOfWeek;
        var thuNumber = schedule.thu;
        
        // Convert thu (2-8) to DayOfWeek (0-6)
        var expectedDay = thuNumber switch
        {
            "2" => DayOfWeek.Monday,
            "3" => DayOfWeek.Tuesday,
            "4" => DayOfWeek.Wednesday,
            "5" => DayOfWeek.Thursday,
            "6" => DayOfWeek.Friday,
            "7" => DayOfWeek.Saturday,
            "8" => DayOfWeek.Sunday,
            _ => (DayOfWeek)(-1)
        };

        if (dayOfWeek != expectedDay)
            return false;

        // Check cach_tuan (interval weeks)
        var weeksSinceStart = (date - schedule.ngay_bat_dau).Days / 7;
        return weeksSinceStart % schedule.cach_tuan == 0;
    }

    // GET: api/student/schedule/exams
    [HttpGet("exams")]
    public async Task<ActionResult<ExamScheduleResponseDto>> GetExamSchedule(
        [FromQuery] string? filter_by_semester = null,
        [FromQuery] string? filter_by_group = null)
    {
        var loggedInMssv = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (loggedInMssv == null) return Forbid();
        if (!int.TryParse(loggedInMssv, out int mssvInt)) return Forbid();

        try
        {
            List<ExamResultDto> examResults;

            if (!string.IsNullOrEmpty(filter_by_semester))
            {
                examResults = await _context.Database
                    .SqlQuery<ExamResultDto>($"SELECT * FROM func_get_student_exam_schedule_by_semester({mssvInt}, {filter_by_semester})")
                    .ToListAsync();
            }
            else
            {
                examResults = await _context.Database
                    .SqlQuery<ExamResultDto>($"SELECT * FROM func_get_student_exam_schedule({mssvInt})")
                    .ToListAsync();
            }

            if (examResults == null || examResults.Count == 0)
            {
                return Ok(new ExamScheduleResponseDto
                {
                    Exams = new List<ExamScheduleDto>(),
                    Message = "Chưa công bố lịch thi"
                });
            }

            // Apply group filter if specified (GK or CK)
            if (!string.IsNullOrEmpty(filter_by_group))
            {
                examResults = examResults
                    .Where(e => e.gk_ck.Equals(filter_by_group, StringComparison.OrdinalIgnoreCase))
                    .ToList();
            }

            var exams = examResults.Select(e => new ExamScheduleDto
            {
                MaMonHoc = e.ma_mon_hoc,
                TenMonHoc = e.ten_mon_hoc,
                MaLop = e.ma_lop,
                MaGiangVien = e.ma_giang_vien,
                TenGiangVien = e.ho_ten,
                NgayThi = e.ngay_thi,
                CaThi = e.ca_thi,
                PhongThi = e.phong_thi,
                HinhThucThi = e.hinh_thuc_thi,
                GkCk = e.gk_ck,
                SoTinChi = e.so_tin_chi
            }).ToList();

            return Ok(new ExamScheduleResponseDto
            {
                Exams = exams
            });
        }
        catch (Exception)
        {
            return Ok(new ExamScheduleResponseDto
            {
                Exams = new List<ExamScheduleDto>(),
                Message = "Chưa công bố lịch thi"
            });
        }
    }
}
