# API Endpoints - Giảng viên (Lecturer)

## Tổng quan
Các endpoint dành cho giảng viên quản lý lớp học, điểm số, phúc khảo, và tài liệu giảng dạy.

**Base URL**: `/api/lecturer`

**Authentication**: Yêu cầu JWT token với role `lecturer`

**Header**: 
```
Authorization: Bearer {token}
```

---

## 1. Quản lý hồ sơ cá nhân

### 1.1. Lấy thông tin hồ sơ giảng viên
**GET** `/api/lecturer/profile`

**Response Success (200)**:
```json
{
  "lecturerId": "GV001",
  "fullName": "Nguyễn Văn A",
  "email": "gv001@uit.edu.vn",
  "phone": "0901234567",
  "department": "Khoa Khoa học Máy tính",
  "faculty": "Công nghệ Thông tin",
  "position": "Giảng viên"
}
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `404 Not Found`: Không tìm thấy profile
- `500 Internal Server Error`: Lỗi server

---

### 1.2. Cập nhật thông tin cá nhân
**PUT** `/api/lecturer/profile`

**Request Body**:
```json
{
  "email": "newemail@uit.edu.vn",
  "phone": "0987654321",
  "department": "Khoa Khoa học Máy tính"
}
```

**Response Success (200)**:
```json
{
  "message": "Profile updated successfully"
}
```

**Response Error**:
- `400 Bad Request`: Dữ liệu không hợp lệ
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

## 2. Quản lý lớp học / Giảng dạy

### 2.1. Lấy danh sách các môn/lớp giảng viên đảm nhiệm
**GET** `/api/lecturer/courses`

**Query Parameters**:
- `semester` (optional): Học kỳ (ví dụ: "1", "2", "3")
- `academicYear` (optional): Năm học (ví dụ: "2024-2025")
- `status` (optional): Trạng thái ("active", "completed", "upcoming")

**Response Success (200)**:
```json
[
  {
    "courseId": "IT001",
    "courseName": "Nhập môn lập trình",
    "classCode": "IT001.01",
    "studentCount": 45,
    "semester": "1",
    "academicYear": "2024-2025",
    "status": "active",
    "schedule": "Thứ 2: 7:30-11:00, A1.501"
  }
]
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

### 2.2. Lấy chi tiết thông tin 1 lớp/môn
**GET** `/api/lecturer/courses/{courseId}`

**Path Parameters**:
- `courseId`: Mã môn học/lớp

**Response Success (200)**:
```json
{
  "courseId": "IT001",
  "courseName": "Nhập môn lập trình",
  "classCode": "IT001.01",
  "credits": 4,
  "studentCount": 45,
  "semester": "1",
  "academicYear": "2024-2025",
  "room": "A1.501",
  "schedule": "Thứ 2: 7:30-11:00",
  "description": "Học các khái niệm cơ bản về lập trình"
}
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `404 Not Found`: Không tìm thấy lớp hoặc không có quyền truy cập
- `500 Internal Server Error`: Lỗi server

---

### 2.3. Lấy lịch dạy
**GET** `/api/lecturer/schedule`

**Query Parameters**:
- `viewMode`: Chế độ xem ("week", "day", "semester") - Mặc định: "week"
- `courseId` (optional): Lọc theo mã môn học
- `date` (optional): Ngày cụ thể (ISO 8601 format)

**Response Success (200)**:
```json
[
  {
    "courseId": "IT001",
    "courseName": "Nhập môn lập trình",
    "classCode": "IT001.01",
    "date": "2024-12-02T00:00:00Z",
    "dayOfWeek": "Thứ 2",
    "startPeriod": 1,
    "endPeriod": 4,
    "room": "A1.501",
    "type": "Lý thuyết"
  }
]
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

## 3. Quản lý điểm

### 3.1. Tra cứu điểm học tập của sinh viên lớp mình dạy
**GET** `/api/lecturer/grades`

**Query Parameters**:
- `courseId` (required): Mã môn học/lớp
- `semester` (optional): Học kỳ

**Response Success (200)**:
```json
[
  {
    "studentId": 23520001,
    "studentName": "Nguyễn Văn A",
    "classCode": "IT001.01",
    "diemQuaTrinh": 8.5,
    "diemGiuaKy": 7.0,
    "diemThucHanh": 9.0,
    "diemCuoiKy": 8.0,
    "diemTongKet": 8.2,
    "diemChu": "A",
    "status": "Đạt"
  }
]
```

**Response Error**:
- `400 Bad Request`: Thiếu courseId
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

### 3.2. Xem chi tiết bảng điểm của 1 sinh viên
**GET** `/api/lecturer/grades/{studentId}`

**Path Parameters**:
- `studentId`: MSSV

**Query Parameters**:
- `courseId` (optional): Mã môn học

**Response Success (200)**:
```json
{
  "studentId": 23520001,
  "studentName": "Nguyễn Văn A",
  "courseId": "IT001",
  "courseName": "Nhập môn lập trình",
  "classCode": "IT001.01",
  "diemQuaTrinh": 8.5,
  "diemGiuaKy": 7.0,
  "diemThucHanh": 9.0,
  "diemCuoiKy": 8.0,
  "diemTongKet": 8.2,
  "diemChu": "A",
  "semester": "1",
  "academicYear": "2024-2025"
}
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền xem điểm sinh viên này
- `404 Not Found`: Không tìm thấy sinh viên hoặc không có quyền truy cập
- `500 Internal Server Error`: Lỗi server

---

### 3.3. Nhập/chỉnh sửa điểm
**PUT** `/api/lecturer/grades/{studentId}`

**Path Parameters**:
- `studentId`: MSSV

**Request Body**:
```json
{
  "courseId": "IT001",
  "diemQuaTrinh": 8.5,
  "diemGiuaKy": 7.0,
  "diemThucHanh": 9.0,
  "diemCuoiKy": 8.0
}
```

**Response Success (200)**:
```json
{
  "message": "Grade updated successfully",
  "notified": true
}
```

**Response Error**:
- `400 Bad Request`: 
  - Dữ liệu không hợp lệ
  - Thời hạn nhập điểm đã đóng
  - Điểm không hợp lệ (< 0 hoặc > 10)
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền nhập điểm
- `500 Internal Server Error`: Lỗi server

---

## 4. Quản lý thi / Kết quả thi

### 4.1. Xem danh sách lịch thi các lớp mình phụ trách
**GET** `/api/lecturer/exams`

**Query Parameters**:
- `semester` (optional): Học kỳ
- `courseId` (optional): Mã môn học

**Response Success (200)**:
```json
[
  {
    "examId": 1,
    "courseId": "IT001",
    "courseName": "Nhập môn lập trình",
    "classCode": "IT001.01",
    "examDate": "2024-12-15T08:00:00Z",
    "examTime": "08:00 - 10:00",
    "room": "A1.501",
    "examType": "Cuối kỳ",
    "studentCount": 45,
    "status": "Scheduled"
  }
]
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

### 4.2. Xem chi tiết lịch thi
**GET** `/api/lecturer/exams/{examId}`

**Path Parameters**:
- `examId`: ID lịch thi

**Response Success (200)**:
```json
{
  "examId": 1,
  "courseId": "IT001",
  "courseName": "Nhập môn lập trình",
  "classCode": "IT001.01",
  "examDate": "2024-12-15T08:00:00Z",
  "startTime": "08:00",
  "endTime": "10:00",
  "room": "A1.501",
  "examType": "Cuối kỳ",
  "duration": 120,
  "studentCount": 45,
  "instructions": "Sinh viên mang theo CMND/CCCD và thẻ sinh viên",
  "status": "Scheduled"
}
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `404 Not Found`: Không tìm thấy lịch thi
- `500 Internal Server Error`: Lỗi server

---

### 4.3. Xem kết quả thi
**GET** `/api/lecturer/exams/{examId}/grades`

**Path Parameters**:
- `examId`: ID lịch thi

**Response Success (200)**:
```json
[
  {
    "studentId": 23520001,
    "studentName": "Nguyễn Văn A",
    "score": 8.5,
    "grade": "A",
    "status": "Completed"
  }
]
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `404 Not Found`: Không tìm thấy lịch thi
- `500 Internal Server Error`: Lỗi server

---

### 4.4. Nhập kết quả thi
**POST** `/api/lecturer/exams/{examId}/grades`

**Path Parameters**:
- `examId`: ID lịch thi

**Request Body**:
```json
{
  "grades": [
    {
      "studentId": 23520001,
      "score": 8.5
    },
    {
      "studentId": 23520002,
      "score": 7.0
    }
  ]
}
```

**Response Success (200)**:
```json
{
  "message": "Exam grades submitted successfully"
}
```

**Response Error**:
- `400 Bad Request`: Dữ liệu không hợp lệ
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền nhập điểm thi
- `500 Internal Server Error`: Lỗi server

---

## 5. Dịch vụ & Hỗ trợ sinh viên

### 5.1. Tạo/nộp Giấy xác nhận cho sinh viên
**POST** `/api/lecturer/confirmation-letter`

**Request Body**:
```json
{
  "studentId": 23520001,
  "purpose": "Xác nhận sinh viên đang học",
  "notes": "Cần gấp trong 3 ngày"
}
```

**Response Success (200)**:
```json
{
  "message": "Confirmation letter created successfully",
  "letterId": 123
}
```

**Response Error**:
- `400 Bad Request`: 
  - Thiếu thông tin bắt buộc
  - StudentId không hợp lệ
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền tạo giấy xác nhận cho sinh viên này
- `500 Internal Server Error`: Lỗi server

---

### 5.2. Xem/lấy thông tin học phí của sinh viên
**GET** `/api/lecturer/tuition-report`

**Query Parameters**:
- `studentId` (required): MSSV
- `year` (optional): Năm học
- `semester` (optional): Học kỳ

**Response Success (200)**:
```json
{
  "studentId": 23520001,
  "studentName": "Nguyễn Văn A",
  "semester": "1",
  "academicYear": "2024-2025",
  "totalAmount": 5000000,
  "paidAmount": 5000000,
  "remainingAmount": 0,
  "dueDate": "2024-09-30T00:00:00Z",
  "status": "Đã đóng đủ"
}
```

**Response Error**:
- `400 Bad Request`: Thiếu studentId
- `401 Unauthorized`: Token không hợp lệ
- `404 Not Found`: Không có thông tin học phí
- `500 Internal Server Error`: Lỗi server

---

## 6. Phúc khảo / Khiếu nại điểm

### 6.1. Lấy danh sách các yêu cầu phúc khảo
**GET** `/api/lecturer/appeals`

**Query Parameters**:
- `courseId` (optional): Mã môn học
- `status` (optional): Trạng thái ("pending", "approved", "rejected")

**Response Success (200)**:
```json
[
  {
    "appealId": 1,
    "studentId": 23520001,
    "studentName": "Nguyễn Văn A",
    "courseId": "IT001",
    "courseName": "Nhập môn lập trình",
    "classCode": "IT001.01",
    "reason": "Cho rằng bài thi bị chấm sai",
    "requestedAt": "2024-12-01T10:00:00Z",
    "status": "pending"
  }
]
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

### 6.2. Xem chi tiết 1 yêu cầu phúc khảo
**GET** `/api/lecturer/appeals/{appealId}`

**Path Parameters**:
- `appealId`: ID yêu cầu phúc khảo

**Response Success (200)**:
```json
{
  "appealId": 1,
  "studentId": 23520001,
  "studentName": "Nguyễn Văn A",
  "courseId": "IT001",
  "courseName": "Nhập môn lập trình",
  "classCode": "IT001.01",
  "currentGrade": 5.0,
  "expectedGrade": 7.0,
  "reason": "Cho rằng bài thi bị chấm sai câu 3 và câu 5",
  "evidence": "Đính kèm ảnh bài làm",
  "requestedAt": "2024-12-01T10:00:00Z",
  "status": "pending"
}
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền xem phúc khảo này
- `404 Not Found`: Không tìm thấy yêu cầu phúc khảo
- `500 Internal Server Error`: Lỗi server

---

### 6.3. Xử lý phúc khảo (chấp nhận/từ chối)
**PUT** `/api/lecturer/appeals/{appealId}`

**Path Parameters**:
- `appealId`: ID yêu cầu phúc khảo

**Request Body**:
```json
{
  "result": "approved",
  "comment": "Sau khi xem xét lại, điểm được nâng lên",
  "newGrade": 7.0
}
```

**Response Success (200)**:
```json
{
  "message": "Appeal processed successfully",
  "notified": true
}
```

**Response Error**:
- `400 Bad Request`: 
  - Dữ liệu không hợp lệ
  - Thời hạn phúc khảo đã hết
  - Result phải là "approved" hoặc "rejected"
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền xử lý phúc khảo này
- `500 Internal Server Error`: Lỗi server

---

## 7. Thông báo / Truyền thông nội bộ

### 7.1. Lấy thông báo gửi tới giảng viên
**GET** `/api/lecturer/notifications`

**Query Parameters**:
- `unreadOnly` (optional): Chỉ lấy thông báo chưa đọc - Mặc định: false
- `limit` (optional): Số lượng thông báo tối đa - Mặc định: 50
- `page` (optional): Trang - Mặc định: 1

**Response Success (200)**:
```json
[
  {
    "id": 1,
    "title": "Thông báo họp khoa",
    "message": "Họp vào 8h ngày 5/12/2024",
    "type": "announcement",
    "createdAt": "2024-12-01T08:00:00Z",
    "isRead": false,
    "link": null
  }
]
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

### 7.2. Đánh dấu thông báo đã xem
**PUT** `/api/lecturer/notifications/{id}`

**Path Parameters**:
- `id`: ID thông báo

**Response Success (200)**:
```json
{
  "message": "Notification marked as read"
}
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `404 Not Found`: Không tìm thấy thông báo
- `500 Internal Server Error`: Lỗi server

---

## 8. Hỗ trợ & Quản lý file / Tài liệu giảng dạy

### 8.1. Lấy danh sách các tài liệu giảng dạy
**GET** `/api/lecturer/materials`

**Query Parameters**:
- `courseId` (optional): Mã môn học
- `type` (optional): Loại tài liệu ("syllabus", "slides", "exercises", "reference")

**Response Success (200)**:
```json
[
  {
    "materialId": 1,
    "courseId": "IT001",
    "courseName": "Nhập môn lập trình",
    "fileName": "abc123.pdf",
    "originalFileName": "Bai_giang_1.pdf",
    "type": "slides",
    "description": "Bài giảng chương 1",
    "uploadedAt": "2024-11-01T10:00:00Z",
    "fileSize": 1024000
  }
]
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `500 Internal Server Error`: Lỗi server

---

### 8.2. Upload tài liệu mới
**POST** `/api/lecturer/materials`

**Request**: `multipart/form-data`

**Form Data**:
- `file`: File tài liệu (Required)
- `courseId`: Mã môn học (Required)
- `type`: Loại tài liệu (Required) - "syllabus", "slides", "exercises", "reference"
- `description`: Mô tả (Optional)

**Response Success (200)**:
```json
{
  "message": "Material uploaded successfully",
  "materialId": 1,
  "fileName": "abc123.pdf"
}
```

**Response Error**:
- `400 Bad Request`: 
  - File không hợp lệ
  - File quá lớn (> 50MB)
  - Định dạng file không được phép
  - Thiếu thông tin bắt buộc
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền upload tài liệu cho môn học này
- `500 Internal Server Error`: Lỗi server

**Allowed File Types**: `.pdf`, `.docx`, `.pptx`, `.xlsx`, `.zip`

**Max File Size**: 50MB

---

### 8.3. Cập nhật tài liệu
**PUT** `/api/lecturer/materials/{materialId}`

**Path Parameters**:
- `materialId`: ID tài liệu

**Request Body**:
```json
{
  "type": "slides",
  "description": "Bài giảng chương 1 - Đã cập nhật"
}
```

**Response Success (200)**:
```json
{
  "message": "Material updated successfully"
}
```

**Response Error**:
- `400 Bad Request`: Dữ liệu không hợp lệ
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền cập nhật tài liệu này
- `404 Not Found`: Không tìm thấy tài liệu
- `500 Internal Server Error`: Lỗi server

---

### 8.4. Xóa tài liệu
**DELETE** `/api/lecturer/materials/{materialId}`

**Path Parameters**:
- `materialId`: ID tài liệu

**Response Success (200)**:
```json
{
  "message": "Material deleted successfully"
}
```

**Response Error**:
- `401 Unauthorized`: Token không hợp lệ
- `403 Forbidden`: Không có quyền xóa tài liệu này
- `404 Not Found`: Không tìm thấy tài liệu
- `500 Internal Server Error`: Lỗi server

---

## Lưu ý chung

### Định dạng ngày giờ
Tất cả các trường ngày giờ sử dụng định dạng ISO 8601: `YYYY-MM-DDThh:mm:ssZ`

### Mã lỗi HTTP
- `200 OK`: Yêu cầu thành công
- `201 Created`: Tạo mới thành công
- `400 Bad Request`: Dữ liệu không hợp lệ
- `401 Unauthorized`: Không có quyền truy cập (token không hợp lệ)
- `403 Forbidden`: Token hợp lệ nhưng không có quyền thực hiện hành động
- `404 Not Found`: Không tìm thấy tài nguyên
- `409 Conflict`: Xung đột dữ liệu
- `500 Internal Server Error`: Lỗi server

### Pagination
Các endpoint trả về danh sách có thể hỗ trợ phân trang qua query parameters:
- `page`: Số trang (bắt đầu từ 1)
- `limit`: Số lượng items mỗi trang (mặc định: 50, max: 100)

### Notification
Khi cập nhật điểm hoặc xử lý phúc khảo, hệ thống sẽ tự động gửi thông báo tới sinh viên qua SignalR.

