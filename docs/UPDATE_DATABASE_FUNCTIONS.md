# 🔧 Cập nhật Database - SQL Functions

## ✅ Đã sửa các vấn đề về data types

### 1. Models đã được cập nhật:

#### ConfirmationLetter.cs
```csharp
- mssv: string → int
- serial_number: string → int
- expiry_date: DateTime → DateTime?
- Table name: "confirmation_letters"
```

#### LanguageCertificate.cs
```csharp
- mssv: string → int
- score: double → float (real)
- expiry_date: DateTime → DateTime?
- Table name: "language_certificates"
```

---

## 🗄️ Chạy SQL Script

### Bước 1: Kết nối PostgreSQL

```bash
psql -U postgres -d eUIT
```

Hoặc dùng pgAdmin/DataGrip

---

### Bước 2: Chạy file SQL

```sql
-- File: scripts/database/sql/history_functions.sql
```

Hoặc copy paste trực tiếp:

```sql
-- Function: Lấy lịch sử giấy xác nhận sinh viên
CREATE OR REPLACE FUNCTION func_get_confirmation_letter_status(p_mssv integer)
RETURNS TABLE (
    letter_id integer,
    mssv integer,
    purpose text,
    serial_number integer,
    expiry_date date,
    requested_at timestamp with time zone
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        cl.letter_id,
        cl.mssv,
        cl.purpose,
        cl.serial_number,
        cl.expiry_date,
        cl.requested_at
    FROM confirmation_letters cl
    WHERE cl.mssv = p_mssv
    ORDER BY cl.requested_at DESC;
END;
$$;

-- Function: Lấy lịch sử chứng chỉ ngoại ngữ
CREATE OR REPLACE FUNCTION func_get_language_certificate_status(p_mssv integer)
RETURNS TABLE (
    id integer,
    mssv integer,
    certificate_type varchar(50),
    score real,
    issue_date date,
    expiry_date date,
    file_path text,
    status varchar(20),
    created_at timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        lc.id,
        lc.mssv,
        lc.certificate_type,
        lc.score,
        lc.issue_date,
        lc.expiry_date,
        lc.file_path,
        lc.status,
        lc.created_at
    FROM language_certificates lc
    WHERE lc.mssv = p_mssv
    ORDER BY lc.created_at DESC;
END;
$$;
```

---

### Bước 3: Kiểm tra functions đã được tạo

```sql
-- Kiểm tra function existence
SELECT proname, pg_get_function_arguments(oid) 
FROM pg_proc 
WHERE proname LIKE 'func_get_%_status';

-- Test với MSSV thật
SELECT * FROM func_get_confirmation_letter_status(23520541);
SELECT * FROM func_get_language_certificate_status(23520541);
```

---

## 🧪 Test API

### 1. Restart API server
```bash
# Stop nếu đang chạy
Ctrl + C

# Start lại
cd D:\eUIT---SE-APP-2025\src\backend
dotnet run
```

---

### 2. Test endpoints

**Login để lấy token:**
```http
POST http://localhost:5128/api/auth/login
Content-Type: application/json

{
  "mssv": "23520541",
  "password": "your_password"
}
```

**Test Language Certificate History:**
```http
GET http://localhost:5128/api/service/language-certificate/history
Authorization: Bearer {your_token}
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "certificateType": "IELTS",
    "score": 7.5,
    "issueDate": "15/01/2024",
    "expiryDate": "15/01/2026",
    "status": "PENDING",
    "filePath": "uploads/certificates/file.pdf",
    "createdAt": "20/11/2024 14:30"
  }
]
```

**Test Confirmation Letter History:**
```http
GET http://localhost:5128/api/service/confirmation-letter/history
Authorization: Bearer {your_token}
```

**Expected Response:**
```json
[
  {
    "serialNumber": 1,
    "purpose": "Xin visa du học",
    "expiryDate": "20/05/2025",
    "requestedAt": "20/11/2024 09:15"
  }
]
```

---

## ✅ Checklist

- [x] Models updated với đúng data types
- [x] DTOs updated với đúng column names
- [x] Controller mapping updated
- [x] SQL functions created
- [ ] **Run SQL script** ← BẠN CẦN LÀM BƯỚC NÀY
- [ ] Restart API
- [ ] Test endpoints

---

## 🔍 Troubleshooting

### Error: "function does not exist"
→ Chưa chạy SQL script. Chạy lại file `history_functions.sql`

### Error: "operator does not exist: integer = text"
→ Function đã được sửa, drop function cũ và tạo lại:
```sql
DROP FUNCTION IF EXISTS func_get_confirmation_letter_status(text);
DROP FUNCTION IF EXISTS func_get_language_certificate_status(text);
-- Rồi chạy lại CREATE OR REPLACE FUNCTION...
```

### Empty array []
→ Chưa có data trong bảng. Insert test data:
```sql
-- Test data for language_certificates
INSERT INTO language_certificates (mssv, certificate_type, score, issue_date, expiry_date, file_path, status)
VALUES (23520541, 'IELTS', 7.5, '2024-01-15', '2026-01-15', 'uploads/test.pdf', 'PENDING');

-- Test data for confirmation_letters
INSERT INTO confirmation_letters (mssv, purpose, serial_number, expiry_date)
VALUES (23520541, 'Xin visa du học', 1, CURRENT_DATE + INTERVAL '6 months');
```

---

## 🎯 Kết luận

Tất cả code đã được sửa đúng theo schema database thực tế:
- ✅ `mssv` type: `integer`
- ✅ `score` type: `real` (float)
- ✅ `serial_number` type: `integer`
- ✅ Nullable fields: `expiry_date`
- ✅ Table names: `confirmation_letters`, `language_certificates`

**Chỉ cần chạy SQL script là xong!**

