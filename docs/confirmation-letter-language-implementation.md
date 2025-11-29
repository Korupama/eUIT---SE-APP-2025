# Confirmation Letter Language Feature - Implementation Summary

## ✅ Changes Implemented

### 1. **DTOs Updated**

#### ConfirmationLetterRequestDto.cs
- Added `Language` property with validation
- Default value: "vi" (Vietnamese)
- Validation: Must be "vi" or "en"
- Validation error message in Vietnamese

```csharp
[Required(ErrorMessage = "Vui lòng chọn ngôn ngữ")]
[RegularExpression("^(vi|en)$", ErrorMessage = "Ngôn ngữ phải là 'vi' hoặc 'en'")]
public string Language { get; set; } = "vi";
```

#### ConfirmationLetterHistoryDto.cs
- Added `Language` property to both DTO and Result classes
- Added `Status` property to show active/expired status
- History now returns language preference and status for each request
### 2. **Model Updated**

#### ConfirmationLetter.cs
- Added `Language` column mapping
- MaxLength: 2 characters
- Default value: "vi"

```csharp
[Column("language")]
[MaxLength(2)]
public string Language { get; set; } = "vi";
```

### 3. **Controller Updated**

#### ServiceController.cs

##### POST /api/service/confirmation-letter
- Now accepts `language` parameter in request body
- Passes language to database function `func_request_confirmation_letter`
- Validates language is "vi" or "en"

##### GET /api/service/confirmation-letter/history
- Updated to call `func_get_confirmation_letter_history` (corrected function name)
- Returns language field in history response
- Maps language from SQL result to DTO

### 4. **Database Schema & Functions**

#### New SQL File: confirmation_letter.sql
Created comprehensive SQL with:

##### Table: confirmation_letters
```sql
CREATE TABLE IF NOT EXISTS confirmation_letters (
    letter_id SERIAL PRIMARY KEY,
    mssv INTEGER NOT NULL REFERENCES sinh_vien(mssv) ON DELETE CASCADE,
    purpose VARCHAR(500) NOT NULL,
    language VARCHAR(2) NOT NULL DEFAULT 'vi' CHECK (language IN ('vi', 'en')),
    serial_number INTEGER NOT NULL,
    expiry_date TIMESTAMP,
    requested_at TIMESTAMP DEFAULT NOW()
);
```

##### Function: func_request_confirmation_letter
```sql
func_request_confirmation_letter(
    p_mssv INTEGER,
    p_purpose TEXT,
    p_language VARCHAR(2) DEFAULT 'vi'
)
```
Features:
- Validates language is "vi" or "en"
- Validates student exists
- Validates purpose not empty
- Generates unique serial number per year
- Sets 30-day expiry date
- Stores language preference

##### Function: func_get_confirmation_letter_history
```sql
func_get_confirmation_letter_history(p_mssv INTEGER)
```
Returns all confirmation letters for a student including language.
Returns all confirmation letters for a student including language and status.
Status is calculated dynamically: 'active' if expiry_date >= NOW(), otherwise 'expired'.
```sql
func_get_all_confirmation_letters(
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
```
Admin function with pagination support.

### 5. **Documentation Created**

#### confirmation-letter-language-support.md
- Complete API documentation
- Request/response examples
- Database migration steps
- Usage examples with curl commands
- Validation rules

#### api-confirmation-letter-language-test.http
- HTTP test file with 7 test scenarios
- Tests for Vietnamese and English requests
- Validation tests (invalid language, missing fields)

## 📋 API Usage

### Request Vietnamese Letter
```json
POST /api/service/confirmation-letter
{
  "purpose": "Xin học bổng",
  "language": "vi"
}
```

### Request English Letter
```json
POST /api/service/confirmation-letter
{
  "purpose": "Apply for scholarship",
  "language": "en"
}
```

### Get History (includes language)
```json
GET /api/service/confirmation-letter/history

Response:
[
  {
    "serialNumber": 123,
    "purpose": "Xin học bổng",
    "language": "vi",
    "expiryDate": "29/12/2025",
    "requestedAt": "29/11/2025 10:30"
    "status": "active",
]
```

## 🔧 Migration Required

1. Run the SQL script:
```bash
psql -U your_user -d your_database -f scripts/database/sql/confirmation_letter.sql
```

2. Verify table structure:
```sql
\d confirmation_letters
```

3. Test functions:
```sql
SELECT * FROM func_request_confirmation_letter(23520541, 'Test purpose', 'vi');
SELECT * FROM func_get_confirmation_letter_history(23520541);
```

## ✨ Key Features

- ✅ Language validation at DTO level
- ✅ Database constraint ensures only "vi" or "en"
- ✅ Default to Vietnamese if not specified
- ✅ Language stored with each request
- ✅ History shows language for each letter
- ✅ Backward compatible (defaults to "vi")
- ✅ Comprehensive error handling
- ✅ Complete documentation and tests

## 📝 Notes

- The language field stores the **preference**, not the translated content
- Frontend should handle actual translation based on this field
- Existing records will default to "vi" in the database
- All validation messages are in Vietnamese (can be localized if needed)

## 🎯 Next Steps (Optional)

1. Add admin endpoint to view all confirmation letters
2. Add filtering by language in history endpoint
3. Add statistics by language preference
4. Create actual letter templates for both languages
5. Add language preference to user profile settings

