# Flutter API Integration Guide

Hướng dẫn sử dụng các service APIs đã được tích hợp.

## 📋 Mục lục

1. [Cài đặt](#cài-đặt)
2. [Cấu trúc dự án](#cấu-trúc-dự-án)
3. [Sử dụng các Services](#sử-dụng-các-services)
4. [Xử lý lỗi](#xử-lý-lỗi)
5. [Best Practices](#best-practices)

---

## Cài đặt

### 1. Cập nhật pubspec.yaml

Thêm `.env` vào assets:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - .env
```

Chạy lệnh:
```bash
flutter pub get
```

### 2. Cấu hình .env

File `.env` đã được tạo với nội dung:
```
API_URL=http://localhost:5128
```

### 3. Khởi tạo trong main.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/content_service.dart';
import 'services/service_api_service.dart';
import 'services/schedule_service.dart';
import 'services/student_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize services
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final contentService = ContentService(apiClient);
  final serviceApiService = ServiceApiService(apiClient);
  final scheduleService = ScheduleService(apiClient);
  final studentService = StudentService(apiClient);
  
  runApp(MyApp(
    authService: authService,
    contentService: contentService,
    serviceApiService: serviceApiService,
    scheduleService: scheduleService,
    studentService: studentService,
  ));
}
```

---

## Cấu trúc dự án

```
lib/
├── models/
│   ├── auth_models.dart           # LoginRequest, LoginResponse, StudentProfile
│   ├── content_models.dart        # NewsItem, Regulation
│   ├── service_models.dart        # ConfirmationLetter, LanguageCertificate, ParkingPass, Appeal
│   ├── schedule_models.dart       # ScheduleClass, ExamSchedule, PersonalEvent
│   └── student_models.dart        # StudentCard, Grade, Transcript, TuitionDetail
├── services/
│   ├── api_client.dart            # Core HTTP client với token management
│   ├── auth_service.dart          # Authentication APIs
│   ├── content_service.dart       # News & Regulations APIs
│   ├── service_api_service.dart   # Service request APIs
│   ├── schedule_service.dart      # Schedule & Exam APIs
│   └── student_service.dart       # Student data APIs
└── .env                           # API_URL configuration
```

---

## Sử dụng các Services

### 🔐 Authentication Service

#### Login
```dart
import 'models/auth_models.dart';
import 'services/auth_service.dart';

Future<void> performLogin() async {
  final authService = AuthService(apiClient);
  
  try {
    final request = LoginRequest(
      userId: '22520001',
      password: 'password123',
      role: 'student', // hoặc 'giang_vien', 'admin'
    );
    
    final response = await authService.login(request);
    
    // Lưu token
    await authService.saveToken(response.token);
    
    print('Login thành công!');
    print('Token: ${response.token}');
    print('Profile: ${response.profile?.hoTen}');
  } on ApiException catch (e) {
    if (e.isUnauthorized) {
      print('Sai tài khoản hoặc mật khẩu');
    } else {
      print('Lỗi: ${e.message}');
    }
  }
}
```

#### Get Profile
```dart
Future<void> loadProfile() async {
  final authService = AuthService(apiClient);
  
  try {
    final profile = await authService.getProfile();
    
    print('Họ tên: ${profile.hoTen}');
    print('MSSV: ${profile.mssv}');
    print('Lớp: ${profile.lop}');
    print('GPA: ${profile.gpa}');
  } catch (e) {
    print('Lỗi tải profile: $e');
  }
}
```

---

### 📰 Content Service

#### Get News
```dart
import 'services/content_service.dart';

Future<void> loadNews() async {
  final contentService = ContentService(apiClient);
  
  try {
    final newsList = await contentService.getLatestNews();
    
    for (var news in newsList) {
      print('${news.tieuDe} - ${news.ngayDang}');
    }
  } catch (e) {
    print('Lỗi tải tin tức: $e');
  }
}
```

#### Get Regulations
```dart
Future<void> searchRegulations(String keyword) async {
  final contentService = ContentService(apiClient);
  
  try {
    final result = await contentService.getRegulations(searchTerm: keyword);
    
    print('Tìm thấy ${result.totalCount} văn bản');
    for (var regulation in result.items) {
      print('${regulation.tenVanBan} - ${regulation.soKyHieu}');
    }
  } catch (e) {
    print('Lỗi tìm kiếm: $e');
  }
}
```

#### Download Regulation
```dart
Future<void> downloadFile(String fileName) async {
  final contentService = ContentService(apiClient);
  
  try {
    final bytes = await contentService.downloadRegulation(fileName);
    
    // Lưu file
    final file = File('/path/to/save/$fileName');
    await file.writeAsBytes(bytes);
    
    print('Tải file thành công: ${bytes.length} bytes');
  } catch (e) {
    print('Lỗi tải file: $e');
  }
}
```

---

### 📋 Service API Service

#### Request Confirmation Letter
```dart
import 'models/service_models.dart';
import 'services/service_api_service.dart';

Future<void> requestLetter() async {
  final serviceApi = ServiceApiService(apiClient);
  
  try {
    final request = ConfirmationLetterRequest(
      letterType: 'confirmation',  // hoặc 'transcript', 'internship', etc.
      quantity: 2,
      reason: 'Xin việc',
      recipientName: 'Công ty ABC',
      recipientAddress: '123 Đường XYZ, Q1, TP.HCM',
    );
    
    final response = await serviceApi.requestConfirmationLetter(request);
    
    print('Đã tạo đơn: ${response.requestId}');
    print('Trạng thái: ${response.status}');
    print('Phí: ${response.fee} VND');
  } catch (e) {
    print('Lỗi tạo đơn: $e');
  }
}
```

#### Submit Language Certificate
```dart
Future<void> submitCertificate(File certificateFile) async {
  final serviceApi = ServiceApiService(apiClient);
  
  try {
    await serviceApi.submitLanguageCertificate(
      certificateType: 'TOEIC',
      score: 850,
      issueDate: DateTime(2024, 1, 15),
      expiryDate: DateTime(2026, 1, 15),
      file: certificateFile,
    );
    
    print('Đã nộp chứng chỉ thành công!');
  } catch (e) {
    print('Lỗi nộp chứng chỉ: $e');
  }
}
```

#### Register Parking Pass
```dart
Future<void> registerParking() async {
  final serviceApi = ServiceApiService(apiClient);
  
  try {
    final request = ParkingPassRequest(
      vehicleType: 'motorbike',  // hoặc 'bicycle'
      licensePlate: '59A1-12345',
      color: 'Đen',
      brand: 'Honda Wave',
      vehicleRegistrationImage: 'path/to/image.jpg',
    );
    
    final response = await serviceApi.registerParkingPass(request);
    
    print('Đăng ký thành công!');
    print('Phí: ${response.fee} VND');
  } catch (e) {
    print('Lỗi đăng ký: $e');
  }
}
```

#### Submit Appeal
```dart
Future<void> submitAppeal() async {
  final serviceApi = ServiceApiService(apiClient);
  
  try {
    final request = AppealRequest(
      appealType: 'grade',  // hoặc 'exam', 'tuition', 'other'
      subject: 'Phúc khảo môn Toán',
      description: 'Em xin phúc khảo điểm thi cuối kỳ',
      paymentMethod: 'banking',  // hoặc 'cash', 'momo', 'vnpay'
      supportingDocs: ['file1.pdf', 'file2.jpg'],
    );
    
    final response = await serviceApi.submitAppeal(request);
    
    print('Đã nộp đơn: ${response.appealId}');
    print('Trạng thái: ${response.status}');
  } catch (e) {
    print('Lỗi nộp đơn: $e');
  }
}
```

---

### 📅 Schedule Service

#### Get Class Schedule
```dart
import 'services/schedule_service.dart';

Future<void> loadSchedule() async {
  final scheduleService = ScheduleService(apiClient);
  
  try {
    final response = await scheduleService.getClassSchedule(
      viewMode: 'week',  // 'day', 'week', 'month', 'all'
      filterByCourse: 'IT001',  // optional
      filterByLecturer: 'Nguyễn Văn A',  // optional
    );
    
    print('Tuần học: ${response.currentWeek}');
    print('Có ${response.classes.length} lớp');
    
    for (var cls in response.classes) {
      print('${cls.tenMonHoc} - ${cls.phongHoc} - Tiết ${cls.tietBatDau}');
    }
  } catch (e) {
    print('Lỗi tải lịch: $e');
  }
}
```

#### Get Exam Schedule
```dart
Future<void> loadExams() async {
  final scheduleService = ScheduleService(apiClient);
  
  try {
    final response = await scheduleService.getExamSchedule(
      filterBySemester: 'HK1_2024-2025',  // optional
      filterByGroup: 'GK',  // 'GK' (giữa kỳ) hoặc 'CK' (cuối kỳ)
    );
    
    print('Có ${response.exams.length} lịch thi');
    
    for (var exam in response.exams) {
      print('${exam.tenMonHoc} - ${exam.ngayThi} - ${exam.phongThi}');
    }
  } catch (e) {
    print('Lỗi tải lịch thi: $e');
  }
}
```

#### Create Personal Event
```dart
Future<void> createEvent() async {
  final scheduleService = ScheduleService(apiClient);
  
  try {
    final request = PersonalEventRequest(
      title: 'Họp nhóm đồ án',
      description: 'Thảo luận chương 3',
      startTime: DateTime(2024, 6, 15, 14, 0),
      endTime: DateTime(2024, 6, 15, 16, 0),
      location: 'Phòng A201',
      color: '#FF5733',
    );
    
    final response = await scheduleService.createPersonalEvent(request);
    
    if (response.conflicts.isNotEmpty) {
      print('Cảnh báo: Bị trùng với ${response.conflicts.length} sự kiện');
      for (var conflict in response.conflicts) {
        print('  - ${conflict.conflictType}: ${conflict.title}');
      }
    } else {
      print('Tạo sự kiện thành công!');
    }
  } catch (e) {
    print('Lỗi tạo sự kiện: $e');
  }
}
```

---

### 🎓 Student Service

#### Get Student Card
```dart
import 'services/student_service.dart';

Future<void> loadStudentCard() async {
  final studentService = StudentService(apiClient);
  
  try {
    final card = await studentService.getStudentCard();
    
    print('MSSV: ${card.mssv}');
    print('Họ tên: ${card.hoTen}');
    print('Lớp: ${card.lop}');
    print('Khóa: ${card.khoa}');
  } catch (e) {
    print('Lỗi tải thẻ SV: $e');
  }
}
```

#### Get Grades
```dart
Future<void> loadGrades() async {
  final studentService = StudentService(apiClient);
  
  try {
    final response = await studentService.getGrades(
      filterBySemester: 'HK1_2024-2025',  // optional
    );
    
    print('GPA: ${response.overallGpa}');
    print('Tổng tín chỉ: ${response.totalCredits}');
    
    for (var grade in response.grades) {
      print('${grade.tenMonHoc}: ${grade.diemTongKet} (${grade.diemChu})');
    }
  } catch (e) {
    print('Lỗi tải điểm: $e');
  }
}
```

#### Get Detailed Transcript
```dart
Future<void> loadTranscript() async {
  final studentService = StudentService(apiClient);
  
  try {
    final overview = await studentService.getDetailedTranscript();
    
    print('GPA tích lũy: ${overview.overallGpa}');
    print('Tín chỉ tích lũy: ${overview.totalCreditsEarned}');
    
    for (var semester in overview.semesters) {
      print('\n${semester.hocKy} - GPA: ${semester.gpa}');
      
      for (var grade in semester.subjects) {
        if (grade.details != null) {
          final details = grade.details!;
          print('  ${grade.tenMonHoc}:');
          print('    - Quá trình: ${details.diemQuaTrinh}');
          print('    - Giữa kỳ: ${details.diemGiuaKi}');
          print('    - Cuối kỳ: ${details.diemCuoiKi}');
          print('    - Tổng kết: ${details.diemTongKet}');
        }
      }
    }
  } catch (e) {
    print('Lỗi tải bảng điểm: $e');
  }
}
```

#### Get Tuition
```dart
Future<void> loadTuition() async {
  final studentService = StudentService(apiClient);
  
  try {
    final tuition = await studentService.getTuition(
      filterByStatus: 'unpaid',  // 'paid', 'unpaid', 'all'
    );
    
    print('Tổng học phí: ${tuition.total.tongHocPhi} VND');
    print('Đã đóng: ${tuition.total.daDong} VND');
    print('Còn nợ: ${tuition.total.conNo} VND');
    
    for (var detail in tuition.details) {
      print('${detail.hocKy}: ${detail.conNo} VND');
    }
  } catch (e) {
    print('Lỗi tải học phí: $e');
  }
}
```

#### Get Training Progress
```dart
Future<void> loadProgress() async {
  final studentService = StudentService(apiClient);
  
  try {
    final progress = await studentService.getTrainingProgress();
    
    print('Tiến độ tốt nghiệp: ${progress.overall.completionPercentage}%');
    print('TC tích lũy: ${progress.overall.currentCredits}/${progress.overall.requiredCredits}');
    
    print('\nNhóm Đại cương: ${progress.groups.daiCuong.completedCredits}/${progress.groups.daiCuong.requiredCredits}');
    print('Nhóm Cơ sở: ${progress.groups.coSo.completedCredits}/${progress.groups.coSo.requiredCredits}');
    print('Nhóm Chuyên ngành: ${progress.groups.chuyenNganh.completedCredits}/${progress.groups.chuyenNganh.requiredCredits}');
    print('Nhóm Tốt nghiệp: ${progress.groups.totNghiep.completedCredits}/${progress.groups.totNghiep.requiredCredits}');
  } catch (e) {
    print('Lỗi tải tiến độ: $e');
  }
}
```

---

## Xử lý lỗi

### ApiException

Tất cả các service đều có thể throw `ApiException`:

```dart
try {
  final grades = await studentService.getGrades();
} on ApiException catch (e) {
  // Kiểm tra loại lỗi
  if (e.isUnauthorized) {
    // 401 - Token hết hạn, cần đăng nhập lại
    print('Vui lòng đăng nhập lại');
    // Navigate to login screen
  } else if (e.isNotFound) {
    // 404 - Không tìm thấy dữ liệu
    print('Không tìm thấy dữ liệu');
  } else if (e.isConflict) {
    // 409 - Xung đột (ví dụ: trùng lịch)
    print('Có xung đột dữ liệu');
  } else if (e.isBadRequest) {
    // 400 - Dữ liệu đầu vào không hợp lệ
    print('Dữ liệu không hợp lệ: ${e.message}');
  } else {
    // Lỗi khác
    print('Lỗi: ${e.message} (${e.statusCode})');
  }
} catch (e) {
  // Lỗi không phải API (network, parsing, etc.)
  print('Lỗi không xác định: $e');
}
```

### Status Code Helpers

```dart
ApiException:
- isUnauthorized: 401
- isNotFound: 404
- isConflict: 409
- isBadRequest: 400
- isForbidden: 403
- isServerError: 500
```

---

## Best Practices

### 1. Token Management

```dart
// Kiểm tra token trước khi gọi API
Future<bool> isAuthenticated() async {
  final token = await authService.getToken();
  return token != null && token.isNotEmpty;
}

// Auto-refresh token khi hết hạn
try {
  final data = await studentService.getGrades();
} on ApiException catch (e) {
  if (e.isUnauthorized) {
    // Thử refresh token hoặc redirect to login
    await handleTokenExpired();
  }
}
```

### 2. Loading States

```dart
class GradesScreen extends StatefulWidget {
  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  bool _isLoading = false;
  String? _error;
  GradeListResponse? _grades;
  
  Future<void> _loadGrades() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final grades = await widget.studentService.getGrades();
      setState(() {
        _grades = grades;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    _loadGrades();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    if (_error != null) return Text('Lỗi: $_error');
    if (_grades == null) return Text('Không có dữ liệu');
    
    return ListView.builder(
      itemCount: _grades!.grades.length,
      itemBuilder: (context, index) {
        final grade = _grades!.grades[index];
        return ListTile(
          title: Text(grade.tenMonHoc),
          trailing: Text(grade.diemChu ?? '-'),
        );
      },
    );
  }
}
```

### 3. Null Safety

Tất cả các model đã được xử lý null safety:

```dart
// Các field nullable sử dụng toán tử ??
final gpa = studentCard.gpa ?? 0.0;
final email = profile.email ?? 'Chưa cập nhật';

// Kiểm tra null trước khi truy cập
if (grade.details != null) {
  print('Điểm quá trình: ${grade.details!.diemQuaTrinh}');
}
```

### 4. Date Formatting

```dart
// Parse ISO 8601 dates
final examDate = DateTime.parse(exam.ngayThi);

// Format for display
final formatter = DateFormat('dd/MM/yyyy HH:mm');
print(formatter.format(examDate));

// Submit dates to API (YYYY-MM-DD)
final request = PersonalEventRequest(
  startTime: DateTime.now(),  // API client sẽ tự động format
);
```

### 5. File Upload

```dart
// Pick file từ device
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'png'],
);

if (result != null) {
  final file = File(result.files.single.path!);
  
  // Upload
  await serviceApi.submitLanguageCertificate(
    certificateType: 'TOEIC',
    score: 850,
    issueDate: DateTime(2024, 1, 15),
    expiryDate: DateTime(2026, 1, 15),
    file: file,
  );
}
```

### 6. Android Emulator

Nếu chạy trên Android emulator, ApiClient sẽ tự động map:
- `localhost` → `10.0.2.2`
- `127.0.0.1` → `10.0.2.2`

Không cần thay đổi gì trong code.

### 7. Environment Variables

```dart
// Development
API_URL=http://localhost:5128

// Staging
API_URL=https://staging-api.euit.edu.vn

// Production
API_URL=https://api.euit.edu.vn
```

Chỉ cần thay đổi `.env` file, không cần sửa code.

---

## Tổng kết

✅ **Đã tích hợp hoàn tất:**
- 25+ API endpoints
- 40+ DTO models với null safety
- 5 service classes
- Token management tự động
- Error handling đầy đủ
- File upload support
- Android emulator support

🚀 **Next Steps:**
1. Tạo Provider classes cho state management
2. Tích hợp với UI screens
3. Thêm unit tests
4. Thêm caching layer (nếu cần)

---

**Lưu ý:** Tất cả các services đều yêu cầu authentication (Bearer token) trừ các endpoint:
- `POST /api/auth/login`
- `GET /api/public/regulations`
- `GET /api/training-plan`

Hãy đảm bảo đã login và có token trước khi gọi các API khác.
