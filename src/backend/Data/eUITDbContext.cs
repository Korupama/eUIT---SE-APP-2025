using Microsoft.EntityFrameworkCore;

namespace eUIT.API.Data;

public class eUITDbContext : DbContext
{
    public eUITDbContext(DbContextOptions<eUITDbContext> options) : base(options)
    {

    }

}