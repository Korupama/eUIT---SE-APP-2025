using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using eUIT.API.Data;
using eUIT.API.DTOs;

[ApiController]
[Route("api/[controller]")]
public class NewsController : ControllerBase
{
    private readonly eUITDbContext _context;

    public NewsController(eUITDbContext context)
    {
        _context = context;
    }

    private class NewsQueryResult
    {
        public string tieu_de { get; set; } = string.Empty;
        public string url { get; set; } = string.Empty;
        public DateTimeOffset ngay_dang { get; set; }
    }

    [HttpGet("/news")]
    public async Task<ActionResult<IEnumerable<NewsDTO>>> GetLatestNews()
    {
        // Use raw SQL query for unmapped type
        var results = new List<NewsQueryResult>();
        var conn = _context.Database.GetDbConnection();
        await conn.OpenAsync();
        using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = "SELECT * FROM get_latest_bai_viet()";
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                // Debug: get all column names
                var columnNames = new List<string>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    columnNames.Add(reader.GetName(i));
                }
                // Try to map using available columns
                while (await reader.ReadAsync())
                {
                    results.Add(new NewsQueryResult
                    {
                        tieu_de = reader[columnNames.Contains("tieu_de") ? "tieu_de" : columnNames[0]].ToString() ?? string.Empty,
                        url = reader[columnNames.Contains("url") ? "url" : columnNames.FirstOrDefault(n => n.ToLower().Contains("url")) ?? columnNames[1]].ToString() ?? string.Empty,
                        ngay_dang = reader[columnNames.Contains("ngay_dang") ? "ngay_dang" : columnNames.Last()].GetType() == typeof(DateTimeOffset)
                            ? (DateTimeOffset)reader[columnNames.Contains("ngay_dang") ? "ngay_dang" : columnNames.Last()]
                            : new DateTimeOffset(Convert.ToDateTime(reader[columnNames.Contains("ngay_dang") ? "ngay_dang" : columnNames.Last()]))
                    });
                }
            }
        }
        await conn.CloseAsync();

        var newsList = results.Select(n => new NewsDTO
        {
            TieuDe = n.tieu_de,
            URL = n.url,
            NgayDang = n.ngay_dang.DateTime
        }).ToList();

        return Ok(newsList);
    }

}