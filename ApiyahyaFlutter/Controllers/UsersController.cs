using ApiyahyaFlutter.Data;
using ApiyahyaFlutter.Dto;
using ApiyahyaFlutter.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiyahyaFlutter.Controllers;

[Route("api/users")]
[ApiController]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsersController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/users
    [HttpGet]
    public async Task<ActionResult<IEnumerable<User>>> GetUsers()
    {
        return await _context.Users.ToListAsync();
    }

    // GET: api/users/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<User>> GetUser(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound();
        return user;
    }

    // ✅ POST: api/users - إنشاء مستخدم مع رفع صورة
    [HttpPost]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<User>> AddUser([FromForm] UserCreateDto dto)
    {
        string? imagePath = null;

        if (dto.ProfileImage != null && dto.ProfileImage.Length > 0)
        {
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(dto.ProfileImage.FileName);
            var filePath = Path.Combine(uploadsFolder, fileName);

            try
            {
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await dto.ProfileImage.CopyToAsync(stream);
                }
                imagePath = $"{fileName}";
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
        }

        var user = new User
        {
            Name = dto.Name,
            Email = dto.Email,
            Password = dto.Password,
            ProfileImagePath = imagePath
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
    }


    // PUT: api/users/{id}
    [HttpPut("{id}")]
    public async Task<ActionResult<User>> UpdateUser(int id, [FromBody] User updatedUser)
    {
        if (id != updatedUser.Id)
            return BadRequest("معرف المستخدم غير متطابق");

        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound();

        user.Name = updatedUser.Name;
        user.Email = updatedUser.Email;
        user.Password = updatedUser.Password;
        user.ProfileImagePath = updatedUser.ProfileImagePath;

        await _context.SaveChangesAsync();

        return Ok(user);
    }

    // DELETE: api/users/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound();

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // POST: api/users/login
    [HttpPost("login")]
    public async Task<ActionResult<User>> Login([FromBody] LoginDto loginDto)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == loginDto.Email && u.Password == loginDto.Password);

        if (user == null)
            return Unauthorized();

        return Ok(user);
    }
}
 