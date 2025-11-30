# Git Commit Message

```
feat: Rewrite LecturerController based on real PostgreSQL schema

BREAKING CHANGE: Complete rewrite of LecturerController and LecturerDtos to match actual database schema

## Changes Made

### Controllers
- Replaced LecturerController.cs with schema-accurate version
- All endpoints now use real Vietnamese field names (mssv, ma_lop, ho_ten)
- Removed invented fields (studentId, courseId, fullName)
- Added new endpoints for absence/makeup class management
- Fixed all SQL queries to match actual table structures

### DTOs
- Completely rewrote LecturerDtos.cs with 30+ DTOs
- All DTOs now match real database columns exactly
- Proper nullable types for optional fields
- Correct data types (CHARACTER vs VARCHAR, NUMERIC vs DECIMAL)
- Added DTOs for absence and makeup class features

### Database Functions
- Created lecturer_functions.sql with all required functions
- 20+ PostgreSQL functions for lecturer operations
- All functions use real table names (giang_vien, thoi_khoa_bieu, etc.)
- Proper grade calculation with weights from bang_diem table
- Safe NULL handling throughout

### Tables Used
- giang_vien (lecturer profile)
- thoi_khoa_bieu (schedule)
- mon_hoc (courses)
- ket_qua_hoc_tap (grades)
- bang_diem (grade weights)
- lich_thi (exams)
- sinh_vien (students)
- hoc_phi (tuition)
- appeals (grade appeals)
- confirmation_letters
- bao_nghi_day (absences)
- bao_hoc_bu (makeup classes)

### Documentation
- Created LECTURER_CONTROLLER_REWRITE.md with complete guide
- Documented all endpoints and their real schema mappings
- Added validation checklist and maintenance tips
- Backup created: LecturerController.cs.backup

## Testing Required
- Execute lecturer_functions.sql on PostgreSQL database
- Test all endpoints with valid JWT tokens
- Verify DTOs serialize/deserialize correctly
- Check grade calculations with real data

## Migration Notes
- Old controller used invented fields - incompatible with new version
- API consumers must update to use Vietnamese field names
- All ma_lop parameters are CHARACTER(20) not VARCHAR
- All mssv parameters are INTEGER not STRING

Closes #[ISSUE_NUMBER]
```

---

# Pull Request Description

```markdown
## 🎯 Mục đích
Viết lại hoàn toàn LecturerController và LecturerDtos dựa trên **schema PostgreSQL thực tế**, loại bỏ các field giả định và đảm bảo 100% khớp với cấu trúc database.

## 📝 Các thay đổi chính

### 1. Controller
- ✅ Viết lại toàn bộ `LecturerController.cs`
- ✅ Sử dụng đúng tên cột tiếng Việt từ database
- ✅ Thêm endpoints quản lý báo nghỉ/học bù
- ✅ Xử lý lỗi và logging hoàn chỉnh

### 2. DTOs
- ✅ 30+ DTOs mới dựa trên schema thực
- ✅ Xóa các field không tồn tại (studentId, courseId, fullName)
- ✅ Dùng đúng field từ DB (mssv, ma_lop, ho_ten)
- ✅ Kiểu dữ liệu chính xác (CHARACTER, NUMERIC, INTEGER)

### 3. SQL Functions
- ✅ Tạo file `lecturer_functions.sql` với 20+ functions
- ✅ Tất cả functions dùng đúng tên bảng và cột
- ✅ Tính điểm tổng kết dựa trên trọng số từ `bang_diem`
- ✅ Xử lý NULL an toàn

## 🔍 Các bảng được sử dụng
- `giang_vien`, `thoi_khoa_bieu`, `mon_hoc`
- `ket_qua_hoc_tap`, `bang_diem`, `lich_thi`
- `sinh_vien`, `hoc_phi`, `appeals`
- `confirmation_letters`, `bao_nghi_day`, `bao_hoc_bu`

## 📋 Checklist
- [x] Code build thành công không lỗi
- [x] Tất cả DTOs khớp với schema DB
- [x] SQL functions sử dụng đúng tên bảng/cột
- [x] Tạo backup controller cũ
- [x] Viết documentation đầy đủ
- [ ] Chạy SQL functions trên DB
- [ ] Test tất cả endpoints
- [ ] Verify với data thực

## 🚀 Cách test
```bash
# 1. Chạy SQL functions
psql -U postgres -d your_db -f scripts/database/sql/lecturer_functions.sql

# 2. Test endpoint
curl -X GET "http://localhost:5128/api/lecturer/profile" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## ⚠️ Breaking Changes
- **API consumers phải cập nhật**: Không còn dùng `studentId`, `courseId`
- **Dùng field tiếng Việt**: `mssv`, `ma_lop`, `ho_ten`
- **Kiểu dữ liệu chính xác**: `ma_lop` là `CHARACTER(20)` không phải `string`

## 📚 Documentation
- `docs/LECTURER_CONTROLLER_REWRITE.md` - Hướng dẫn chi tiết
- `scripts/database/sql/lecturer_functions.sql` - Tất cả functions
- Backup: `Controllers/LecturerController.cs.backup`
```

