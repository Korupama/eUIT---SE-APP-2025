using eUIT.API.Models;
using Microsoft.EntityFrameworkCore;

namespace eUIT.API.Data;

public class eUITDbContext : DbContext
{
    public eUITDbContext(DbContextOptions<eUITDbContext> options)
        : base(options)
    {
    }

    public DbSet<ConfirmationLetter> ConfirmationLetters { get; set; }
    public DbSet<LanguageCertificate> LanguageCertificates { get; set; }
    public DbSet<ParkingPass> ParkingPasses { get; set; }
}