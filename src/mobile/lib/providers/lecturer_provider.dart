import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/lecturer_models.dart';
import '../models/teaching_class.dart';
import '../models/notification_item.dart';
import '../models/quick_action.dart';
import '../models/appeal.dart';
import '../models/document.dart';
import '../models/exam_schedule.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class LecturerProvider extends ChangeNotifier {
  final AuthService auth;
  late final ApiClient _client;

  LecturerProvider({required this.auth}) {
    _client = ApiClient(auth);
    _init();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  LecturerProfile? _lecturerProfile;
  LecturerProfile? get lecturerProfile => _lecturerProfile;

  List<TeachingScheduleItem> _teachingSchedule = [];
  List<TeachingScheduleItem> get teachingSchedule => _teachingSchedule;
  List<TeachingScheduleItem> get schedule =>
      _teachingSchedule; // Alias for compatibility

  TeachingScheduleItem? _nextClass;
  TeachingScheduleItem? get nextClass => _nextClass;
  DateTime? _nextClassDate; // Ngày cụ thể của buổi học tiếp theo
  DateTime? get nextClassDate => _nextClassDate;

  List<TeachingClass> _teachingClasses = [];
  List<TeachingClass> get teachingClasses => _teachingClasses;
  String _debugInfo = 'Not loaded yet';
  String get debugInfo => _debugInfo;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  List<QuickAction> _quickActions = [];
  List<QuickAction> get quickActions => _quickActions;

  List<Appeal> _appeals = [];
  List<Appeal> get appeals => _appeals;

  List<Document> _documents = [];
  List<Document> get documents => _documents;

  List<ExamSchedule> _examSchedules = [];
  List<ExamSchedule> get examSchedules => _examSchedules;

  Future<void> _init() async {
    print('=== LECTURER PROVIDER INIT STARTED ===');
    developer.log('=== LECTURER PROVIDER INIT STARTED ===', name: 'LecturerProvider');
    _isLoading = true;
    notifyListeners();

    try {
      // Check if we have a token first
      final token = await auth.getValidToken();
      print('Token available: ${token != null}');
      developer.log('Token available: ${token != null}', name: 'LecturerProvider');
      
      if (token == null) {
        print('No token found, skipping API calls');
        developer.log('No token found, skipping API calls', name: 'LecturerProvider');
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Starting API calls...');
      await Future.wait([
        fetchLecturerProfile(),
        fetchTeachingClasses(),
        fetchTeachingSchedule(),
        _fetchNotifications(),
      ]);
      
      print('=== LECTURER PROVIDER INIT COMPLETED ===');
      developer.log('=== LECTURER PROVIDER INIT COMPLETED ===', name: 'LecturerProvider');
    } catch (e) {
      print('LecturerProvider init error: $e');
      developer.log(
        'LecturerProvider init error: $e',
        name: 'LecturerProvider',
      );
    }

    _initQuickActions();
    _isLoading = false;
    notifyListeners();
    print('=== LECTURER PROVIDER INIT COMPLETED ===');
    developer.log('=== LECTURER PROVIDER INIT COMPLETED ===', name: 'LecturerProvider');
  }

  void _initQuickActions() {
    _quickActions = [
      QuickAction(
        label: 'Lịch giảng',
        type: 'lecturer_schedule',
        iconName: 'calendar_today_outlined',
      ),
      QuickAction(
        label: 'Danh sách lớp',
        type: 'lecturer_classes',
        iconName: 'groups_outlined',
      ),
      QuickAction(
        label: 'Nhập điểm',
        type: 'lecturer_grading',
        iconName: 'edit_document',
      ),
      QuickAction(
        label: 'Phúc khảo',
        type: 'lecturer_appeals',
        iconName: 'rate_review',
      ),
      QuickAction(
        label: 'Tài liệu',
        type: 'lecturer_documents',
        iconName: 'description_outlined',
      ),
      QuickAction(
        label: 'Lịch thi',
        type: 'lecturer_exam_schedule',
        iconName: 'event_note',
      ),
      QuickAction(
        label: 'Giấy XN',
        type: 'lecturer_confirmation_letter',
        iconName: 'verified',
      ),
      QuickAction(
        label: 'Vắng mặt',
        type: 'lecturer_absences',
        iconName: 'event_busy',
      ),
      QuickAction(
        label: 'Lớp học bù',
        type: 'lecturer_makeup_classes',
        iconName: 'event_available',
      ),
      QuickAction(
        label: 'Học phí',
        type: 'lecturer_tuition',
        iconName: 'payment',
      ),
    ];
  }



  Future<void> fetchLecturerProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching lecturer profile...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/profile');
      if (data != null) {
        developer.log('Lecturer profile fetched successfully', name: 'LecturerProvider');
        _lecturerProfile = LecturerProfile.fromJson(data);
      }
    } catch (e) {
      developer.log(
        'Error fetching lecturer profile: $e',
        name: 'LecturerProvider',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeachingSchedule() async {
    try {
      developer.log('Fetching teaching schedule...', name: 'LecturerProvider');
      // Fetch entire academic year (Aug 1 to Jul 31 next year)
      final now = DateTime.now();
      final startDate = DateTime(now.month >= 8 ? now.year : now.year - 1, 8, 1);
      final endDate = DateTime(now.month >= 8 ? now.year + 1 : now.year, 7, 31);
      
      developer.log('Schedule date range: $startDate to $endDate', name: 'LecturerProvider');
      
      final data = await _client.get(
        '/api/lecturer/schedule',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (data != null && data is List) {
        developer.log('Teaching schedule fetched successfully', name: 'LecturerProvider');
        _teachingSchedule = data
            .map((item) => TeachingScheduleItem.fromJson(item))
            .toList();
        
        developer.log('Parsed ${_teachingSchedule.length} schedule items', name: 'LecturerProvider');
        
        // Find next class from schedule
        _findNextClass();
        notifyListeners();
      }
    } catch (e) {
      developer.log(
        'Error fetching teaching schedule: $e',
        name: 'LecturerProvider',
      );
    }
  }

  void _findNextClass() {
    if (_teachingSchedule.isEmpty) {
      _nextClass = null;
      _nextClassDate = null;
      return;
    }

    final now = DateTime.now();
    TeachingScheduleItem? upcoming;
    DateTime? nearestDateTime;

    for (final item in _teachingSchedule) {
      // Skip if no date or day information
      if (item.ngayBatDau == null || item.ngayKetThuc == null || item.thu == null) continue;

      // Parse thu (day of week): "2" = Monday, "3" = Tuesday, etc.
      final thuInt = int.tryParse(item.thu!.trim());
      if (thuInt == null || thuInt < 2 || thuInt > 8) continue;
      
      // Convert Vietnamese day numbering to Dart weekday (1=Mon, 2=Tue, ..., 7=Sun)
      final targetWeekday = thuInt == 8 ? 7 : thuInt - 1;

      // Find next occurrence of this weekday starting from today
      var daysUntilTarget = targetWeekday - now.weekday;
      if (daysUntilTarget < 0) {
        daysUntilTarget += 7; // Next week
      }
      
      var nextOccurrence = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilTarget));
      
      // Make sure it's within the course date range
      if (nextOccurrence.isBefore(item.ngayBatDau!)) {
        nextOccurrence = item.ngayBatDau!;
        // Adjust to the correct weekday if needed
        while (nextOccurrence.weekday != targetWeekday) {
          nextOccurrence = nextOccurrence.add(const Duration(days: 1));
        }
      }
      
      // Skip if past the end date
      if (nextOccurrence.isAfter(item.ngayKetThuc!)) {
        continue;
      }

      // Check cachTuan (1 = every week, 2 = every 2 weeks, etc.)
      final cachTuan = item.cachTuan ?? 1;
      if (cachTuan > 1) {
        // Calculate weeks from start date
        final weeksDiff = nextOccurrence.difference(item.ngayBatDau!).inDays ~/ 7;
        if (weeksDiff % cachTuan != 0) {
          // Not on the correct week cycle, find next occurrence
          final weeksToAdd = cachTuan - (weeksDiff % cachTuan);
          nextOccurrence = nextOccurrence.add(Duration(days: weeksToAdd * 7));
          
          // Skip if past the end date
          if (nextOccurrence.isAfter(item.ngayKetThuc!)) {
            continue;
          }
        }
      }

      // Check if class has already ended today
      final endPeriod = int.tryParse(item.tietKetThuc ?? '0') ?? 0;
      final classEndTime = _getClassEndTime(nextOccurrence, endPeriod);
      
      // If today and class already ended, skip to next week
      if (nextOccurrence.year == now.year && 
          nextOccurrence.month == now.month && 
          nextOccurrence.day == now.day && 
          now.isAfter(classEndTime)) {
        nextOccurrence = nextOccurrence.add(Duration(days: 7 * cachTuan));
        
        // Skip if past the end date
        if (nextOccurrence.isAfter(item.ngayKetThuc!)) {
          continue;
        }
      }

      // This is a valid future class session
      if (nearestDateTime == null || nextOccurrence.isBefore(nearestDateTime)) {
        nearestDateTime = nextOccurrence;
        upcoming = item;
      }
    }

    _nextClass = upcoming;
    _nextClassDate = nearestDateTime;
    developer.log(
      'Next class found: ${_nextClass?.tenMon ?? 'None'} on ${nearestDateTime?.toString() ?? 'N/A'}',
      name: 'LecturerProvider',
    );
  }

  DateTime _getClassEndTime(DateTime date, int period) {
    const Map<int, int> periodEndHour = {
      1: 8, 2: 9, 3: 9, 4: 10, 5: 11,
      6: 13, 7: 14, 8: 15, 9: 16, 0: 17,
    };
    const Map<int, int> periodEndMinute = {
      1: 15, 2: 0, 3: 45, 4: 45, 5: 30,
      6: 45, 7: 30, 8: 30, 9: 15, 0: 0,
    };

    final hour = periodEndHour[period] ?? 17;
    final minute = periodEndMinute[period] ?? 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<void> _fetchNotifications() async {
    try {
      developer.log('Fetching notifications...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/notifications');
      
      if (data != null && data is List) {
        developer.log('Notifications fetched successfully', name: 'LecturerProvider');
        _notifications = data.map((item) {
          return NotificationItem(
            id: item['id']?.toString(),
            title: item['title']?.toString() ?? '{Tiêu đề}',
            body: item['body']?.toString() ?? '{Nội dung}',
            isUnread: item['isUnread'] as bool? ?? true,
            time: item['time'] as String? ?? '{giờ/phút} trước',
          );
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      developer.log(
        'Error fetching notifications: $e',
        name: 'LecturerProvider',
      );
    }
  }

  Future<void> fetchTeachingClasses({String? semester}) async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching teaching classes...', name: 'LecturerProvider');
      
      final Map<String, dynamic> queryParams = {};
      if (semester != null && semester.isNotEmpty) {
        queryParams['semester'] = semester;
      }

      _debugInfo = 'Calling classes API...';
      notifyListeners();

      final data = await _client.get('/api/lecturer/courses', queryParameters: queryParams);
      
      if (data != null && data is List) {
        developer.log('Teaching classes fetched successfully', name: 'LecturerProvider');
        _teachingClasses = data
            .map((item) => TeachingClass.fromJson(item))
            .toList();
        _debugInfo = 'Success: ${_teachingClasses.length} classes';
        developer.log('Found ${_teachingClasses.length} classes', name: 'LecturerProvider');
        notifyListeners();
      }
    } catch (e) {
      _debugInfo = 'Error: $e';
      developer.log(
        'Error fetching teaching classes: $e',
        name: 'LecturerProvider',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch classes for multiple semesters and merge results
  Future<void> fetchTeachingClassesForYear(String year) async {
    _isLoading = true;
    notifyListeners();

    try {
      final yearParts = year.split('-'); // "2024-2025" -> ["2024", "2025"]
      final allClasses = <TeachingClass>[];

      // Fetch all 3 semesters
      for (int semNum = 1; semNum <= 3; semNum++) {
        final semester = '${yearParts[0]}_${yearParts[1]}_$semNum';
        developer.log('Fetching semester: $semester', name: 'LecturerProvider');
        
        final data = await _client.get(
          '/api/lecturer/courses',
          queryParameters: {'semester': semester},
        );

        if (data != null && data is List) {
          final classes = data.map((item) => TeachingClass.fromJson(item)).toList();
          allClasses.addAll(classes);
          developer.log('Found ${classes.length} classes for $semester', name: 'LecturerProvider');
        }
      }

      _teachingClasses = allClasses;
      developer.log('Total classes fetched: ${_teachingClasses.length}', name: 'LecturerProvider');
    } catch (e) {
      developer.log('Error fetching classes for year: $e', name: 'LecturerProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSchedule({String? semester}) async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching teaching schedule...', name: 'LecturerProvider');
      
      // If no semester specified, use current semester (2025_2026_1)
      final semesterParam = semester ?? '2025_2026_1';
      
      final data = await _client.get(
        '/api/lecturer/schedule',
        queryParameters: {'semester': semesterParam},
      );

      if (data != null && data is List) {
        developer.log('Teaching schedule fetched successfully', name: 'LecturerProvider');
        _teachingSchedule = data
            .map((item) => TeachingScheduleItem.fromJson(item))
            .toList();
        developer.log('Found ${_teachingSchedule.length} schedule items', name: 'LecturerProvider');
        
        // Find next class from schedule
        _findNextClass();
      }
    } catch (e) {
      developer.log('Error fetching schedule: $e', name: 'LecturerProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch appeals
  Future<void> fetchAppeals({
    String? maMon,
    String? nhom,
    String? trangThai,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (maMon != null && maMon.isNotEmpty) queryParams['course_id'] = maMon;
      if (nhom != null && nhom.isNotEmpty) queryParams['nhom'] = nhom;
      if (trangThai != null && trangThai.isNotEmpty) queryParams['status'] = trangThai;

      developer.log('Fetching appeals...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/appeals', queryParameters: queryParams);

      if (data != null && data is List) {
        developer.log('Appeals fetched successfully', name: 'LecturerProvider');
        _appeals = data.map((item) => Appeal.fromJson(item)).toList();
        developer.log('Found ${_appeals.length} appeals', name: 'LecturerProvider');
      }
    } catch (e) {
      developer.log('Error fetching appeals: $e', name: 'LecturerProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle appeal (approve/reject)
  Future<void> handleAppeal(
    String appealId,
    String action, {
    String? ghiChu,
    double? diemMoi,
  }) async {
    try {
      developer.log('Handling appeal $appealId with action: $action', name: 'LecturerProvider');
      final body = {
        'status': action, // Backend expects 'status' not 'result'
        if (ghiChu != null) 'comment': ghiChu,
        // Note: Backend doesn't handle diemMoi in this endpoint
      };

      final res = await _client.put('/api/lecturer/appeals/$appealId', body: body);

      if (res != null) {
        developer.log('Appeal handled successfully', name: 'LecturerProvider');
        // Refresh appeals list
        await fetchAppeals();
      }
    } catch (e) {
      developer.log('Error handling appeal: $e', name: 'LecturerProvider');
    }
  }

  // Fetch documents
  Future<void> fetchDocuments({String? maMon, String? loaiTaiLieu}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (maMon != null && maMon.isNotEmpty) queryParams['course_id'] = maMon;
      if (loaiTaiLieu != null && loaiTaiLieu.isNotEmpty) queryParams['type'] = loaiTaiLieu;

      developer.log('Fetching documents...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/materials', queryParameters: queryParams);

      if (data != null && data is List) {
        developer.log('Documents fetched successfully', name: 'LecturerProvider');
        _documents = data.map((item) => Document.fromJson(item)).toList();
        developer.log('Found ${_documents.length} documents', name: 'LecturerProvider');
      }
    } catch (e) {
      developer.log('Error fetching documents: $e', name: 'LecturerProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload document
  Future<void> uploadDocument(Document document) async {
    try {
      developer.log('Uploading document: ${document.tieuDe}', name: 'LecturerProvider');
      final body = {
        'tieuDe': document.tieuDe,
        'moTa': document.moTa,
        'maMon': document.maMon,
        'loaiTaiLieu': document.loaiTaiLieu,
      };

      final res = await _client.post('/api/lecturer/materials', body: body);

      if (res != null) {
        developer.log('Document uploaded successfully', name: 'LecturerProvider');
        // Refresh documents list
        await fetchDocuments();
      }
    } catch (e) {
      developer.log('Error uploading document: $e', name: 'LecturerProvider');
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      developer.log('Deleting document: $documentId', name: 'LecturerProvider');
      
      await _client.delete('/api/lecturer/materials/$documentId');
      
      developer.log('Document deleted successfully', name: 'LecturerProvider');
      _documents.removeWhere((d) => d.id == documentId);
      notifyListeners();
    } catch (e) {
      developer.log('Error deleting document: $e', name: 'LecturerProvider');
    }
  }

  // Fetch exam schedules
  Future<void> fetchExamSchedules({String? loaiThi, String? vaiTro}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (loaiThi != null && loaiThi.isNotEmpty) queryParams['loaiThi'] = loaiThi;
      if (vaiTro != null && vaiTro.isNotEmpty) queryParams['vaiTro'] = vaiTro;

      developer.log('Fetching exam schedules...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/exams', queryParameters: queryParams);

      if (data != null && data is List) {
        developer.log('Exam schedules fetched successfully', name: 'LecturerProvider');
        _examSchedules = data
            .map((item) => ExamSchedule.fromJson(item))
            .toList();
        // Sort by exam date
        _examSchedules.sort((a, b) => a.ngayThi.compareTo(b.ngayThi));
        developer.log('Found ${_examSchedules.length} exam schedules', name: 'LecturerProvider');
      }
    } catch (e) {
      developer.log('Error fetching exam schedules: $e', name: 'LecturerProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _init();
  }

  // Update profile method
  Future<bool> updateProfile({
    String? email,
    String? soDienThoai,
    String? diaChiThuongTru,
  }) async {
    try {
      developer.log('Updating profile...', name: 'LecturerProvider');
      final body = {
        if (email != null) 'email': email,
        if (soDienThoai != null) 'phone': soDienThoai,
        if (diaChiThuongTru != null) 'address': diaChiThuongTru,
      };

      final res = await _client.put('/api/lecturer/profile', body: body);

      if (res != null) {
        developer.log('Profile updated successfully', name: 'LecturerProvider');
        // Refresh profile
        await fetchLecturerProfile();
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error updating profile: $e', name: 'LecturerProvider');
      return false;
    }
  }

  // GET /api/lecturer/courses/{classCode} - Lấy chi tiết lớp học
  Future<TeachingClass?> fetchCourseDetail(String classCode) async {
    try {
      developer.log('Fetching course detail for $classCode...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/courses/$classCode');

      if (data != null && data is Map<String, dynamic>) {
        developer.log('Course detail fetched successfully', name: 'LecturerProvider');
        return TeachingClass.fromJson(data);
      }
    } catch (e) {
      developer.log('Error fetching course detail: $e', name: 'LecturerProvider');
    }
    return null;
  }

  // GET /api/lecturer/grades - Tra cứu điểm học tập của lớp
  Future<List<Map<String, dynamic>>> fetchGrades({String? courseId, String? semester}) async {
    try {
      developer.log('Fetching grades...', name: 'LecturerProvider');
      var queryParams = <String, String>{};
      if (courseId != null) queryParams['courseId'] = courseId;
      if (semester != null) queryParams['semester'] = semester;
      
      final data = await _client.get('/api/lecturer/grades', queryParameters: queryParams);

      if (data != null && data is List) {
        developer.log('Grades fetched successfully', name: 'LecturerProvider');
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      developer.log('Error fetching grades: $e', name: 'LecturerProvider');
    }
    return [];
  }

  // GET /api/lecturer/grades/{mssv} - Xem chi tiết điểm của 1 sinh viên
  Future<Map<String, dynamic>?> fetchStudentGrade(String mssv) async {
    try {
      developer.log('Fetching grade for student $mssv...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/grades/$mssv');

      if (data != null && data is Map<String, dynamic>) {
        developer.log('Student grade fetched successfully', name: 'LecturerProvider');
        return data;
      }
    } catch (e) {
      developer.log('Error fetching student grade: $e', name: 'LecturerProvider');
    }
    return null;
  }

  // PUT /api/lecturer/grades/{mssv} - Nhập/chỉnh sửa điểm
  Future<bool> updateGrade({
    required String mssv,
    required String maLop,
    double? diemQuaTrinh,
    double? diemGiuaKy,
    double? diemCuoiKy,
  }) async {
    try {
      developer.log('Updating grade for student $mssv...', name: 'LecturerProvider');
      final body = {
        'maLop': maLop,
        if (diemQuaTrinh != null) 'diemQuaTrinh': diemQuaTrinh,
        if (diemGiuaKy != null) 'diemGiuaKy': diemGiuaKy,
        if (diemCuoiKy != null) 'diemCuoiKy': diemCuoiKy,
      };

      final res = await _client.put('/api/lecturer/grades/$mssv', body: body);

      if (res != null) {
        developer.log('Grade updated successfully', name: 'LecturerProvider');
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error updating grade: $e', name: 'LecturerProvider');
      return false;
    }
  }

  // GET /api/lecturer/exams/{maLop} - Chi tiết lịch thi của 1 lớp
  Future<Map<String, dynamic>?> fetchExamDetail(String maLop) async {
    try {
      developer.log('Fetching exam detail for class $maLop...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/exams/$maLop');

      if (data != null && data is Map<String, dynamic>) {
        developer.log('Exam detail fetched successfully', name: 'LecturerProvider');
        return data;
      }
    } catch (e) {
      developer.log('Error fetching exam detail: $e', name: 'LecturerProvider');
    }
    return null;
  }

  // GET /api/lecturer/exams/{maLop}/students - Danh sách sinh viên thi
  Future<List<Map<String, dynamic>>> fetchExamStudents(String maLop) async {
    try {
      developer.log('Fetching exam students for class $maLop...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/exams/$maLop/students');

      if (data != null && data is List) {
        developer.log('Exam students fetched successfully', name: 'LecturerProvider');
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      developer.log('Error fetching exam students: $e', name: 'LecturerProvider');
    }
    return [];
  }

  // GET /api/lecturer/tuition - Thông tin học phí
  Future<List<Map<String, dynamic>>> fetchTuition({String? studentId, String? semester}) async {
    try {
      developer.log('Fetching tuition info...', name: 'LecturerProvider');
      var queryParams = <String, String>{};
      if (studentId != null) queryParams['studentId'] = studentId;
      if (semester != null) queryParams['semester'] = semester;
      
      final data = await _client.get('/api/lecturer/tuition', queryParameters: queryParams);

      if (data != null && data is List) {
        developer.log('Tuition info fetched successfully', name: 'LecturerProvider');
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      developer.log('Error fetching tuition: $e', name: 'LecturerProvider');
    }
    return [];
  }

  // PUT /api/lecturer/notifications/{id}/read - Đánh dấu thông báo đã đọc
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      developer.log('Marking notification $notificationId as read...', name: 'LecturerProvider');
      
      final res = await _client.put('/api/lecturer/notifications/$notificationId/read');

      if (res != null) {
        developer.log('Notification marked as read', name: 'LecturerProvider');
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationItem(
            id: _notifications[index].id,
            title: _notifications[index].title,
            body: _notifications[index].body,
            time: _notifications[index].time,
            isUnread: false,
            category: _notifications[index].category,
            createdAt: _notifications[index].createdAt,
            data: _notifications[index].data,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error marking notification as read: $e', name: 'LecturerProvider');
      return false;
    }
  }

  // GET /api/lecturer/absences - Danh sách vắng mặt
  Future<List<Map<String, dynamic>>> fetchAbsences() async {
    try {
      developer.log('Fetching absences...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/absences');

      if (data != null && data is List) {
        developer.log('Absences fetched successfully', name: 'LecturerProvider');
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      developer.log('Error fetching absences: $e', name: 'LecturerProvider');
    }
    return [];
  }

  // GET /api/lecturer/makeup-classes - Danh sách lớp học bù
  Future<List<Map<String, dynamic>>> fetchMakeupClasses() async {
    try {
      developer.log('Fetching makeup classes...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/makeup-classes');

      if (data != null && data is List) {
        developer.log('Makeup classes fetched successfully', name: 'LecturerProvider');
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      developer.log('Error fetching makeup classes: $e', name: 'LecturerProvider');
    }
    return [];
  }

  // GET /api/lecturer/appeals/{appealId} - Xem chi tiết đơn phúc khảo
  Future<Map<String, dynamic>?> fetchAppealDetail(int appealId) async {
    try {
      developer.log('Fetching appeal detail $appealId...', name: 'LecturerProvider');
      
      final data = await _client.get('/api/lecturer/appeals/$appealId');

      if (data != null && data is Map<String, dynamic>) {
        developer.log('Appeal detail fetched successfully', name: 'LecturerProvider');
        return data;
      }
    } catch (e) {
      developer.log('Error fetching appeal detail: $e', name: 'LecturerProvider');
    }
    return null;
  }

  // PUT /api/lecturer/appeals/{appealId} - Phản hồi đơn phúc khảo
  Future<bool> respondToAppeal({
    required int appealId,
    required String status, // 'approved' or 'rejected'
    String? comment,
  }) async {
    try {
      developer.log('Responding to appeal $appealId with status: $status', name: 'LecturerProvider');
      final body = {
        'status': status,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      final res = await _client.put('/api/lecturer/appeals/$appealId', body: body);

      if (res != null) {
        developer.log('Appeal response submitted successfully', name: 'LecturerProvider');
        // Refresh appeals list
        await fetchAppeals();
        return true;
      }
    } catch (e) {
      developer.log('Error responding to appeal: $e', name: 'LecturerProvider');
    }
    return false;
  }

  // POST /api/lecturer/absence - Đăng ký báo nghỉ
  Future<bool> createAbsence({
    required String maLop,
    required DateTime ngayNghi,
    String? lyDo,
  }) async {
    try {
      developer.log('Creating absence for class $maLop on $ngayNghi...', name: 'LecturerProvider');
      final body = {
        'maLop': maLop,
        'ngayNghi': ngayNghi.toIso8601String(),
        if (lyDo != null && lyDo.isNotEmpty) 'lyDo': lyDo,
      };

      final res = await _client.post('/api/lecturer/absence', body: body);

      if (res != null) {
        developer.log('Absence created successfully', name: 'LecturerProvider');
        return true;
      }
    } catch (e) {
      developer.log('Error creating absence: $e', name: 'LecturerProvider');
    }
    return false;
  }

  // POST /api/lecturer/makeup-class - Đăng ký lịch học bù
  Future<bool> createMakeupClass({
    required String maLop,
    required DateTime ngayHocBu,
    required int tietBatDau,
    required int tietKetThuc,
    String? phongHoc,
    String? lyDo,
  }) async {
    try {
      developer.log('Creating makeup class for $maLop on $ngayHocBu...', name: 'LecturerProvider');
      final body = {
        'maLop': maLop,
        'ngayHocBu': ngayHocBu.toIso8601String(),
        'tietBatDau': tietBatDau,
        'tietKetThuc': tietKetThuc,
        if (phongHoc != null && phongHoc.isNotEmpty) 'phongHoc': phongHoc,
        if (lyDo != null && lyDo.isNotEmpty) 'lyDo': lyDo,
      };

      final res = await _client.post('/api/lecturer/makeup-class', body: body);

      if (res != null) {
        developer.log('Makeup class created successfully', name: 'LecturerProvider');
        return true;
      }
    } catch (e) {
      developer.log('Error creating makeup class: $e', name: 'LecturerProvider');
    }
    return false;
  }

  // POST /api/lecturer/confirmation-letter - Tạo giấy xác nhận cho sinh viên
  Future<Map<String, dynamic>?> createConfirmationLetter({
    required int mssv,
    required String purpose,
  }) async {
    try {
      developer.log('Creating confirmation letter for student $mssv...', name: 'LecturerProvider');
      final body = {
        'mssv': mssv,
        'purpose': purpose,
      };

      final res = await _client.post('/api/lecturer/confirmation-letter', body: body);

      if (res != null) {
        developer.log('Confirmation letter created successfully', name: 'LecturerProvider');
        if (res is Map<String, dynamic>) return res;
      }
    } catch (e) {
      developer.log('Error creating confirmation letter: $e', name: 'LecturerProvider');
    }
    return null;
  }

  /// Prefetch commonly used lecturer data. Used by LoadingScreen.
  Future<void> prefetch({bool forceRefresh = false}) async {
    try {
      developer.log('LecturerProvider: starting prefetch', name: 'LecturerProvider');
      await Future.wait([
        fetchLecturerProfile(),
        fetchTeachingClasses(),
        fetchTeachingSchedule(),
        _fetchNotifications(),
      ]);
      developer.log('LecturerProvider: prefetch completed', name: 'LecturerProvider');
    } catch (e) {
      developer.log('LecturerProvider: prefetch error: $e', name: 'LecturerProvider');
      rethrow;
    }
  }
}
