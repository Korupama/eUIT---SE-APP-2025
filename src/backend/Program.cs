using eUIT.API.Data; // Thêm để "thấy" eUITDbContext
using Microsoft.EntityFrameworkCore; // Thêm để sử dụng UseNpgsql
using Microsoft.AspNetCore.Authentication.JwtBearer; // Thêm để sử dụng JwtBearerDefaults
using Microsoft.IdentityModel.Tokens; // Thêm để sử dụng TokenValidationParameters, SymmetricSecurityKey
using System.Text; // Thêm để sử dụng Encoding.UTF8
using Microsoft.OpenApi.Models;
using Microsoft.Extensions.FileProviders;
using eUIT.API.Services; // Thêm để sử dụng NotificationClient

var builder = WebApplication.CreateBuilder(args);

// --- Thêm dịch vụ vào ứng dụng ---

// Thêm dịch vụ Controllers
builder.Services.AddControllers();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8
                .GetBytes(builder.Configuration["Jwt:Key"])),
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["Jwt:Audience"]
        };
    });

builder.Services.AddScoped<eUIT.API.Services.ITokenService, eUIT.API.Services.TokenService>();

// Thêm Notification Client để gửi thông báo realtime
builder.Services.AddNotificationClient();

// Lấy chuỗi kết nối từ file appsettings.json
var connectionString = builder.Configuration.GetConnectionString("eUITDatabase");

// Thêm dịch vụ DbContext để làm việc với database PostgreSQL
builder.Services.AddDbContext<eUITDbContext>(options =>
    options.UseNpgsql(connectionString));


// Thêm Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    // Định nghĩa Security Scheme cho JWT Bearer
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT"
    });

    // Thêm yêu cầu bảo mật để Swagger UI hiển thị nút Authorize
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// --- Cấu hình pipeline xử lý request ---
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(builder.Environment.ContentRootPath, "StaticContent")),
    RequestPath = "/files"
});

app.UseRouting();


app.UseHttpsRedirection();

app.UseAuthentication(); 
app.UseAuthorization();  

app.MapControllers();


app.Run();

