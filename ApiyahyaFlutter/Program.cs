using ApiyahyaFlutter.Data;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi.Models;
using System.IO;

var builder = WebApplication.CreateBuilder(args);

// إضافة خدمات التحكم (Controllers)
builder.Services.AddControllers();

// إعداد سياسة CORS للسماح لأي أصل
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// زيادة حد حجم رفع الملفات إلى 100 ميجابايت
builder.Services.Configure<FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = 104_857_600; // 100 MB
});

// تحديد مسار قاعدة بيانات SQLite
string dbPath = Path.Combine(Directory.GetCurrentDirectory(), "yahya.db");

// تسجيل DbContext مع SQLite
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite($"Filename={dbPath}"));

// تعيين عنوان الاستضافة (IP + Port)
builder.WebHost.UseUrls("http://192.168.18.3:7045");

// إضافة Swagger لتوثيق الـ API
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "My API", Version = "v1" });
});

var app = builder.Build();

// إنشاء قاعدة البيانات إذا لم تكن موجودة
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}

// ** استضافة الملفات الثابتة من مجلد خارجي **
var uploadsFolder = @"D:\Apps\ApiyahyaFlutter\wwwroot\uploads";
if (!Directory.Exists(uploadsFolder))
{
    Directory.CreateDirectory(uploadsFolder);
}

// Middleware للسماح بتحميل ملفات الصور من أي أصل (CORS للملفات الثابتة)
app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/uploads"))
    {
        context.Response.Headers.Add("Access-Control-Allow-Origin", "*");
    }
    await next();
});

// ملفات static من wwwroot
app.UseStaticFiles();

// ملفات static من مجلد الصور uploads
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsFolder),
    RequestPath = "/uploads"
});

// تفعيل Swagger في بيئة التطوير فقط
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// تفعيل CORS
app.UseCors("AllowAll");

// إذا تريد تفعيل الـ HTTPS ضع التعليق التالي مفكوكاً مع إعداد الشهادة
// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
