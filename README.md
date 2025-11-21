# eUIT - SE APP 2025

Mobile application project with .NET backend and PostgreSQL database.

## 📚 Tài liệu / Documentation

### Kết nối Cơ sở dữ liệu / Database Connection
- **[Hướng dẫn nhanh (Vietnamese)](docs/DATABASE_CONNECTION_QUICK.md)** - Câu trả lời cho "kết nối csdl ở file nào?"
- **[Chi tiết đầy đủ / Full Documentation](docs/DATABASE_CONNECTION.md)** - Detailed database connection guide

## 🏗️ Kiến trúc / Architecture

- **.NET 9 Web API** - Backend
- **PostgreSQL** - Database with Entity Framework Core
- **React Native/Flutter** - Mobile frontend
- **Docker** - Containerization support

## 📁 Cấu trúc thư mục / Project Structure

```
eUIT---SE-APP-2025/
├── src/
│   ├── backend/              # .NET Web API
│   │   ├── Controllers/      # API Controllers
│   │   ├── Data/            # DbContext và Database models
│   │   ├── DTOs/            # Data Transfer Objects
│   │   ├── Services/        # Business logic services
│   │   ├── Program.cs       # ⭐ Cấu hình kết nối database
│   │   ├── appsettings.json # ⭐ File cấu hình kết nối CSDL
│   │   └── appsettings.Example.json
│   └── mobile/              # Mobile app
├── docs/                    # Documentation
└── tests/                   # Unit tests
```

## ⚙️ Thiết lập / Setup

### Yêu cầu / Prerequisites
- .NET 9 SDK
- PostgreSQL 15+
- Node.js (for mobile development)

### 1. Clone repository
```bash
git clone https://github.com/Korupama/eUIT---SE-APP-2025.git
cd eUIT---SE-APP-2025
```

### 2. Cấu hình Database / Database Configuration

**Bước 1:** Tạo file cấu hình từ file mẫu
```bash
cd src/backend
cp appsettings.Example.json appsettings.json
```

**Bước 2:** Chỉnh sửa `appsettings.json` với thông tin PostgreSQL của bạn:
```json
{
  "ConnectionStrings": {
    "eUITDatabase": "Server=localhost;Port=5432;Database=eUIT;User Id=postgres;Password=YOUR_PASSWORD;"
  }
}
```

**Bước 3:** Tạo database
```sql
CREATE DATABASE eUIT;
```

**Xem thêm:** [Hướng dẫn chi tiết về kết nối database](docs/DATABASE_CONNECTION.md)

### 3. Chạy Backend / Run Backend
```bash
cd src/backend
dotnet restore
dotnet build
dotnet run
```

API sẽ chạy tại: `http://localhost:5128`

Swagger UI: `http://localhost:5128/swagger`

### 4. Chạy Mobile App / Run Mobile App
```bash
cd src/mobile
npm install
npm start
```

## 🔑 File cấu hình quan trọng / Important Configuration Files

| File | Mô tả | Committed to Git |
|------|-------|------------------|
| `src/backend/appsettings.json` | ⭐ **File cấu hình chính** chứa connection string | ❌ No (in .gitignore) |
| `src/backend/appsettings.Example.json` | File mẫu để tham khảo | ✅ Yes |
| `src/backend/Program.cs` | Nơi đọc và sử dụng connection string | ✅ Yes |
| `src/backend/Data/eUITDbContext.cs` | DbContext làm việc với database | ✅ Yes |

## �� Các lệnh hữu ích / Useful Commands

### Backend
```bash
# Build project
dotnet build

# Run project
dotnet run

# Run with watch (auto-reload)
dotnet watch run

# Entity Framework migrations
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### Database
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE eUIT;

# List databases
\l

# Connect to eUIT database
\c eUIT
```

## 📖 API Documentation

Khi backend đang chạy, truy cập Swagger UI tại:
```
http://localhost:5128/swagger
```

## 🔒 Bảo mật / Security

⚠️ **QUAN TRỌNG / IMPORTANT:**
- ❌ **KHÔNG** commit file `appsettings.json` vào git
- ❌ **KHÔNG** chia sẻ mật khẩu database
- ✅ Sử dụng environment variables cho production
- ✅ Thay đổi JWT Key mặc định trong production

## 🤝 Đóng góp / Contributing

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📝 License

[Add license information here]

## 👥 Team

eUIT Development Team - SE APP 2025

## 🆘 Hỗ trợ / Support

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra [Database Connection Documentation](docs/DATABASE_CONNECTION.md)
2. Tạo issue trên GitHub
3. Liên hệ team

---

**Ghi chú:** File này được tạo tự động để trả lời câu hỏi "kết nối csdl ở file nào?"
