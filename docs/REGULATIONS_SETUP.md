# Regulations (Quy Chế) Feature Implementation Guide

## Overview
This document describes how to load and display regulations from PDF files in the StaticContent/documents directory.

## Architecture

### Backend (.NET Core 9)
- **Controller**: `RegulationsController.cs` at `/api/public/regulations`
- **Database**: PostgreSQL table `van_ban` with columns:
  - `ten_van_ban` (VARCHAR 255) - Regulation title (Primary Key)
  - `url_van_ban` (VARCHAR 255) - PDF filename
  - `ngay_ban_hanh` (DATE, nullable) - Date of regulation

- **Static Files**: Served from `/src/backend/StaticContent/documents/` via `/files/` route
  - 31 PDF files with Vietnamese regulations

### Mobile (Flutter)
- **Screen**: `TrainingRegulationsScreen` and `PlanScreen` 
- **Provider**: `AcademicProvider` - manages regulations list
- **UI Components**:
  - Search box with live filtering
  - List of regulations with titles and dates
  - PDF viewer using `pdfrx` library
  
- **Models**: `Regulation` class in `content_models.dart`
  ```dart
  class Regulation {
    final String tenVanBan;
    final String urlVanBan;
    final DateTime? ngayBanHanh;
  }
  ```

- **API Integration**: `ContentService.getRegulations(query)` 

## Setup Instructions

### 1. Load Data into Database

#### Option A: Using Admin Endpoint (Recommended)
```bash
# 1. Start the backend
cd /Users/home/Documents/GitHub/eUIT---SE-APP-2025/src/backend
dotnet run

# 2. In another terminal, call the seed endpoint
curl -X POST http://localhost:5128/api/admin/seed-regulations

# Response:
# {
#   "message": "Successfully loaded 31 regulations",
#   "count": 31
# }
```

#### Option B: Using psql Directly
```bash
# Run the generated SQL file
psql -h localhost -U postgres -d eUIT -f /Users/home/Documents/GitHub/eUIT---SE-APP-2025/scripts/database/sql/load_regulations_data.sql
```

#### Option C: Using Python Script
```bash
# Generate SQL and save to file
python3 /Users/home/Documents/GitHub/eUIT---SE-APP-2025/scripts/database/sql/load_regulations.py > regulations.sql

# Then execute the SQL file
```

### 2. Verify Data is Loaded

```bash
# Check regulations in database
curl http://localhost:5128/api/public/regulations

# Should return JSON like:
# {
#   "message": "Success",
#   "data": [
#     {
#       "tenVanBan": "Quy trình xử lý học vụ...",
#       "urlVanBan": "http://localhost:5128/files/Quy%20tri%cc%80nh%20xu%cc%89%20ly%CC%81%20ho%CC%A3c%20vu%CC%A3%20...",
#       "ngayBanHanh": null
#     },
#     ...
#   ]
# }
```

### 3. Test Search Functionality

```bash
# Search for a regulation
curl "http://localhost:5128/api/public/regulations?search_term=quy"

# Should return filtered results
```

### 4. Mobile Integration

#### Build and Run
```bash
cd /Users/home/Documents/GitHub/eUIT---SE-APP-2025/src/mobile
flutter pub get
flutter run -d "sdk gphone64 arm64"
```

#### Navigation
- Go to **Menu** (☰)
- Tap **Quy chế & Đào tạo** (Regulations & Training)
- View the regulations list
- Tap any regulation to open the PDF

## File Structure

```
src/
├── backend/
│   ├── StaticContent/
│   │   └── documents/
│   │       ├── 1139_qd-dhcntt_20-12-2022_to_chuc_thi_cac_mon_hoc_he_dai_hoc_chinh_quy.pdf
│   │       ├── 1393-qd-dhcntt_29-12-2023_cap_nhat_quy_che_dao_tao_theo_hoc_che_tin_chi_cho_he_dai_hoc_chinh_quy.pdf
│   │       └── ... (29 more PDF files)
│   ├── Controllers/
│   │   ├── RegulationsController.cs
│   │   └── AdminController.cs (with seed-regulations endpoint)
│   └── Program.cs (configures static file serving)
├── mobile/
│   ├── lib/
│   │   ├── screens/search/
│   │   │   ├── plan_screen.dart
│   │   │   └── trainingregulations_screen.dart
│   │   ├── providers/
│   │   │   └── academic_provider.dart
│   │   ├── services/
│   │   │   └── content_service.dart
│   │   └── models/
│   │       └── content_models.dart
│   └── pubspec.yaml (includes pdfrx dependency)
└── scripts/
    └── database/
        └── sql/
            ├── load_regulations.py (Python script to generate SQL)
            ├── load_regulations_insert.sql (Generated SQL)
            └── load_regulations_data.sql (Manually formatted SQL)
```

## Key Files to Edit

If you need to make changes:

### Backend
- `src/backend/Controllers/RegulationsController.cs` - API responses
- `src/backend/Program.cs` - Static file serving configuration
- `src/backend/appsettings.Example.json` - Database connection

### Mobile
- `src/mobile/lib/providers/academic_provider.dart` - Data management
- `src/mobile/lib/screens/search/plan_screen.dart` - UI
- `src/mobile/lib/services/content_service.dart` - API calls
- `src/mobile/pubspec.yaml` - Dependencies

## Troubleshooting

### 1. "Chưa có dữ liệu quy chế" (No regulations data)
**Cause**: Database is empty  
**Solution**: Run the seed-regulations endpoint (see Setup section)

### 2. PDF files return 404
**Cause**: Static file middleware not configured  
**Solution**: Check `Program.cs` has:
```csharp
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(Path.Combine(builder.Environment.ContentRootPath, "StaticContent")),
    RequestPath = "/files"
});
```

### 3. Search not working
**Cause**: UI not passing search term to API  
**Solution**: Verify `AcademicProvider.fetchRegulations(searchTerm)` is called in search box `onChanged`

### 4. PDF viewer shows blank page
**Cause**: URL format issue  
**Solution**: Ensure `PdfViewer.uri(Uri.parse(url))` receives valid absolute URL

## Data Loading Details

### Automatic from Seeder
The Python script `load_regulations.py`:
- Scans `/src/backend/StaticContent/documents/` for PDF files
- Extracts filenames without extension as regulation titles
- Tries to parse dates from filenames (YYYY-MM-DD format)
- Generates SQL INSERT statements with ON CONFLICT clause for idempotency

### SQL Generation
```sql
INSERT INTO van_ban (ten_van_ban, url_van_ban, ngay_ban_hanh) 
VALUES ('Quy trình...', 'Quy trinh....pdf', NULL) 
ON CONFLICT (ten_van_ban) 
DO UPDATE SET url_van_ban = EXCLUDED.url_van_ban, ngay_ban_hanh = EXCLUDED.ngay_ban_hanh;
```

This allows safe re-running without duplicate key errors.

## API Endpoints

### Get All Regulations (Public)
```
GET /api/public/regulations
Response: { message: "Success", data: [...] }
```

### Search Regulations (Public)
```
GET /api/public/regulations?search_term=quy
Response: { message: "Success", data: [...filtered...] }
```

### Download Regulation (Public)
```
GET /api/public/regulations/download?filename=xxx.pdf&download=true
Returns: PDF file with proper headers
```

### Seed Regulations (Admin Only)
```
POST /api/admin/seed-regulations
Response: { message: "Successfully loaded X regulations", count: X }
```

## Next Steps

1. ✅ Database schema created (`van_ban` table)
2. ✅ Backend API endpoints implemented
3. ✅ PDF files in `StaticContent/documents`
4. ✅ Mobile UI screens created with PDF viewer
5. ✅ Data loading script and admin endpoint
6. ⏳ **Run seed-regulations endpoint to populate database**
7. ⏳ Test the mobile app with loaded regulations

## Notes

- All 31 PDF files are Vietnamese regulations and training guidelines
- Database dates are currently NULL (can be extracted/added manually if needed)
- Search is case-insensitive using PostgreSQL ILIKE operator
- PDF viewer uses pdfrx library with inline viewing support
- Static files are served with proper MIME types (application/pdf)
