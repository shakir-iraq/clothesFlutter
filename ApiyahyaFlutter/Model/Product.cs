
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiyahyaFlutter.Model
{
    
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public int CategoryId { get; set; }
        public Category Category { get; set; } = null!;
        public string? ImageUrl { get; set; }
     
        public ICollection<Inventory> Inventories { get; set; } = new List<Inventory>();
    }

    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;

        public ICollection<Product> Products { get; set; } = new List<Product>();
    }

    public class Coolor
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;

        public ICollection<Inventory> Inventories { get; set; } = new List<Inventory>();
    }

    public class Siize
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;

        public ICollection<Inventory> Inventories { get; set; } = new List<Inventory>();
    }

    public class Inventory
    {
        public int Id { get; set; }

        public int ProductId { get; set; }
        public Product? Product { get; set; } = null!;

        public int CoolorId { get; set; }
        public Coolor? Coolor { get; set; } = null!;

        public int SiizeId { get; set; }
        public Siize? Siize { get; set; } = null!;

        public int Quantity { get; set; }

        public ICollection<StockMovement?> StockMovements { get; set; } = new List<StockMovement>();
    }

    public class StockMovement
    {
        public int  Id { get; set; }
        public int InventoryId { get; set; }
        public Inventory Inventory { get; set; } = null!;
        public DateTime? MovementDate { get; set; }
        public int Quantity { get; set; }  // موجب أو سالب حسب نوع الحركة
        public string? Notes { get; set; }
    }



    public class User
    {
        public int Id { get; set; }  // EF Core يفهمها كمفتاح تلقائي
        public string Name { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string? ProfileImagePath { get; set; }  // مسار الصورة وليس الصورة نفسها
    }

}
