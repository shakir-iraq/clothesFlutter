using ApiyahyaFlutter.Model;

namespace ApiyahyaFlutter.Dto
{
    public class UserCreateDto
    {
        public string Name { get; set; } = "";
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
        public IFormFile? ProfileImage { get; set; }
    }

    public class LoginDto
    {
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
    }
    public class ProductCreateDto
    {
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public int CategoryId { get; set; }
        public IFormFile? Image { get; set; }
    }

    public class ProductDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = null!;
        public string? ImageUrl { get; set; }
    }
    

public class ProductUpdateDto
    {
        public int Id { get; set; }                  // معرف المنتج
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public int CategoryId { get; set; }

        // هذه خاصية صورة مرفوعة (اختيارية)
        public IFormFile? Image { get; set; }
    }
    public class InventoryCreateDto
    {

        public int ProductId { get; set; }
        public int CoolorId { get; set; }
        public int SiizeId { get; set; }
        public int Quantity { get; set; }
    }

    public class InventoryDto
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string? ProductImageUrl { get; set; }
        public int CoolorId { get; set; }
        public string CoolorName { get; set; }
        public int SiizeId { get; set; }
        public string SiizeName { get; set; }
        public int Quantity { get; set; }
    }

    public class StockMovementDto
    {
        public int Id { get; set; }
        public int InventoryId { get; set; }
        public int Quantity { get; set; }
        public string? Notes { get; set; }
        public DateTime? MovementDate { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; }
      
    }

    public class StockMovementDtocrud
    {
        public int Id { get; set; }
        public int InventoryId { get; set; }
        public int Quantity { get; set; }
        public string? Notes { get; set; }
  

    }
}
