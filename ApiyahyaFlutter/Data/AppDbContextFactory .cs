using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace ApiyahyaFlutter.Data
{
    public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
    {
        public AppDbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<AppDbContext>();
            string dbPath = System.IO.Path.Combine(System.IO.Directory.GetCurrentDirectory(), "yahya.db");
            optionsBuilder.UseSqlite($"Filename={dbPath}");

            return new AppDbContext(optionsBuilder.Options);
        }
    }
}
