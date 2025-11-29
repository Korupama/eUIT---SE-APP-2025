# Confirmation Letter Language Support

## Overview
The confirmation letter API now supports language selection for Vietnamese (vi) and English (en).

## API Endpoint

### POST /api/service/confirmation-letter

Request a new confirmation letter with language preference.

**Request Body:**
```json
{
  "purpose": "Xin học bổng",
  "language": "vi"
}
```

**Parameters:**
- `purpose` (required): The purpose of the confirmation letter
- `language` (required): Language preference - "vi" (Vietnamese) or "en" (English). Default: "vi"

**Response (201 Created):**
```json
{
  "serialNumber": 123,
  "expiryDate": "29/12/2025"
}
```

**Error Responses:**
- 400 Bad Request: Invalid language (must be "vi" or "en")
- 401 Unauthorized: No valid JWT token
- 500 Internal Server Error: Database or server error

### GET /api/service/confirmation-letter/history

Get confirmation letter history for the authenticated student.

**Response (200 OK):**
```json
[
  {
    "serialNumber": 123,
    "purpose": "Xin học bổng",
    "language": "vi",
    "status": "active",
    "requestedAt": "29/11/2025 10:30"
  },
  {
    "serialNumber": 122,
    "purpose": "Apply for scholarship",
    "language": "en",
    "expiryDate": "15/11/2025",
    "status": "expired",
  }
]
```

## Database Changes

### Table: confirmation_letters
New column added:
- `language` VARCHAR(2) NOT NULL DEFAULT 'vi' CHECK (language IN ('vi', 'en'))

### Function: func_request_confirmation_letter
Updated signature:
```sql
func_request_confirmation_letter(
    p_mssv INTEGER,
    p_purpose TEXT,
    p_language VARCHAR(2) DEFAULT 'vi'
)
```

### Function: func_get_confirmation_letter_history
Returns language column in result set.

## Usage Examples

### Request Vietnamese Confirmation Letter
```bash
curl -X POST http://localhost:5128/api/service/confirmation-letter \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "purpose": "Xin học bổng",
    "language": "vi"
  }'
```

### Request English Confirmation Letter
```bash
curl -X POST http://localhost:5128/api/service/confirmation-letter \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "purpose": "Apply for scholarship",
    "language": "en"
  }'
```

### Get History
```bash
curl -X GET http://localhost:5128/api/service/confirmation-letter/history \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Migration Steps

1. **Update Database:**
   ```bash
   psql -U your_user -d your_database -f scripts/database/sql/confirmation_letter.sql
   ```

2. **Verify Table Structure:**
   ```sql
   \d confirmation_letters
   ```

3. **Test Functions:**
   ```sql
   -- Test Vietnamese request
   SELECT * FROM func_request_confirmation_letter(23520541, 'Xin học bổng', 'vi');
   
   -- Test English request
   SELECT * FROM func_request_confirmation_letter(23520541, 'Apply for scholarship', 'en');
   
   -- Get history
   SELECT * FROM func_get_confirmation_letter_history(23520541);
   ```

## Validation Rules

- Language must be exactly "vi" or "en" (case-sensitive)
- Default language is "vi" if not specified
- Purpose field remains required and cannot be empty
- Maximum length for purpose: 500 characters

## Notes

- Existing records without language field will default to "vi"
- The language field is stored with the request and returned in history
- The actual content translation (letter template) should be handled by the frontend or a separate service
- This feature only stores the language preference, not the translated content

