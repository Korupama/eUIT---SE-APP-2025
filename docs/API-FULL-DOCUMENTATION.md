# eUIT API - Comprehensive Documentation for UI Integration

**Base URL**: `http://localhost:5128` (Development)  
**Authentication**: Bearer JWT Token (except for public endpoints)

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Content APIs](#2-content-apis)
3. [Service APIs](#3-service-apis)
4. [Schedule APIs](#4-schedule-apis)
5. [Student Data APIs](#5-student-data-apis)
6. [Error Handling](#6-error-handling)
7. [Authentication Flow](#7-authentication-flow)

---

## 1. Authentication

### 1.1 Login

**Endpoint**: `POST /api/auth/login`  
**Authentication**: None (Public)

**Request Body**:
```json
{
  "userId": "string",      // Required: MSSV for students, employee ID for lecturer/admin
  "password": "string",    // Required
  "role": "string"         // Required: "student" | "lecturer" | "admin"
}
```

**Accepted Values**:
- `role`: Must be one of: `"student"`, `"lecturer"`, `"admin"` (case-insensitive)

**Success Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses**:
- `400 Bad Request`: Invalid role
  ```json
  { "error": "Invalid role" }
  ```
- `401 Unauthorized`: Invalid credentials
  ```json
  { "message": "Invalid credentials" }
  ```

---

### 1.2 Get Profile

**Endpoint**: `GET /api/auth/profile`  
**Authentication**: Required (Student only)

**Query Parameters**: None

**Success Response** (200 OK):
```json
{
  "mssv": 23520541,
  "hoTen": "Nguyễn Văn A",
  "ngaySinh": "2005-01-01T00:00:00",
  "nganhHoc": "Công nghệ thông tin",
  "khoaHoc": 2023,
  "lopSinhHoat": "CNTT2023.01",
  "noiSinh": "TP.HCM",
  "cccd": "079205001234",
  "ngayCapCccd": "2023-01-01T00:00:00",
  "noiCapCccd": "Cục Cảnh sát ĐKQL cư trú và DLQG về dân cư",
  "danToc": "Kinh",
  "tonGiao": "Không",
  "soDienThoai": "0901234567",
  "diaChiThuongTru": "123 Đường ABC, Quận 1",
  "tinhThanhPho": "TP. Hồ Chí Minh",
  "phuongXa": "Phường Bến Nghé",
  "quaTrinhHocTapCongTac": "Tốt nghiệp THPT XYZ",
  "thanhTich": "Học sinh giỏi Toán",
  "emailCaNhan": "student@email.com",
  "maNganHang": "970415",
  "tenNganHang": "Vietinbank",
  "soTaiKhoan": "1234567890",
  "chiNhanh": "Chi nhánh TP.HCM",
  "hoTenCha": "Nguyễn Văn B",
  "quocTichCha": "Việt Nam",
  "danTocCha": "Kinh",
  "tonGiaoCha": "Không",
  "sdtCha": "0912345678",
  "emailCha": "father@email.com",
  "diaChiThuongTruCha": "123 Đường ABC",
  "congViecCha": "Kỹ sư",
  "hoTenMe": "Trần Thị C",
  "quocTichMe": "Việt Nam",
  "danTocMe": "Kinh",
  "tonGiaoMe": "Không",
  "sdtMe": "0923456789",
  "emailMe": "mother@email.com",
  "diaChiThuongTruMe": "123 Đường ABC",
  "congViecMe": "Giáo viên",
  "hoTenNgh": null,
  "quocTichNgh": null,
  "danTocNgh": null,
  "tonGiaoNgh": null,
  "sdtNgh": null,
  "emailNgh": null,
  "diaChiThuongTruNgh": null,
  "congViecNgh": null,
  "thongTinNguoiCanBaoTin": "Ông Nguyễn Văn D",
  "soDienThoaiBaoTin": "0934567890",
  "anhTheUrl": null
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `400 Bad Request`: Only students can access this endpoint
  ```json
  { "error": "Only students can access this endpoint" }
  ```
- `404 Not Found`: Student not found
  ```json
  { "error": "Student not found" }
  ```

---

## 2. Content APIs

### 2.1 Get Latest News

**Endpoint**: `GET /news`  
**Authentication**: None (Public)

**Query Parameters**: None

**Success Response** (200 OK):
```json
[
  {
    "tieuDe": "Thông báo nghỉ tết Nguyên Đán 2025",
    "url": "https://student.uit.edu.vn/thong-bao-nghi-tet-2025",
    "ngayDang": "2024-12-15T00:00:00"
  },
  {
    "tieuDe": "Lịch thi cuối kỳ HK1 2024-2025",
    "url": "https://student.uit.edu.vn/lich-thi-hk1-2024-2025",
    "ngayDang": "2024-12-10T00:00:00"
  }
]
```

**Notes**:
- Returns list of latest news/announcements from the university
- Ordered by `ngayDang` (publication date) descending

---

### 2.2 Get Regulations

**Endpoint**: `GET /api/public/regulations`  
**Authentication**: None (Public)

**Query Parameters**:
- `download` (boolean, optional): Set to `true` to download a regulation file
- `search_term` (string, optional): Keyword to filter regulations by name
- `file_name` (string, required if `download=true`): Name of the file to download

**Response for List Mode** (`download=false` or omitted) - 200 OK:
```json
{
  "regulations": [
    {
      "tenVanBan": "Quy chế học vụ đại học hệ chính quy",
      "urlVanBan": "http://localhost:5128/files/quy-che-hoc-vu-2024.pdf",
      "ngayBanHanh": "2024-01-15T00:00:00"
    },
    {
      "tenVanBan": "Quy định về đánh giá kết quả rèn luyện",
      "urlVanBan": "http://localhost:5128/files/danh-gia-rl-2024.pdf",
      "ngayBanHanh": "2024-02-01T00:00:00"
    }
  ],
  "message": null
}
```

**Response for Download Mode** (`download=true`):
- Returns PDF file as binary data with `Content-Type: application/pdf`

**Error Responses**:
- `400 Bad Request`: File name missing when download=true
  ```json
  { "message": "Tên file không được để trống khi tải xuống" }
  ```
- `404 Not Found`: File not found
  ```json
  { "message": "File không tồn tại" }
  ```
- `404 Not Found`: No regulations found
  ```json
  {
    "regulations": [],
    "message": "Không tìm thấy quy chế nào"
  }
  ```
- `500 Internal Server Error`: Cannot load data
  ```json
  {
    "regulations": [],
    "message": "Không thể tải dữ liệu quy chế"
  }
  ```

**Examples**:
- List all regulations: `GET /api/public/regulations`
- Search regulations: `GET /api/public/regulations?search_term=học vụ`
- Download regulation: `GET /api/public/regulations?download=true&file_name=quy-che-hoc-vu-2024.pdf`

---

## 3. Service APIs

### 3.1 Request Confirmation Letter

**Endpoint**: `POST /api/service/confirmation-letter`  
**Authentication**: Required

**Request Body**:
```json
{
  "purpose": "string"  // Required: Purpose of the confirmation letter
}
```

**Success Response** (200 OK):
```json
{
  "serialNumber": 12345,
  "expiryDate": "31/12/2025"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid MSSV
- `401 Unauthorized`: Missing token
- `500 Internal Server Error`: Database error

---

### 3.2 Get Confirmation Letter History

**Endpoint**: `GET /api/service/confirmation-letter/history`  
**Authentication**: Required

**Query Parameters**: None

**Success Response** (200 OK):
```json
[
  {
    "serialNumber": 12345,
    "purpose": "Xin học bổng",
    "expiryDate": "31/12/2025",
    "requestedAt": "15/12/2024 10:30"
  },
  {
    "serialNumber": 12344,
    "purpose": "Xin xác nhận vay ngân hàng",
    "expiryDate": "30/06/2025",
    "requestedAt": "10/06/2024 14:20"
  }
]
```

---

### 3.3 Submit Language Certificate

**Endpoint**: `POST /api/service/language-certificate`  
**Authentication**: Required  
**Content-Type**: `multipart/form-data`  
**Max File Size**: 5 MB

**Form Data**:
```
certificateType: string   // Required: Certificate type
score: float              // Required: Score/Level
issueDate: date           // Required: Issue date (YYYY-MM-DD)
expiryDate: date          // Optional: Expiry date (YYYY-MM-DD)
file: file                // Required: Certificate file (PDF, JPG, PNG)
```

**Accepted Values**:
- `certificateType`: Any string (e.g., "TOEIC", "IELTS", "TOEFL", etc.)
- `file` extensions: `.pdf`, `.jpg`, `.jpeg`, `.png`

**Success Response** (200 OK):
```json
{
  "message": "Nộp chứng chỉ thành công."
}
```

**Error Responses**:
- `400 Bad Request`: Invalid file type
  ```json
  { "error": "File phải là PDF hoặc JPG/PNG." }
  ```
- `400 Bad Request`: Missing file
  ```json
  { "file": "Vui lòng tải lên file chứng chỉ." }
  ```
- `400 Bad Request`: Database validation error (e.g., duplicate certificate)
  ```json
  { "error": "Message from database exception" }
  ```
- `500 Internal Server Error`: Server error
  ```json
  { "error": "Lỗi Server: ..." }
  ```

---

### 3.4 Get Language Certificate History

**Endpoint**: `GET /api/service/language-certificate/history`  
**Authentication**: Required

**Query Parameters**: None

**Success Response** (200 OK):
```json
[
  {
    "id": 1,
    "certificateType": "TOEIC",
    "score": 850.0,
    "issueDate": "15/06/2024",
    "expiryDate": "15/06/2026",
    "status": "approved",
    "filePath": "uploads/certificates/23520541_20240615_abc123.pdf",
    "createdAt": "15/06/2024 10:30"
  },
  {
    "id": 2,
    "certificateType": "IELTS",
    "score": 7.5,
    "issueDate": "01/09/2024",
    "expiryDate": null,
    "status": "pending",
    "filePath": "uploads/certificates/23520541_20240901_def456.pdf",
    "createdAt": "01/09/2024 14:20"
  }
]
```

**Possible Status Values**:
- `"pending"`: Awaiting approval
- `"approved"`: Approved
- `"rejected"`: Rejected

---

### 3.5 Register Parking Pass

**Endpoint**: `POST /api/service/parking-pass`  
**Authentication**: Required

**Request Body**:
```json
{
  "licensePlate": "string",       // Required for motorbike, ignored for bicycle
  "vehicleType": "string",        // Required: "bicycle" | "motorbike"
  "registrationMonths": number    // Required: Number of months (1-12)
}
```

**Accepted Values**:
- `vehicleType`: `"bicycle"` or `"motorbike"` (case-sensitive)
- `registrationMonths`: Integer from 1 to 12
- `licensePlate`: Required if `vehicleType` is `"motorbike"`. For `"bicycle"`, the system automatically uses MSSV as license plate.

**Success Response** (201 Created):
```json
{
  "id": 123,
  "licensePlate": "59A-12345",
  "vehicleType": "motorbike",
  "registeredAt": "15/12/2024 10:30",
  "expiryDate": "15/06/2025"
}
```

**Error Responses**:
- `400 Bad Request`: Missing license plate for motorbike
  ```json
  {
    "licensePlate": ["Biển số xe là bắt buộc cho xe máy."]
  }
  ```
- `409 Conflict`: Already registered for this vehicle
  ```json
  { "error": "Error message from database" }
  ```
- `500 Internal Server Error`: Server error

---

### 3.6 Submit Appeal

**Endpoint**: `POST /api/service/appeal`  
**Authentication**: Required

**Request Body**:
```json
{
  "courseId": "string",        // Required: Course code (e.g., "IE307.Q12")
  "reason": "string",          // Required: Reason for appeal
  "paymentMethod": "string"    // Required: "cash" | "banking" | "momo" | "vnpay"
}
```

**Accepted Values**:
- `paymentMethod`: Must be one of: `"cash"`, `"banking"`, `"momo"`, `"vnpay"` (case-sensitive)

**Success Response** (200 OK):
```json
{
  "id": 1,
  "courseId": "IE307.Q12",
  "reason": "Điểm thi không khớp với điểm trên bài thi",
  "paymentMethod": "momo",
  "paymentStatus": "completed",
  "status": "pending",
  "createdAt": "15/12/2024 10:30",
  "message": "Nộp đơn phúc khảo thành công. Đơn của bạn đang được xử lý."
}
```

**Possible Status Values**:
- `paymentStatus`: `"pending"`, `"completed"`, `"failed"`
- `status`: `"awaiting_payment"`, `"pending"`, `"approved"`, `"rejected"`

**Error Responses**:
- `400 Bad Request`: Already submitted appeal for this course
  ```json
  { "error": "Bạn đã nộp đơn phúc khảo cho môn học này rồi." }
  ```
- `500 Internal Server Error`: Server error

**Notes**:
- If `paymentMethod` is `"cash"`, the appeal status will be `"awaiting_payment"` and payment needs to be confirmed manually
- For online payment methods (`"banking"`, `"momo"`, `"vnpay"`), payment is simulated as `"completed"` and status is `"pending"`

---

### 3.7 Request Tuition Extension

**Endpoint**: `POST /api/service/tuition-extension`  
**Authentication**: Required  
**Content-Type**: `multipart/form-data`  
**Max File Size**: 10 MB

**Form Data**:
```
reason: string              // Required: Reason for extension
desiredTime: date           // Required: Desired extension date (YYYY-MM-DD)
supportingDocs: file        // Optional: Supporting document (PDF, JPG, PNG)
```

**Accepted Values**:
- `supportingDocs` extensions: `.pdf`, `.jpg`, `.jpeg`, `.png`
- `desiredTime`: Must be after current date and within 2 months from registration deadline

**Success Response** (200 OK):
```json
{
  "id": 1,
  "reason": "Gia đình gặp khó khăn tài chính",
  "desiredTime": "15/02/2025",
  "supportingDocs": "uploads/tuition-extensions/23520541_20241215_abc123.pdf",
  "status": "pending",
  "createdAt": "15/12/2024 10:30",
  "updatedAt": "15/12/2024 10:30",
  "message": "Đăng ký gia hạn học phí thành công. Đơn của bạn đang chờ Phòng KHTC xét duyệt."
}
```

**Possible Status Values**:
- `"pending"`: Awaiting review
- `"approved"`: Approved
- `"rejected"`: Rejected

**Error Responses**:
- `400 Bad Request`: Past registration deadline
  ```json
  { "error": "Đã hết thời hạn đăng ký gia hạn học phí." }
  ```
- `400 Bad Request`: Invalid extension date
  ```json
  { "error": "Thời gian gia hạn không hợp lệ. Vượt quá quy định cho phép." }
  ```
  ```json
  { "error": "Thời gian gia hạn phải sau thời điểm hiện tại." }
  ```
- `400 Bad Request`: Invalid file type
  ```json
  { "error": "File phải là PDF hoặc JPG/PNG." }
  ```
- `500 Internal Server Error`: Server error

---

### 3.8 Update Tuition Extension

**Endpoint**: `PUT /api/service/tuition-extension/{request_id}`  
**Authentication**: Required  
**Content-Type**: `multipart/form-data`  
**Max File Size**: 10 MB

**Path Parameters**:
- `request_id` (integer, required): ID of the tuition extension request

**Form Data** (all optional):
```
reason: string              // Optional: Updated reason
desiredTime: date           // Optional: Updated desired date (YYYY-MM-DD)
supportingDocs: file        // Optional: New supporting document (PDF, JPG, PNG)
```

**Success Response** (200 OK):
```json
{
  "id": 1,
  "reason": "Gia đình gặp khó khăn tài chính (cập nhật)",
  "desiredTime": "20/02/2025",
  "supportingDocs": "uploads/tuition-extensions/23520541_20241216_xyz789.pdf",
  "status": "pending",
  "createdAt": "15/12/2024 10:30",
  "updatedAt": "16/12/2024 14:20",
  "message": "Cập nhật đơn gia hạn thành công."
}
```

**Error Responses**:
- `404 Not Found`: Request not found or unauthorized
  ```json
  { "error": "Không tìm thấy đơn gia hạn hoặc bạn không có quyền chỉnh sửa." }
  ```
- `400 Bad Request`: Cannot edit approved/rejected request
  ```json
  { "error": "Không thể chỉnh sửa đơn gia hạn đã được phê duyệt." }
  ```
  ```json
  { "error": "Không thể chỉnh sửa đơn gia hạn đã được từ chối." }
  ```
- `400 Bad Request`: Invalid extension date (same validation as POST)
- `400 Bad Request`: Invalid file type (same validation as POST)
- `500 Internal Server Error`: Server error

**Notes**:
- Only requests with `status="pending"` can be updated
- If a new file is uploaded, the old file will be deleted
- Partial updates are supported - only provide fields you want to change

---

## 4. Schedule APIs

### 4.1 Get Class Schedule

**Endpoint**: `GET /api/student/schedule/classes`  
**Authentication**: Required

**Query Parameters**:
- `view_mode` (string, optional, default: `"week"`): Filter classes by time range
  - Accepted values: `"day"`, `"week"`, `"month"`, `"all"`
- `filter_by_course` (string, optional): Filter by course code or name (case-insensitive)
- `filter_by_lecturer` (string, optional): Filter by lecturer code or name (case-insensitive)

**Accepted Values**:
- `view_mode`:
  - `"day"`: Show today's classes only
  - `"week"`: Show this week's classes (Monday to Sunday)
  - `"month"`: Show this month's classes
  - `"all"`: Show all upcoming classes from today onwards

**Success Response** (200 OK):
```json
{
  "classes": [
    {
      "hocKy": "HK1_2024-2025",
      "maMonHoc": "IE307",
      "tenMonHoc": "Công nghệ Web và ứng dụng",
      "maLop": "IE307.Q12",
      "soTinChi": 4,
      "maGiangVien": "00001234",
      "tenGiangVien": "Nguyễn Văn A",
      "thu": "2",
      "tietBatDau": 1,
      "tietKetThuc": 5,
      "cachTuan": 1,
      "ngayBatDau": "2024-09-01T00:00:00",
      "ngayKetThuc": "2025-12-31T00:00:00",
      "phongHoc": "E3.2",
      "siSo": 60,
      "hinhThucGiangDay": "Lý thuyết",
      "ghiChu": null
    },
    {
      "hocKy": "HK1_2024-2025",
      "maMonHoc": "IT001",
      "tenMonHoc": "Nhập môn lập trình",
      "maLop": "IT001.Q11",
      "soTinChi": 4,
      "maGiangVien": "00005678",
      "tenGiangVien": "Trần Thị B",
      "thu": "5",
      "tietBatDau": 6,
      "tietKetThuc": 10,
      "cachTuan": 1,
      "ngayBatDau": "2024-09-01T00:00:00",
      "ngayKetThuc": "2024-12-31T00:00:00",
      "phongHoc": "B1.01",
      "siSo": 50,
      "hinhThucGiangDay": "Thực hành",
      "ghiChu": null
    }
  ],
  "message": null
}
```

**Field Descriptions**:
- `thu`: Day of week as string ("2"=Monday, "3"=Tuesday, ..., "8"=Sunday)
- `tietBatDau`, `tietKetThuc`: Period numbers (1-based, each period ≈ 50 minutes, starting 7:00 AM)
- `cachTuan`: Week interval (1=every week, 2=every 2 weeks, etc.)
- `hinhThucGiangDay`: Teaching format (e.g., "Lý thuyết", "Thực hành", "Thảo luận")

**Empty Response** (200 OK):
```json
{
  "classes": [],
  "message": "Chưa có lịch học"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `500 Internal Server Error`: Cannot load schedule
  ```json
  {
    "classes": [],
    "message": "Không thể tải lịch học"
  }
  ```

**Examples**:
- Get this week's classes: `GET /api/student/schedule/classes?view_mode=week`
- Get today's classes: `GET /api/student/schedule/classes?view_mode=day`
- Filter by course: `GET /api/student/schedule/classes?filter_by_course=IE307`
- Filter by lecturer: `GET /api/student/schedule/classes?filter_by_lecturer=Nguyễn Văn A`
- Combined filters: `GET /api/student/schedule/classes?view_mode=month&filter_by_course=IT001`

---

### 4.2 Get Exam Schedule

**Endpoint**: `GET /api/student/schedule/exams`  
**Authentication**: Required

**Query Parameters**:
- `filter_by_semester` (string, optional): Filter by semester (e.g., "HK1_2024-2025")
- `filter_by_group` (string, optional): Filter by exam group
  - Accepted values: `"GK"` (midterm), `"CK"` (final)

**Success Response** (200 OK):
```json
{
  "exams": [
    {
      "maMonHoc": "IE307",
      "tenMonHoc": "Công nghệ Web và ứng dụng",
      "maLop": "IE307.Q12",
      "maGiangVien": "00001234",
      "tenGiangVien": "Nguyễn Văn A",
      "ngayThi": "2025-01-15T00:00:00",
      "caThi": "7h00 - 8h30",
      "phongThi": "E3.2",
      "hinhThucThi": "Tự luận",
      "gkCk": "CK",
      "soTinChi": 4
    },
    {
      "maMonHoc": "IT001",
      "tenMonHoc": "Nhập môn lập trình",
      "maLop": "IT001.Q11",
      "maGiangVien": "00005678",
      "tenGiangVien": "Trần Thị B",
      "ngayThi": "2025-01-20T00:00:00",
      "caThi": "9h00 - 10h30",
      "phongThi": "B1.01",
      "hinhThucThi": "Trắc nghiệm",
      "gkCk": "CK",
      "soTinChi": 4
    }
  ],
  "message": null
}
```

**Field Descriptions**:
- `gkCk`: Exam group ("GK"=midterm, "CK"=final)
- `hinhThucThi`: Exam format (e.g., "Tự luận", "Trắc nghiệm", "Vấn đáp")

**Empty Response** (200 OK):
```json
{
  "exams": [],
  "message": "Chưa công bố lịch thi"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV

**Examples**:
- Get all exams: `GET /api/student/schedule/exams`
- Get exams for specific semester: `GET /api/student/schedule/exams?filter_by_semester=HK1_2024-2025`
- Get only final exams: `GET /api/student/schedule/exams?filter_by_group=CK`

---

### 4.3 Create Personal Event

**Endpoint**: `POST /api/student/schedule/personal`  
**Authentication**: Required

**Request Body**:
```json
{
  "eventName": "string",       // Required: Name of the event
  "time": "datetime",          // Required: Event time (ISO 8601 format)
  "location": "string",        // Optional: Event location
  "description": "string"      // Optional: Event description
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "message": "Tạo sự kiện thành công",
  "event": {
    "eventId": 1,
    "eventName": "Họp nhóm đồ án",
    "time": "2024-12-20T14:00:00",
    "location": "E3.2",
    "description": "Thảo luận về đồ án môn Web",
    "createdAt": "2024-12-15T10:30:00",
    "updatedAt": "2024-12-15T10:30:00"
  },
  "conflict": null
}
```

**Response with Conflict Warning** (200 OK):
```json
{
  "success": true,
  "message": "Sự kiện đã được tạo nhưng có xung đột với lịch học",
  "event": {
    "eventId": 2,
    "eventName": "Họp câu lạc bộ",
    "time": "2024-12-20T07:00:00",
    "location": "Sân trường",
    "description": null,
    "createdAt": "2024-12-15T11:00:00",
    "updatedAt": "2024-12-15T11:00:00"
  },
  "conflict": {
    "hasConflict": true,
    "conflictType": "class",
    "conflictDetails": "Công nghệ Web và ứng dụng (IE307.Q12) - Tiết 1-5, Phòng E3.2"
  }
}
```

**Possible Conflict Types**:
- `"class"`: Conflict with class schedule
- `"exam"`: Conflict with exam schedule

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `500 Internal Server Error`: Cannot create event
  ```json
  {
    "success": false,
    "message": "Không thể tạo sự kiện: ..."
  }
  ```

**Notes**:
- Events are created even if there's a conflict (conflict is a warning, not an error)
- Conflicts are detected by comparing event time with class schedule and exam schedule
- Use ISO 8601 datetime format for `time` field (e.g., "2024-12-20T14:00:00")

---

### 4.4 Update Personal Event

**Endpoint**: `PUT /api/student/schedule/personal/{event_id}`  
**Authentication**: Required

**Path Parameters**:
- `event_id` (integer, required): ID of the personal event

**Request Body** (all fields optional):
```json
{
  "eventName": "string",       // Optional: Updated event name
  "time": "datetime",          // Optional: Updated event time (ISO 8601 format)
  "location": "string",        // Optional: Updated location
  "description": "string"      // Optional: Updated description
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "message": "Cập nhật sự kiện thành công",
  "event": {
    "eventId": 1,
    "eventName": "Họp nhóm đồ án (cập nhật)",
    "time": "2024-12-20T15:00:00",
    "location": "E3.3",
    "description": "Thảo luận về đồ án môn Web (thay đổi phòng)",
    "createdAt": "2024-12-15T10:30:00",
    "updatedAt": "2024-12-15T14:20:00"
  },
  "conflict": null
}
```

**Response with Conflict Warning** (200 OK):
- Same structure as Create Personal Event with conflict

**Error Responses**:
- `404 Not Found`: Event not found or unauthorized
  ```json
  {
    "success": false,
    "message": "Không tìm thấy sự kiện hoặc bạn không có quyền chỉnh sửa"
  }
  ```
- `500 Internal Server Error`: Cannot update event
  ```json
  {
    "success": false,
    "message": "Không thể cập nhật sự kiện: ..."
  }
  ```

**Notes**:
- Partial updates are supported - only provide fields you want to change
- Conflict detection runs only if `time` field is provided
- Students can only update their own events

---

### 4.5 Delete Personal Event

**Endpoint**: `DELETE /api/student/schedule/personal/{event_id}`  
**Authentication**: Required

**Path Parameters**:
- `event_id` (integer, required): ID of the personal event

**Query Parameters**: None

**Success Response** (200 OK):
```json
{
  "success": true,
  "message": "Xóa sự kiện thành công"
}
```

**Error Responses**:
- `404 Not Found`: Event not found or unauthorized
  ```json
  {
    "success": false,
    "message": "Không tìm thấy sự kiện hoặc bạn không có quyền xóa"
  }
  ```
- `500 Internal Server Error`: Cannot delete event
  ```json
  {
    "success": false,
    "message": "Không thể xóa sự kiện: ..."
  }
  ```

**Notes**:
- This is a hard delete (event is permanently removed from database)
- Students can only delete their own events

---

## 5. Student Data APIs

### 5.1 Get Student Card Info

**Endpoint**: `GET /card`  
**Authentication**: Required

**Query Parameters**: None

**Success Response** (200 OK):
```json
{
  "mssv": 23520541,
  "hoTen": "Nguyễn Văn A",
  "khoaHoc": 2023,
  "nganhHoc": "Công nghệ thông tin",
  "avatarFullUrl": "http://localhost:5128/files/Students/Avatars/23520541.jpg"
}
```

**Field Descriptions**:
- `avatarFullUrl`: Full URL to student's avatar image (null if not available)

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `404 Not Found`: Student not found

---

### 5.2 Get Quick GPA

**Endpoint**: `GET /quickgpa`  
**Authentication**: Required

**Query Parameters**: None

**Success Response** (200 OK):
```json
{
  "gpa": 3.45,
  "soTinChiTichLuy": 80
}
```

**Field Descriptions**:
- `gpa`: Overall GPA (0.00 - 4.00 scale)
- `soTinChiTichLuy`: Accumulated credits

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `404 Not Found`: No GPA data available

---

### 5.3 Get Next Class

**Endpoint**: `GET /nextclass`  
**Authentication**: Required

**Query Parameters**: None

**Success Response** (200 OK):
```json
{
  "maLop": "IE307.Q12",
  "tenMonHoc": "Công nghệ Web và ứng dụng",
  "tenGiangVien": "Nguyễn Văn A",
  "thu": "2",
  "tietBatDau": 1,
  "tietKetThuc": 5,
  "phongHoc": "E3.2",
  "ngayHoc": "2024-12-23T00:00:00",
  "countdownMinutes": 120
}
```

**Field Descriptions**:
- `thu`: Day of week as string ("2"=Monday, "3"=Tuesday, ..., "8"=Sunday)
- `countdownMinutes`: Minutes remaining until class starts (can be negative if class is in progress)

**Empty Response** (204 No Content):
- Returned when there are no upcoming classes

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV

---

### 5.4 Get Grades

**Endpoint**: `GET /grades`  
**Authentication**: Required

**Query Parameters**:
- `filter_by_semester` (string, optional): Filter by semester (e.g., "HK1_2024-2025")

**Success Response** (200 OK):
```json
{
  "grades": [
    {
      "hocKy": "HK1_2024-2025",
      "maMonHoc": "IE307",
      "tenMonHoc": "Công nghệ Web và ứng dụng",
      "soTinChi": 4,
      "diemTongKet": 8.5
    },
    {
      "hocKy": "HK1_2024-2025",
      "maMonHoc": "IT001",
      "tenMonHoc": "Nhập môn lập trình",
      "soTinChi": 4,
      "diemTongKet": 9.0
    }
  ],
  "message": null
}
```

**Empty Response** (200 OK):
```json
{
  "grades": [],
  "message": "Chưa có dữ liệu"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `500 Internal Server Error`: Cannot load grades
  ```json
  {
    "grades": [],
    "message": "Không thể tải dữ liệu"
  }
  ```

**Examples**:
- Get all grades: `GET /grades`
- Get grades for specific semester: `GET /grades?filter_by_semester=HK1_2024-2025`

---

### 5.5 Get Detailed Transcript

**Endpoint**: `GET /grades/details`  
**Authentication**: Required

**Query Parameters**:
- `filter_by_semester` (string, optional): Filter by semester (e.g., "HK1_2024-2025")

**Success Response** (200 OK):
```json
{
  "overallGpa": 3.45,
  "accumulatedCredits": 80,
  "semesters": [
    {
      "hocKy": "HK1_2024-2025",
      "subjects": [
        {
          "hocKy": "HK1_2024-2025",
          "maMonHoc": "IE307",
          "tenMonHoc": "Công nghệ Web và ứng dụng",
          "soTinChi": 4,
          "trongSoQuaTrinh": 10,
          "trongSoGiuaKi": 20,
          "trongSoThucHanh": 10,
          "trongSoCuoiKi": 60,
          "diemQuaTrinh": 8.0,
          "diemGiuaKi": 7.5,
          "diemThucHanh": 9.0,
          "diemCuoiKi": 8.5,
          "diemTongKet": 8.3
        },
        {
          "hocKy": "HK1_2024-2025",
          "maMonHoc": "IT001",
          "tenMonHoc": "Nhập môn lập trình",
          "soTinChi": 4,
          "trongSoQuaTrinh": 10,
          "trongSoGiuaKi": 20,
          "trongSoThucHanh": 20,
          "trongSoCuoiKi": 50,
          "diemQuaTrinh": 9.5,
          "diemGiuaKi": 9.0,
          "diemThucHanh": 9.5,
          "diemCuoiKi": 8.5,
          "diemTongKet": 9.0
        }
      ],
      "semesterGpa": 8.65
    }
  ]
}
```

**Field Descriptions**:
- `trongSo*`: Weight percentages for each grade component (sum = 100)
- `diem*`: Scores for each component (0-10 scale)
- `diemTongKet`: Final grade (weighted average of components)
- Note: Weight and score fields can be `null` if not applicable for the subject

**Empty Response** (200 OK):
```json
{
  "overallGpa": 0.0,
  "accumulatedCredits": 0,
  "semesters": []
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `500 Internal Server Error`: Cannot load transcript
  ```json
  {
    "overallGpa": 0.0,
    "accumulatedCredits": 0,
    "semesters": []
  }
  ```

---

### 5.6 Get Training Scores

**Endpoint**: `GET /training-scores`  
**Authentication**: Required

**Query Parameters**:
- `filter_by_semester` (string, optional): Filter by semester (e.g., "HK1_2024-2025")

**Success Response** (200 OK):
```json
{
  "trainingScores": [
    {
      "hocKy": "HK1_2024-2025",
      "tongDiem": 85,
      "xepLoai": "Giỏi",
      "tinhTrang": "Đã xác nhận"
    },
    {
      "hocKy": "HK2_2023-2024",
      "tongDiem": 92,
      "xepLoai": "Xuất sắc",
      "tinhTrang": "Đã xác nhận"
    }
  ],
  "message": null
}
```

**Field Descriptions**:
- `tongDiem`: Total training score (0-100)
- `xepLoai`: Classification based on score:
  - ≥ 90: "Xuất sắc" (Excellent)
  - ≥ 80: "Giỏi" (Good)
  - ≥ 70: "Khá" (Fair)
  - ≥ 60: "Trung bình khá" (Average)
  - < 60: "Trung bình" (Below Average)
- `tinhTrang`: Status (e.g., "Đã xác nhận" = Confirmed)

**Empty Response** (200 OK):
```json
{
  "trainingScores": [],
  "message": "Đang chờ xác nhận"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV

---

### 5.7 Get Tuition Information

**Endpoint**: `GET /api/students/tuition`  
**Authentication**: Required

**Query Parameters**:
- `filter_by_year` (string, optional): Filter by academic year (e.g., "2024-2025")

**Success Response** (200 OK):
```json
{
  "tongHocPhi": 15000000,
  "tongDaDong": 10000000,
  "tongConLai": 5000000,
  "chiTietHocPhi": [
    {
      "hocKy": "HK1_2024-2025",
      "soTinChi": 20,
      "hocPhi": 7500000,
      "noHocKyTruoc": 0,
      "daDong": 5000000,
      "soTienConLai": 2500000
    },
    {
      "hocKy": "HK2_2024-2025",
      "soTinChi": 20,
      "hocPhi": 7500000,
      "noHocKyTruoc": 2500000,
      "daDong": 5000000,
      "soTienConLai": 2500000
    }
  ]
}
```

**Field Descriptions**:
- All amounts are in VND (Vietnamese Dong)
- `tongHocPhi`: Total tuition fees
- `tongDaDong`: Total amount paid
- `tongConLai`: Total remaining balance
- `noHocKyTruoc`: Debt from previous semester

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `404 Not Found`: No tuition data
  ```json
  "Chưa phát sinh học phí"
  ```

---

### 5.8 Get Training Progress

**Endpoint**: `GET /api/students/progress`  
**Authentication**: Required

**Query Parameters**: None

**Success Response** (200 OK):
```json
{
  "progressByGroup": [
    {
      "groupName": "dai_cuong",
      "completedCredits": 25,
      "gpa": 3.2
    },
    {
      "groupName": "co_so",
      "completedCredits": 30,
      "gpa": 3.5
    },
    {
      "groupName": "chuyen_nganh",
      "completedCredits": 20,
      "gpa": 3.8
    },
    {
      "groupName": "tot_nghiep",
      "completedCredits": 5,
      "gpa": 4.0
    }
  ],
  "graduationProgress": {
    "totalCreditsRequired": 125,
    "totalCreditsCompleted": 80,
    "completionPercentage": 64.0
  }
}
```

**Field Descriptions**:
- `progressByGroup`: Progress breakdown by course groups
  - `groupName`: Course group name
    - `"dai_cuong"`: General education
    - `"co_so"`: Foundation courses
    - `"chuyen_nganh"`: Major courses
    - `"tot_nghiep"`: Graduation project
  - `completedCredits`: Credits completed in this group
  - `gpa`: GPA for this group
- `graduationProgress`: Overall graduation progress
  - `totalCreditsRequired`: Total credits needed for graduation (varies by major)
  - `totalCreditsCompleted`: Total credits completed across all groups
  - `completionPercentage`: Percentage towards graduation

**Credits Required by Major**:
- Công nghệ thông tin: 125
- Thương mại điện tử: 125
- Khoa học máy tính: 126
- Trí tuệ nhân tạo: 128
- Kỹ thuật máy tính: 128
- An toàn thông tin: 129
- Kỹ thuật phần mềm: 130
- Mạng máy tính và truyền thông dữ liệu: 130
- Hệ thống Thông tin: 132
- Thiết kế vi mạch: 132
- Khoa học dữ liệu: 123

**Error Responses**:
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Invalid MSSV
- `404 Not Found`: Student information not found
  ```json
  "Không tìm thấy thông tin sinh viên."
  ```

---

### 5.9 Get Academic Plan

**Endpoint**: `GET /api/public/academic-plan`  
**Authentication**: None (Public)

**Query Parameters**:
- `download_image` (boolean, optional): Reserved for future use (not implemented)

**Success Response** (200 OK):
```json
{
  "Biểu đồ kế hoạch đào tạo K2023": "https://student.uit.edu.vn/sites/default/files/inline-images/bieu-do-ke-hoach-dao-tao-k2023.png"
}
```

**Notes**:
- Scrapes the academic plan image from the university website
- Returns a dictionary with image description as key and image URL as value
- Typically returns one entry with the latest academic plan diagram

**Error Responses**:
- `404 Not Found`: No data available
  ```json
  "Dữ liệu chưa được công bố"
  ```
- `500 Internal Server Error`: Error scraping website
  ```json
  "An error occurred: ..."
  ```

---

## 6. Error Handling

### Common Error Response Format

All error responses follow a consistent structure:

```json
{
  "error": "Error message description"
}
```

or

```json
{
  "message": "Error message description"
}
```

or for validation errors:

```json
{
  "fieldName": ["Validation error message"]
}
```

### HTTP Status Codes

- **200 OK**: Successful request
- **201 Created**: Resource successfully created
- **204 No Content**: Successful request with no data to return
- **400 Bad Request**: Invalid request parameters or body
- **401 Unauthorized**: Missing or invalid authentication token
- **403 Forbidden**: Valid token but insufficient permissions
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource conflict (e.g., duplicate entry)
- **500 Internal Server Error**: Server-side error

### Common Error Scenarios

1. **Missing Authentication Token**:
   - Status: `401 Unauthorized`
   - Common endpoints: All endpoints except public ones

2. **Invalid MSSV Format**:
   - Status: `403 Forbidden`
   - Occurs when MSSV from token cannot be parsed

3. **Database Connection Issues**:
   - Status: `500 Internal Server Error`
   - Message varies by endpoint

4. **Invalid Input Data**:
   - Status: `400 Bad Request`
   - Returns validation errors for specific fields

5. **Resource Not Found**:
   - Status: `404 Not Found`
   - Common when accessing non-existent records or unauthorized access

---

## 7. Authentication Flow

### Step 1: Login

1. User provides credentials (userId, password, role)
2. Backend validates credentials against database
3. If valid, generates JWT token containing:
   - `NameIdentifier` claim: MSSV (for students) or employee ID
   - `Role` claim: User role (student/lecturer/admin)
4. Returns token to client

### Step 2: Making Authenticated Requests

1. Include JWT token in request headers:
   ```
   Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

2. Backend validates token:
   - Checks signature
   - Verifies expiration
   - Extracts claims (MSSV, role)

3. Backend processes request based on user identity

### Token Structure

JWT tokens contain:
- **Header**: Algorithm and token type
- **Payload**: 
  - `NameIdentifier`: User ID (MSSV for students)
  - `Role`: User role
  - `exp`: Expiration timestamp
  - `iss`: Issuer
  - `aud`: Audience
- **Signature**: Validates token integrity

### Token Expiration

- Token lifetime configured in `appsettings.json`
- When token expires, user must log in again
- No refresh token mechanism currently implemented

### Security Considerations

1. **HTTPS**: Always use HTTPS in production to protect token transmission
2. **Token Storage**: Store token securely on client side (not in localStorage for web apps)
3. **Token Validation**: Backend validates every request
4. **Role-Based Access**: Some endpoints restrict access to specific roles (e.g., `/api/auth/profile` only for students)
5. **SQL Injection Prevention**: All database queries use parameterized queries

---

## Additional Notes

### Date/Time Formats

- **Request**: Use ISO 8601 format (`YYYY-MM-DDTHH:mm:ss`)
  - Example: `"2024-12-20T14:00:00"`
- **Response**: May include timezone offset
  - Example: `"2024-12-20T14:00:00+07:00"`
- **Date-only fields**: May omit time portion
  - Example: `"2024-12-20"`

### File Upload Guidelines

1. **Supported formats**:
   - Images: `.jpg`, `.jpeg`, `.png`
   - Documents: `.pdf`

2. **Size limits**:
   - Language certificates: 5 MB
   - Tuition extension documents: 10 MB

3. **File naming**:
   - System generates unique filenames: `{mssv}_{yyyyMMdd}_{guid}.{ext}`

4. **Storage location**:
   - Language certificates: `wwwroot/uploads/certificates/`
   - Tuition extensions: `wwwroot/uploads/tuition-extensions/`

### Database Functions

Many endpoints rely on PostgreSQL stored functions:
- `func_get_student_schedule()`: Retrieve class schedule
- `func_get_student_exam_schedule()`: Retrieve exam schedule
- `func_calculate_gpa()`: Calculate GPA
- `func_get_student_full_transcript()`: Retrieve full transcript
- `func_get_student_semester_transcript_details()`: Retrieve detailed semester transcript
- `func_request_confirmation_letter()`: Create confirmation letter
- `func_submit_language_certificate()`: Submit language certificate
- `func_register_parking_pass()`: Register parking pass
- `func_get_student_tuition()`: Retrieve tuition information
- `func_calculate_progress_tracking()`: Calculate training progress
- `func_get_next_class()`: Get next scheduled class

### Nullable Fields

Many fields in responses can be `null`:
- `location`, `description` in personal events
- `ghiChu` (notes) in schedule
- `expiryDate` in language certificates
- `supportingDocs` in tuition extensions
- Weight and score components in detailed transcript
- Family member information in student profile

Always check for `null` values when processing responses.

### Pagination

Currently, most list endpoints return all matching records without pagination. For large datasets, consider implementing:
- `page` parameter (page number, 1-based)
- `pageSize` parameter (items per page)
- Response metadata (total count, total pages, current page)

This will be implemented in future versions.

---

**Documentation Version**: 1.0  
**Last Updated**: December 2024  
**Contact**: For API support, contact the development team.
