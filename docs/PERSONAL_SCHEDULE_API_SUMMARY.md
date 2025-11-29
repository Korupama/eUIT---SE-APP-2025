# Personal Schedule API - Quick Reference

## Đã hoàn thành 3 endpoints

### 1. POST /api/student/schedule/personal
**Tạo sự kiện cá nhân mới**

```json
POST /api/student/schedule/personal
Authorization: Bearer <token>

{
  "eventName": "Họp nhóm đồ án",
  "time": "2025-11-25T14:00:00",
  "location": "Phòng E205",
  "description": "Họp bàn về tiến độ"
}
```

✅ **Features:**
- Tự động kiểm tra xung đột với lịch học và lịch thi
- Cảnh báo nhưng vẫn cho phép tạo sự kiện
- Validation đầy đủ cho các trường bắt buộc

---

### 2. PUT /api/student/schedule/personal/{event_id}
**Chỉnh sửa sự kiện (Alternative flow)**

```json
PUT /api/student/schedule/personal/1
Authorization: Bearer <token>

{
  "eventName": "Họp nhóm đồ án (Lần 2)",
  "time": "2025-11-25T16:00:00",
  "location": "Phòng E206"
}
```

✅ **Features:**
- Partial update: chỉ cập nhật trường được cung cấp
- Kiểm tra quyền sở hữu (chỉ sửa sự kiện của mình)
- Kiểm tra xung đột khi thay đổi thời gian
- Auto-update timestamp

---

### 3. DELETE /api/student/schedule/personal/{event_id}
**Xóa sự kiện (Alternative flow)**

```bash
DELETE /api/student/schedule/personal/1
Authorization: Bearer <token>
```

✅ **Features:**
- Kiểm tra quyền sở hữu (chỉ xóa sự kiện của mình)
- Xóa vĩnh viễn khỏi database
- Trả về message xác nhận

---

## Edge Cases Handled

### ✅ Xung đột thời gian
- Kiểm tra trùng với lịch học (thứ, tiết, cách tuần)
- Kiểm tra trùng với lịch thi (ngày, ca thi)
- Cảnh báo chi tiết về xung đột nhưng vẫn cho phép tạo

### ✅ Quyền truy cập
- Chỉ xem/sửa/xóa sự kiện của chính mình
- Tự động lấy MSSV từ JWT token

### ✅ Validation
- Kiểm tra trường bắt buộc (eventName, time)
- Giới hạn độ dài (eventName, location ≤ 255 chars)
- Format datetime hợp lệ

### ✅ Alternative Flows
- PUT: Cho phép chỉnh sửa sự kiện cũ
- DELETE: Cho phép xóa sự kiện cũ
- Partial update trong PUT

---

## Files Created/Modified

```
src/backend/
├── Models/
│   └── PersonalEvent.cs                    ✅ NEW
├── DTOs/
│   └── PersonalEventDto.cs                 ✅ NEW
├── Data/
│   └── eUITDbContext.cs                    ✅ MODIFIED
└── Controllers/
    └── ScheduleController.cs               ✅ MODIFIED

scripts/database/sql/
└── personal_events.sql                     ✅ NEW

docs/
├── api-personal-schedule-endpoints.http    ✅ NEW
└── api-personal-schedule-implementation.md ✅ NEW
```

---

## Database Migration

```bash
# Run this SQL script to create the table
psql -U your_user -d your_database -f scripts/database/sql/personal_events.sql
```

**Table Structure:**
```sql
personal_events
├── event_id (PK, SERIAL)
├── mssv (FK -> sinh_vien.mssv)
├── event_name (VARCHAR(255), NOT NULL)
├── time (TIMESTAMP, NOT NULL)
├── location (VARCHAR(255))
├── description (TEXT)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP, auto-update)
```

---

## Testing

Chi tiết test cases xem trong file:
- `docs/api-personal-schedule-endpoints.http`

**Quick Test:**
1. ✅ POST: Tạo sự kiện mới
2. ✅ PUT: Cập nhật sự kiện
3. ✅ DELETE: Xóa sự kiện
4. ⚠️ Conflict: Test xung đột lịch học/thi
5. ❌ Authorization: Test xóa sự kiện của người khác

---

## Response Examples

### Success (No Conflict)
```json
{
  "success": true,
  "message": "Tạo sự kiện thành công",
  "event": {
    "eventId": 1,
    "eventName": "Họp nhóm đồ án",
    "time": "2025-11-25T14:00:00",
    "location": "Phòng E205",
    "description": "Họp bàn",
    "createdAt": "2025-11-24T10:00:00",
    "updatedAt": "2025-11-24T10:00:00"
  },
  "conflict": null
}
```

### Warning (With Conflict)
```json
{
  "success": true,
  "message": "Sự kiện đã được tạo nhưng có xung đột với lịch học",
  "event": { ... },
  "conflict": {
    "hasConflict": true,
    "conflictType": "class",
    "conflictDetails": "Công nghệ phần mềm (SE101.N11) - Tiết 7-9, Phòng E205"
  }
}
```

### Error (Not Found)
```json
{
  "success": false,
  "message": "Không tìm thấy sự kiện hoặc bạn không có quyền chỉnh sửa"
}
```

---

## Summary

✅ **Đã implement đầy đủ 3 endpoints:**
1. POST - Thêm sự kiện với conflict detection
2. PUT - Chỉnh sửa sự kiện (alternative flow)
3. DELETE - Xóa sự kiện (alternative flow)

✅ **Edge cases đã xử lý:**
- Conflict detection với lịch học/thi
- Authorization (ownership check)
- Validation đầy đủ
- Partial update support

✅ **Database:**
- Table structure hoàn chỉnh
- Indexes tối ưu
- Auto-update timestamps
- Foreign key constraints

🚀 **Ready to use!**
