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

class LecturerProvider extends ChangeNotifier {
  final AuthService auth;

  LecturerProvider({required this.auth}) {
    _init();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  LecturerCard? _lecturerCard;
  LecturerCard? get lecturerCard => _lecturerCard;

  LecturerProfile? _lecturerProfile;
  LecturerProfile? get lecturerProfile => _lecturerProfile;

  List<TeachingScheduleItem> _teachingSchedule = [];
  List<TeachingScheduleItem> get teachingSchedule => _teachingSchedule;
  List<TeachingScheduleItem> get schedule =>
      _teachingSchedule; // Alias for compatibility

  TeachingScheduleItem? _nextClass;
  TeachingScheduleItem? get nextClass => _nextClass;

  List<TeachingClass> _teachingClasses = [];
  List<TeachingClass> get teachingClasses => _teachingClasses;

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
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _fetchLecturerCard(),
        _fetchNextClass(),
        _fetchNotifications(),
      ]);
    } catch (e) {
      developer.log(
        'LecturerProvider init error: $e',
        name: 'LecturerProvider',
      );
    }

    _initQuickActions();
    _isLoading = false;
    notifyListeners();
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
    ];
  }

  Future<void> _fetchLecturerCard() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/card');
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _lecturerCard = LecturerCard.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      developer.log(
        'Error fetching lecturer card: $e',
        name: 'LecturerProvider',
      );
    }
  }

  Future<void> fetchLecturerProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await auth.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final uri = auth.buildUri('/api/Lecturer/profile');
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
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

  Future<void> _fetchNextClass() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/next-class');
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _nextClass = TeachingScheduleItem.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error fetching next class: $e', name: 'LecturerProvider');
    }
  }

  Future<void> fetchTeachingSchedule() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/schedule');
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _teachingSchedule = data
            .map((item) => TeachingScheduleItem.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      developer.log(
        'Error fetching teaching schedule: $e',
        name: 'LecturerProvider',
      );
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/notifications');
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _notifications = data.map((item) {
          return NotificationItem(
            id: item['id']?.toString(),
            title: item['title'] as String,
            body: item['body'] as String?,
            isUnread: item['isUnread'] as bool? ?? true,
            time: item['time'] as String? ?? '1 giờ trước',
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

  Future<void> fetchTeachingClasses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/classes');
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _teachingClasses = data
            .map((item) => TeachingClass.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      developer.log(
        'Error fetching teaching classes: $e',
        name: 'LecturerProvider',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSchedule() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await auth.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final uri = auth.buildUri('/api/Lecturer/schedule');
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _teachingSchedule = data
            .map((item) => TeachingScheduleItem.fromJson(item))
            .toList();
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
      final token = await auth.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      var path = '/api/Lecturer/appeals';
      final queryParams = <String>[];
      if (maMon != null && maMon.isNotEmpty) {
        queryParams.add('course_id=$maMon');
      }
      if (nhom != null && nhom.isNotEmpty) queryParams.add('nhom=$nhom');
      if (trangThai != null && trangThai.isNotEmpty) {
        queryParams.add('status=$trangThai');
      }
      if (queryParams.isNotEmpty) {
        path += '?${queryParams.join('&')}';
      }

      final uri = auth.buildUri(path);
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _appeals = data.map((item) => Appeal.fromJson(item)).toList();
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
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/appeals/$appealId');
      final body = {
        'result': action,
        if (ghiChu != null) 'comment': ghiChu,
        if (diemMoi != null) 'diemMoi': diemMoi,
      };

      final res = await http
          .put(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
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
      final token = await auth.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      var path = '/api/Lecturer/materials';
      final queryParams = <String>[];
      if (maMon != null && maMon.isNotEmpty) {
        queryParams.add('course_id=$maMon');
      }
      if (loaiTaiLieu != null && loaiTaiLieu.isNotEmpty) {
        queryParams.add('type=$loaiTaiLieu');
      }
      if (queryParams.isNotEmpty) {
        path += '?${queryParams.join('&')}';
      }

      final uri = auth.buildUri(path);
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _documents = data.map((item) => Document.fromJson(item)).toList();
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
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/materials');
      final body = {
        'tieuDe': document.tieuDe,
        'moTa': document.moTa,
        'maMon': document.maMon,
        'loaiTaiLieu': document.loaiTaiLieu,
      };

      final res = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
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
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/materials/$documentId');
      final res = await http
          .delete(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 204) {
        _documents.removeWhere((d) => d.id == documentId);
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error deleting document: $e', name: 'LecturerProvider');
    }
  }

  // Fetch exam schedules
  Future<void> fetchExamSchedules({String? loaiThi, String? vaiTro}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await auth.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      var path = '/api/Lecturer/exams';
      final queryParams = <String>[];
      if (loaiThi != null && loaiThi.isNotEmpty) {
        queryParams.add('loaiThi=$loaiThi');
      }
      if (vaiTro != null && vaiTro.isNotEmpty) {
        queryParams.add('vaiTro=$vaiTro');
      }
      if (queryParams.isNotEmpty) {
        path += '?${queryParams.join('&')}';
      }

      final uri = auth.buildUri(path);
      final res = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _examSchedules = data
            .map((item) => ExamSchedule.fromJson(item))
            .toList();
        // Sort by exam date
        _examSchedules.sort((a, b) => a.ngayThi.compareTo(b.ngayThi));
      }
    } catch (e) {
      developer.log(
        'Error fetching exam schedules: $e',
        name: 'LecturerProvider',
      );
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
      final token = await auth.getToken();
      if (token == null) return false;

      final uri = auth.buildUri('/api/Lecturer/profile');
      final body = {
        if (email != null) 'email': email,
        if (soDienThoai != null) 'soDienThoai': soDienThoai,
        if (diaChiThuongTru != null) 'diaChiThuongTru': diaChiThuongTru,
      };

      final res = await http
          .patch(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
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
}
