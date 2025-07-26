using ApiyahyaFlutter.Data;
using ApiyahyaFlutter.Dto;
using ApiyahyaFlutter.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;

namespace ApiyahyaFlutter.Controllers
{
    [Route("api/GetAll")]
    [ApiController]
  
    public class GetAllController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IWebHostEnvironment _environment;
        public GetAllController(AppDbContext context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        // ====== Product CRUD ======

        [HttpGet("products")]
        public async Task<List<ProductDto>> GetProductsAsync()
        {
            var products = await _context.Products
                .Include(p => p.Category)  // تضمين بيانات التصنيف المرتبط بكل منتج
                .Select(p => new ProductDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category.Name,
                    ImageUrl = p.ImageUrl
                })
                .ToListAsync();

            return products;
        }

        [HttpGet("products/{id}")]
        public async Task<ActionResult<Product>> GetProductByIdAsync(int id)
        {
            var product = await _context.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.Id == id);
            if (product == null) return NotFound();
            return product;
        }

        [HttpPost("products")]
        [Consumes("multipart/form-data")]
        public async Task<ActionResult<Product>> AddProductWithImageAsync([FromForm] ProductCreateDto dto)
        {
            string? imagePath = null;

            if (dto.Image != null && dto.Image.Length > 0)
            {
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
                if (!Directory.Exists(uploadsFolder))
                    Directory.CreateDirectory(uploadsFolder);

                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(dto.Image.FileName)}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                try
                {
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await dto.Image.CopyToAsync(stream);
                    }
                    imagePath = $"uploads/{fileName}";
                    Console.WriteLine($"Image saved at: {filePath}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error saving image: {ex.Message}");
                    return BadRequest("خطأ في حفظ الصورة");
                }
            }
            else
            {
                Console.WriteLine("No image uploaded");
                return BadRequest("الصورة غير مرفقة");
            }

            var product = new Product
            {
                Name = dto.Name,
                Description = dto.Description,
                Price = dto.Price,
                CategoryId = dto.CategoryId,
                ImageUrl = imagePath
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetProductByIdAsync), new { id = product.Id }, product);
        }




        [HttpPut("products/{id}")]
        public async Task<IActionResult> UpdateProductAsync(int id, [FromForm] ProductUpdateDto dto)
        {
            if (id != dto.Id)
                return BadRequest();

            var existingProduct = await _context.Products.FindAsync(id);
            if (existingProduct == null) return NotFound();

            existingProduct.Name = dto.Name;
            existingProduct.Description = dto.Description;
            existingProduct.Price = dto.Price;
            existingProduct.CategoryId = dto.CategoryId;

            if (dto.Image != null)
            {
                var imageUrl = await SaveImageAsync(dto.Image);
                existingProduct.ImageUrl = imageUrl;
            }

            await _context.SaveChangesAsync();

            return Ok(existingProduct); // <- ترجع المنتج بعد التعديل
        }

        private async Task<string> SaveImageAsync(IFormFile image)
        {
            if (image == null || image.Length == 0)
                return null;

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");

            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            var uniqueFileName = Guid.NewGuid().ToString() + Path.GetExtension(image.FileName);
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await image.CopyToAsync(fileStream);
            }

            return "uploads/" + uniqueFileName;
        }

        [HttpDelete("products/{id}")]
        public async Task<IActionResult> DeleteProductAsync(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        // ====== Category CRUD ======

        [HttpGet("categories")]
        public async Task<List<Category>> GetCategoriesAsync()
        {
            return await _context.Categorys.ToListAsync();
        }

        [HttpGet("categories/{id}")]
        public async Task<ActionResult<Category>> GetCategoryByIdAsync(int id)
        {
            var category = await _context.Categorys.FindAsync(id);
            if (category == null) return NotFound();
            return category;
        }

        [HttpPost("categories")]
        public async Task<ActionResult<Category>> AddCategoryAsync(Category category)
        {
            _context.Categorys.Add(category);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetCategoryByIdAsync), new { id = category.Id }, category);
        }


        [HttpPut("categories/{id}")]
        public async Task<IActionResult> UpdateCategoryAsync(int id, Category category)
        {
            if (id != category.Id) return BadRequest();

            var existingCategory = await _context.Categorys.FindAsync(id);
            if (existingCategory == null) return NotFound();

            existingCategory.Name = category.Name;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("categories/{id}")]
        public async Task<IActionResult> DeleteCategoryAsync(int id)
        {
            var category = await _context.Categorys.FindAsync(id);
            if (category == null) return NotFound();

            _context.Categorys.Remove(category);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        // ====== Coolor CRUD ======

        [HttpGet("coolors")]
        public async Task<List<Coolor>> GetCoolorsAsync()
        {
            return await _context.Coolors.ToListAsync();
        }

        [HttpGet("coolors/{id}")]
        public async Task<ActionResult<Coolor>> GetCoolorByIdAsync(int id)
        {
            var coolor = await _context.Coolors.FindAsync(id);
            if (coolor == null) return NotFound();
            return coolor;
        }

        [HttpPost("coolors")]
        public async Task<ActionResult<Coolor>> AddCoolorAsync(Coolor coolor)
        {
            _context.Coolors.Add(coolor);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetCoolorByIdAsync), new { id = coolor.Id }, coolor);
        }

        [HttpPut("coolors/{id}")]
        public async Task<IActionResult> UpdateCoolorAsync(int id, Coolor coolor)
        {
            if (id != coolor.Id) return BadRequest();

            var existing = await _context.Coolors.FindAsync(id);
            if (existing == null) return NotFound();

            existing.Name = coolor.Name;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("coolors/{id}")]
        public async Task<IActionResult> DeleteCoolorAsync(int id)
        {
            var coolor = await _context.Coolors.FindAsync(id);
            if (coolor == null) return NotFound();

            _context.Coolors.Remove(coolor);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        // ====== Siize CRUD ======

        [HttpGet("siizes")]
        public async Task<List<Siize>> GetSiizesAsync()
        {
            return await _context.Siizes.ToListAsync();
        }

        [HttpGet("siizes/{id}")]
        public async Task<ActionResult<Siize>> GetSiizeByIdAsync(int id)
        {
            var siize = await _context.Siizes.FindAsync(id);
            if (siize == null) return NotFound();
            return siize;
        }

        [HttpPost("siizes")]
        public async Task<ActionResult<Siize>> AddSiizeAsync(Siize siize)
        {
            _context.Siizes.Add(siize);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetSiizeByIdAsync), new { id = siize.Id }, siize);
        }

        [HttpPut("siizes/{id}")]
        public async Task<IActionResult> UpdateSiizeAsync(int id, Siize size)
        {
            if (id != size.Id) return BadRequest();

            var existingSize = await _context.Siizes.FindAsync(id);
            if (existingSize == null) return NotFound();

            existingSize.Name = size.Name;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("siizes/{id}")]
        public async Task<IActionResult> DeleteSiizeAsync(int id)
        {
            var siize = await _context.Siizes.FindAsync(id);
            if (siize == null) return NotFound();

            _context.Siizes.Remove(siize);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        // ====== Inventory CRUD ======

        [HttpGet("inventories")]
        public async Task<ActionResult<List<InventoryDto>>> GetInventoriesAsync()
        {
            var inventories = await _context.Inventorys
                .Include(i => i.Product)
                .Include(i => i.Coolor)
                .Include(i => i.Siize)
                .Select(i => new InventoryDto
                {
                    Id = i.Id,
                    ProductId = i.ProductId,
                    ProductName = i.Product.Name,
                    ProductImageUrl = i.Product.ImageUrl,  // تأكد أن الحقل اسمه هكذا أو عدله حسب الاسم الصحيح في الـ Product
                    CoolorId = i.CoolorId,
                    CoolorName = i.Coolor.Name,
                    SiizeId = i.SiizeId,
                    SiizeName = i.Siize.Name,
                    Quantity = i.Quantity
                }).ToListAsync();

            return inventories;
        }



        [HttpGet("inventories/{id}")]
        public async Task<ActionResult<Inventory>> GetInventoryByIdAsync(int id)
        {
            var inventory = await _context.Inventorys
                .Include(i => i.Product)
                .Include(i => i.Coolor)
                .Include(i => i.Siize)
                .FirstOrDefaultAsync(i => i.Id == id);
            if (inventory == null) return NotFound();
            return inventory;
        }

        [HttpPost("inventories")]
        public async Task<ActionResult<Inventory>> AddInventoryAsync(InventoryCreateDto dto)
        {
            // البحث عن مخزون مطابق بنفس المنتج، اللون، المقاس فقط
            var existingInventory = await _context.Inventorys
                .FirstOrDefaultAsync(i =>
                    i.ProductId == dto.ProductId &&
                    i.CoolorId == dto.CoolorId &&
                    i.SiizeId == dto.SiizeId
                );

            if (existingInventory != null)
            {
                existingInventory.Quantity += dto.Quantity;
                await _context.SaveChangesAsync();
                return Ok(existingInventory);
            }
            else
            {
                var inventory = new Inventory
                {
                    ProductId = dto.ProductId,
                    CoolorId = dto.CoolorId,
                    SiizeId = dto.SiizeId,
                    Quantity = dto.Quantity,
                };

                _context.Inventorys.Add(inventory);
                await _context.SaveChangesAsync();

                return CreatedAtAction(nameof(GetInventoryByIdAsync), new { id = inventory.Id }, inventory);
            }
        }



        [HttpPut("inventories/{id}")]
        public async Task<IActionResult> UpdateInventoryAsync(int id, Inventory inventory)
        {
            if (id != inventory.Id) return BadRequest();

            var existingInventory = await _context.Inventorys.FindAsync(id);
            if (existingInventory == null) return NotFound();

            existingInventory.ProductId = inventory.ProductId;
            existingInventory.CoolorId = inventory.CoolorId;
            existingInventory.SiizeId = inventory.SiizeId;
            existingInventory.Quantity = inventory.Quantity;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("inventories/{id}")]
        public async Task<IActionResult> DeleteInventoryAsync(int id)
        {
            var inventory = await _context.Inventorys.FindAsync(id);
            if (inventory == null) return NotFound();

            _context.Inventorys.Remove(inventory);
            await _context.SaveChangesAsync();
            return NoContent();
        }


        // ====== StockMovement CRUD ======
        [HttpGet("stockmovements")]
        public async Task<ActionResult<List<StockMovementDto>>> GetStockMovementsAsync(
        [FromQuery] int? inventoryId = null,
        [FromQuery] int? movementType = null)
        {
            var query = _context.StockMovements
                .Include(sm => sm.Inventory)
                    .ThenInclude(i => i.Product)
                .AsQueryable();

            if (inventoryId.HasValue)
            {
                query = query.Where(sm => sm.InventoryId == inventoryId.Value);
            }

            if (movementType.HasValue)
            {
                if (movementType == 1)
                    query = query.Where(sm => sm.Quantity > 0);
                else if (movementType == -1)
                    query = query.Where(sm => sm.Quantity < 0);
            }

            var movements = await query.Select(sm => new StockMovementDto
            {
                Id = sm.Id,
                InventoryId = sm.InventoryId,
                Quantity = sm.Quantity,
                Notes = sm.Notes,
                MovementDate = sm.MovementDate,
                ProductId = sm.Inventory.Product.Id,
                ProductName = sm.Inventory.Product.Name
            }).ToListAsync();

            // الترتيب: حسب المخزون ثم النوع (الإرجاع أولاً)
            var orderedMovements = movements
                .OrderBy(m => m.InventoryId)
                .ThenBy(m => m.Quantity > 0 ? 1 : 0) // الإرجاع أولًا ثم الإضافة
                .ThenByDescending(m => m.MovementDate) // ترتيب زمني داخل كل نوع
                .ToList();

            return Ok(orderedMovements);
        }




        [HttpGet("stockmovements/{id}")]
        public async Task<ActionResult<StockMovement>> GetStockMovementByIdAsync(int id)
        {
            var stockMovement = await _context.StockMovements
                .Include(sm => sm.Inventory)
                    .ThenInclude(i => i.Product)
                .FirstOrDefaultAsync(sm => sm.Id == id);
            if (stockMovement == null) return NotFound();
            return stockMovement;
        }
        [HttpPost("stockmovements")]
        public async Task<ActionResult<StockMovementDtocrud>> AddStockMovementAsync(StockMovementDtocrud dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (dto.Quantity == 0)
            {
                return BadRequest("الكمية يجب أن تكون غير صفر");
            }

            var inventory = await _context.Inventorys.FindAsync(dto.InventoryId);
            if (inventory == null)
            {
                return NotFound("المخزون غير موجود");
            }

            int newQuantity = inventory.Quantity + dto.Quantity;

            // منع الكمية السالبة
            if (newQuantity < 0)
            {
                return BadRequest("الكمية في المخزون غير كافية لإجراء هذه العملية");
            }

            // البحث عن حركات سابقة من نفس النوع ونفس الـ InventoryId
            var existingMovements = await _context.StockMovements
                .Where(sm => sm.InventoryId == dto.InventoryId
                          && ((sm.Quantity > 0 && dto.Quantity > 0) || (sm.Quantity < 0 && dto.Quantity < 0)))
                .ToListAsync();

            int totalQuantity = dto.Quantity;
            if (existingMovements.Any())
            {
                totalQuantity += existingMovements.Sum(sm => sm.Quantity);

                // حذف الحركات القديمة
                _context.StockMovements.RemoveRange(existingMovements);
            }

            // إنشاء الحركة الجديدة الموحدة
            var stockMovement = new StockMovement
            {
                InventoryId = dto.InventoryId,
                Notes = dto.Notes ?? (existingMovements.Any() ? "تم دمج الحركات السابقة" : null),
                MovementDate = DateTime.UtcNow,
                Quantity = totalQuantity,
            };

            _context.StockMovements.Add(stockMovement);

            if (newQuantity == 0)
            {
                _context.Inventorys.Remove(inventory);
            }
            else
            {
                inventory.Quantity = newQuantity;
            }

            await _context.SaveChangesAsync();

            var resultDto = new StockMovementDto
            {
                Id = stockMovement.Id,
                InventoryId = stockMovement.InventoryId,
                Quantity = stockMovement.Quantity,
                Notes = stockMovement.Notes,
            };

            return Ok(resultDto);
        }




        [HttpPut("stockmovements/{id}")]
        public async Task<IActionResult> UpdateStockMovementAsync(int id, StockMovement stockMovement)
        {
            if (id != stockMovement.Id) return BadRequest();

            var existing = await _context.StockMovements
                .FirstOrDefaultAsync(sm => sm.Id == stockMovement.Id);

            if (existing == null) return NotFound();

            var inventory = await _context.Inventorys.FindAsync(stockMovement.InventoryId);
            if (inventory != null)
            {
                // تعديل كمية المخزون بناءً على الفرق بين القديم والجديد
                inventory.Quantity = inventory.Quantity - existing.Quantity + stockMovement.Quantity;
            }

            // تحديث خصائص الحركة
            existing.InventoryId = stockMovement.InventoryId;
            existing.Quantity = stockMovement.Quantity;
            existing.MovementDate = stockMovement.MovementDate;
            existing.Notes = stockMovement.Notes;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("stockmovements/{id}")]
        public async Task<IActionResult> DeleteStockMovementAsync(int id)
        {
            var stockMovement = await _context.StockMovements.FindAsync(id);
            if (stockMovement == null) return NotFound();

            var inventory = await _context.Inventorys.FindAsync(stockMovement.InventoryId);
            if (inventory != null)
            {
                inventory.Quantity -= stockMovement.Quantity;
            }

            _context.StockMovements.Remove(stockMovement);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
