# 📍 TÀI LIỆU NHANH: KẾT NỐI CƠ SỞ DỮ LIỆU

## Câu hỏi: "kết nối csdl ở file nào?"

### ✅ CÁC FILE QUAN TRỌNG:

#### 1️⃣ **File cấu hình chính:** 
📁 `src/backend/appsettings.json`
- Chứa chuỗi kết nối database
- Chứa cấu hình JWT
- **File này đã được tạo sẵn**

#### 2️⃣ **File sử dụng kết nối:**
📁 `src/backend/Program.cs`
- Dòng 35: Đọc connection string từ appsettings.json
- Dòng 38-39: Cấu hình kết nối với PostgreSQL

#### 3️⃣ **File DbContext:**
📁 `src/backend/Data/eUITDbContext.cs`
- Định nghĩa cách ứng dụng làm việc với database

#### 4️⃣ **File mẫu (tham khảo):**
📁 `src/backend/appsettings.Example.json`
- File mẫu để tham khảo
- KHÔNG chỉnh sửa file này

---

## 🔧 CHUỖI KẾT NỐI HIỆN TẠI:

Trong file `src/backend/appsettings.json`:

```json
"ConnectionStrings": {
  "eUITDatabase": "Server=localhost;Port=5432;Database=eUIT;User Id=postgres;Password=YOUR_PASSWORD;"
}
```

### Ý nghĩa các tham số:
- **Server=localhost**: Database ở máy local
- **Port=5432**: Cổng mặc định của PostgreSQL
- **Database=eUIT**: Tên database là "eUIT"
- **User Id=postgres**: Username đăng nhập PostgreSQL
- **Password=YOUR_PASSWORD**: Mật khẩu PostgreSQL của bạn

---

## 🚀 CÁCH SỬA ĐỔI KẾT NỐI:

1. Mở file: `src/backend/appsettings.json`
2. Tìm đến phần `ConnectionStrings`
3. Sửa các thông tin:
   - Đổi `Server` nếu database ở server khác
   - Đổi `Port` nếu PostgreSQL dùng cổng khác
   - Đổi `Database` nếu muốn dùng database khác
   - Đổi `User Id` và `Password` theo tài khoản PostgreSQL của bạn

---

## 📖 TÀI LIỆU CHI TIẾT:

Xem thêm tài liệu đầy đủ tại: `/docs/DATABASE_CONNECTION.md`

---

## ⚠️ LƯU Ý QUAN TRỌNG:

1. ✅ File `appsettings.json` đã được thêm vào .gitignore
2. ✅ KHÔNG commit file này lên git (có chứa mật khẩu)
3. ✅ Nếu làm việc nhóm, mỗi người cần tạo file appsettings.json riêng
4. ✅ Đối với production, nên dùng environment variables thay vì hardcode password

---

## 🔍 CÁCH KIỂM TRA KẾT NỐI:

1. Đảm bảo PostgreSQL đang chạy
2. Chạy lệnh:
```bash
cd src/backend
dotnet run
```
3. Nếu không có lỗi về database connection => Kết nối thành công ✅

---

**Tóm lại:** Kết nối cơ sở dữ liệu được cấu hình chủ yếu ở file `src/backend/appsettings.json` và được sử dụng trong `src/backend/Program.cs`.
