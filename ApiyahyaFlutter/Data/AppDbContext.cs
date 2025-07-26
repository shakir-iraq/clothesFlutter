using Microsoft.EntityFrameworkCore;
using ApiyahyaFlutter.Model;

namespace ApiyahyaFlutter.Data
{
    public class AppDbContext : DbContext
    {
        public DbSet<Product> Products => Set<Product>();
        public DbSet<Inventory> Inventorys => Set<Inventory>();
        public DbSet<StockMovement> StockMovements => Set<StockMovement>();
        public DbSet<Siize> Siizes => Set<Siize>();
        public DbSet<Coolor> Coolors => Set<Coolor>();
        public DbSet<Category> Categorys => Set<Category>();
        public DbSet<User> Users => Set<User>();

        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }
    }
}
