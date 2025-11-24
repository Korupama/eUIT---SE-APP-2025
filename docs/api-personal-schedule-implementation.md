# API Documentation - Personal Schedule Management

## Overview
API endpoints để quản lý lịch cá nhân của sinh viên, bao gồm tạo, chỉnh sửa và xóa các sự kiện cá nhân.

## Authentication
Tất cả các endpoints đều yêu cầu JWT token trong header:
```
Authorization: Bearer <your_jwt_token>
```

## Endpoints

### 1. POST /api/student/schedule/personal
Thêm sự kiện mới vào lịch cá nhân.

**Request Body:**
```json
{
  "eventName": "string (required, max 255 chars)",
  "time": "datetime (required)",
  "location": "string (optional, max 255 chars)",
  "description": "string (optional)"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Tạo sự kiện thành công",
  "event": {
    "eventId": 1,
    "eventName": "Họp nhóm đồ án",
    "time": "2025-11-25T14:00:00",
    "location": "Phòng E205",
    "description": "Họp bàn về tiến độ đồ án",
    "createdAt": "2025-11-24T10:00:00",
    "updatedAt": "2025-11-24T10:00:00"
  },
  "conflict": null
}
```

**Conflict Warning Response:**
```json
{
  "success": true,
  "message": "Sự kiện đã được tạo nhưng có xung đột với lịch học",
  "event": { ... },
  "conflict": {
    "hasConflict": true,
    "conflictType": "class",  // "class" hoặc "exam"
    "conflictDetails": "Công nghệ phần mềm (SE101.N11) - Tiết 7-9, Phòng E205"
  }
}
```

**Error Responses:**
- `400 Bad Request`: Dữ liệu không hợp lệ (thiếu trường bắt buộc, vượt quá độ dài)
- `401 Unauthorized`: Chưa đăng nhập
- `500 Internal Server Error`: Lỗi server

**Edge Cases:**
- Hệ thống sẽ kiểm tra và cảnh báo nếu sự kiện trùng thời gian với lịch học hoặc lịch thi
- Cảnh báo chỉ mang tính thông báo, sự kiện vẫn được tạo thành công

---

### 2. PUT /api/student/schedule/personal/{event_id}
Chỉnh sửa thông tin sự kiện cá nhân đã có.

**Path Parameters:**
- `event_id`: ID của sự kiện cần chỉnh sửa

**Request Body:**
```json
{
  "eventName": "string (optional, max 255 chars)",
  "time": "datetime (optional)",
  "location": "string (optional, max 255 chars)",
  "description": "string (optional)"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật sự kiện thành công",
  "event": {
    "eventId": 1,
    "eventName": "Họp nhóm đồ án (Lần 2)",
    "time": "2025-11-25T16:00:00",
    "location": "Phòng E206",
    "description": "Họp bàn về tiến độ đồ án - Thảo luận về demo",
    "createdAt": "2025-11-24T10:00:00",
    "updatedAt": "2025-11-24T10:15:00"
  },
  "conflict": null
}
```

**Error Responses:**
- `400 Bad Request`: Dữ liệu không hợp lệ
- `401 Unauthorized`: Chưa đăng nhập
- `404 Not Found`: Không tìm thấy sự kiện hoặc không có quyền chỉnh sửa
- `500 Internal Server Error`: Lỗi server

**Edge Cases:**
- Chỉ các trường được cung cấp trong request body mới được cập nhật
- Nếu thay đổi thời gian, hệ thống sẽ kiểm tra xung đột với lịch học/thi
- Sinh viên chỉ có thể chỉnh sửa sự kiện của chính mình
- Trường `updatedAt` tự động được cập nhật

---

### 3. DELETE /api/student/schedule/personal/{event_id}
Xóa sự kiện cá nhân.

**Path Parameters:**
- `event_id`: ID của sự kiện cần xóa

**Response:**
```json
{
  "success": true,
  "message": "Xóa sự kiện thành công"
}
```

**Error Responses:**
- `401 Unauthorized`: Chưa đăng nhập
- `404 Not Found`: Không tìm thấy sự kiện hoặc không có quyền xóa
- `500 Internal Server Error`: Lỗi server

**Edge Cases:**
- Sinh viên chỉ có thể xóa sự kiện của chính mình
- Sau khi xóa, dữ liệu sẽ bị xóa vĩnh viễn khỏi database

---

## Business Rules

### Conflict Detection
Hệ thống kiểm tra xung đột thời gian với:
1. **Lịch học**: Dựa trên thời khóa biểu đã đăng ký
   - Kiểm tra ngày học (thứ 2-8)
   - Kiểm tra khoảng thời gian tiết học
   - Tính toán cách tuần (nếu có)

2. **Lịch thi**: Dựa trên lịch thi đã công bố
   - Kiểm tra ngày thi
   - Cảnh báo nếu trùng ca thi

### Authorization
- Mỗi sinh viên chỉ có thể quản lý (tạo/sửa/xóa) sự kiện của chính mình
- Hệ thống tự động lấy MSSV từ JWT token để đảm bảo bảo mật

### Data Validation
- `eventName`: Bắt buộc, tối đa 255 ký tự
- `time`: Bắt buộc, định dạng datetime
- `location`: Không bắt buộc, tối đa 255 ký tự
- `description`: Không bắt buộc, không giới hạn độ dài

---

## Database Schema

### Table: personal_events
```sql
CREATE TABLE personal_events (
    event_id SERIAL PRIMARY KEY,
    mssv INTEGER NOT NULL,
    event_name VARCHAR(255) NOT NULL,
    time TIMESTAMP NOT NULL,
    location VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv) ON DELETE CASCADE
);
```

**Indexes:**
- `idx_personal_events_mssv` on `mssv`
- `idx_personal_events_time` on `time`

**Triggers:**
- Auto-update `updated_at` on record update

---

## Testing

Xem file `api-personal-schedule-endpoints.http` để có các ví dụ cụ thể về cách test các endpoints.

**Test Scenarios:**
1. ✅ Tạo sự kiện không có xung đột
2. ✅ Tạo sự kiện có xung đột với lịch học
3. ✅ Tạo sự kiện có xung đột với lịch thi
4. ✅ Cập nhật toàn bộ thông tin sự kiện
5. ✅ Cập nhật một phần thông tin sự kiện
6. ✅ Xóa sự kiện thành công
7. ❌ Cập nhật sự kiện không tồn tại (404)
8. ❌ Xóa sự kiện không tồn tại (404)
9. ❌ Tạo sự kiện thiếu trường bắt buộc (400)
10. ❌ Cập nhật/xóa sự kiện của người khác (404)

---

## Implementation Notes

### Files Modified/Created:
1. **Models/PersonalEvent.cs**: Entity model cho personal events
2. **DTOs/PersonalEventDto.cs**: DTOs cho request/response
3. **Data/eUITDbContext.cs**: Thêm DbSet cho PersonalEvents
4. **Controllers/ScheduleController.cs**: Implement 3 endpoints mới
5. **scripts/database/sql/personal_events.sql**: SQL migration script

### Key Features:
- ✅ JWT Authentication
- ✅ Conflict detection với lịch học và lịch thi
- ✅ Partial update support
- ✅ Soft validation (warning only, không block)
- ✅ Auto-update timestamps
- ✅ Authorization check (chỉ sửa/xóa sự kiện của mình)

---

## Migration Steps

1. Chạy SQL script để tạo bảng:
```bash
psql -U your_user -d your_database -f scripts/database/sql/personal_events.sql
```

2. Khởi động lại API server

3. Test các endpoints bằng file `.http` hoặc Postman

---

## Future Enhancements

Các tính năng có thể mở rộng:
- [ ] GET endpoint để lấy danh sách personal events
- [ ] Pagination cho danh sách events
- [ ] Filter events theo ngày/tuần/tháng
- [ ] Reminder/notification cho events
- [ ] Recurring events (sự kiện lặp lại)
- [ ] Export calendar to iCal format
- [ ] Share events với sinh viên khác
