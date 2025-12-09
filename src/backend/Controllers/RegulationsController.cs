using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using eUIT.API.Data;
using eUIT.API.DTOs;

namespace eUIT.API.Controllers;

[ApiController]
[Route("api/public")]
public class RegulationsController : ControllerBase
{
    private readonly eUITDbContext _context;

    public RegulationsController(eUITDbContext context)
    {
        _context = context;
    }

    private class RegulationResult
    {
        public string ten_van_ban { get; set; } = string.Empty;
        public string url_van_ban { get; set; } = string.Empty;
        public DateTime? ngay_ban_hanh { get; set; }
    }

    /// <summary>
    /// Retrieves education regulations. Supports searching and downloading files.
    /// </summary>
    /// <param name="download">Set to true to download a specific regulation file</param>
    /// <param name="search_term">Search keyword to filter regulations</param>
    /// <param name="file_name">File name to download (required when download=true)</param>
    [HttpGet("regulations")]
    public async Task<IActionResult> GetRegulations(
        [FromQuery] bool download = false,
        [FromQuery] string? search_term = null,
        [FromQuery] string? file_name = null)
    {
        try
        {
            // If download is requested, return the file
            if (download)
            {
                if (string.IsNullOrEmpty(file_name))
                {
                    return BadRequest(new { Message = "Tên file không được để trống khi tải xuống" });
                }

                // Build the file path
                var staticFilesPath = Path.Combine(Directory.GetCurrentDirectory(), "StaticContent", "documents", file_name);

                if (!System.IO.File.Exists(staticFilesPath))
                {
                    return NotFound(new { Message = "File không tồn tại" });
                }

                var fileBytes = await System.IO.File.ReadAllBytesAsync(staticFilesPath);
                var contentType = "application/pdf"; // Assuming PDF files, adjust as needed

                return File(fileBytes, contentType, file_name);
            }

            // Otherwise, return the list of regulations
            List<RegulationResult> regulationResults;

            // Add search filter if provided
            if (!string.IsNullOrEmpty(search_term))
            {
                // Use parameterized query with LIKE pattern
                var searchPattern = $"%{search_term}%";
                regulationResults = await _context.Database
                    .SqlQuery<RegulationResult>($"SELECT ten_van_ban, url_van_ban, ngay_ban_hanh FROM van_ban WHERE ten_van_ban ILIKE {searchPattern} ORDER BY ngay_ban_hanh DESC NULLS LAST")
                    .ToListAsync();
            }
            else
            {
                regulationResults = await _context.Database
                    .SqlQuery<RegulationResult>($"SELECT ten_van_ban, url_van_ban, ngay_ban_hanh FROM van_ban ORDER BY ngay_ban_hanh DESC NULLS LAST")
                    .ToListAsync();
            }

            if (regulationResults == null || regulationResults.Count == 0)
            {
                return Ok(new RegulationListResponseDto
                {
                    Regulations = new List<RegulationDto>(),
                    Message = "Không tìm thấy quy chế nào"
                });
            }

            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            var regulations = regulationResults.Select(r => new RegulationDto
            {
                TenVanBan = r.ten_van_ban,
                UrlVanBan = $"{baseUrl}/files/documents/{r.url_van_ban}",
                NgayBanHanh = r.ngay_ban_hanh
            }).ToList();

            return Ok(new RegulationListResponseDto
            {
                Regulations = regulations
            });
        }
        catch (Exception)
        {
            return StatusCode(500, new RegulationListResponseDto
            {
                Regulations = new List<RegulationDto>(),
                Message = "Không thể tải dữ liệu quy chế"
            });
        }
    }
}
