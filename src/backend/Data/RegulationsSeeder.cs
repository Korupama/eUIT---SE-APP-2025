using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace eUIT.API.Data;

/// <summary>
/// Seed regulations (van_ban) from PDF files in StaticContent/documents
/// </summary>
public static class RegulationsSeeder
{
    public static async Task SeedRegulationsAsync(IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<eUITDbContext>();

        // Get the StaticContent/documents directory
        var documentsDir = Path.Combine(
            AppContext.BaseDirectory,
            "..", "..", "StaticContent", "documents"
        );

        if (!Directory.Exists(documentsDir))
        {
            Console.WriteLine($"Documents directory not found: {documentsDir}");
            return;
        }

        // Get all PDF files
        var pdfFiles = Directory.GetFiles(documentsDir, "*.pdf")
            .Where(f => !Path.GetFileName(f).StartsWith("."))
            .ToList();

        Console.WriteLine($"Found {pdfFiles.Count} PDF files to seed");

        if (pdfFiles.Count == 0)
        {
            return;
        }

        // Insert regulations
        var insertedCount = 0;
        foreach (var pdfPath in pdfFiles)
        {
            var fileName = Path.GetFileName(pdfPath);
            var nameWithoutExt = Path.GetFileNameWithoutExtension(pdfPath);

            // Check if already exists
            var existing = await context.Database
                .ExecuteSqlInterpolatedAsync(
                    $"SELECT 1 FROM van_ban WHERE ten_van_ban = {nameWithoutExt} LIMIT 1"
                );

            if (existing == 0)
            {
                // Insert new regulation
                await context.Database
                    .ExecuteSqlInterpolatedAsync(
                        $"""
                        INSERT INTO van_ban (ten_van_ban, url_van_ban, ngay_ban_hanh)
                        VALUES ({nameWithoutExt}, {fileName}, NULL)
                        """
                    );
                insertedCount++;
            }
        }

        Console.WriteLine($"Inserted {insertedCount} new regulations");
    }
}
