import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/schedule_item.dart';
import '../models/notification_item.dart';
import '../models/quick_action.dart';
import '../services/auth_service.dart';
import '../models/student_card_dto.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;

  HomeProvider() {
    _loadMock();
    // Try to fetch quick GPA in background when provider is created
    Future.microtask(() => fetchQuickGpa());
    // Fetch student card in background
    Future.microtask(() => fetchStudentCard());
  }

  late ScheduleItem _nextSchedule;
  List<NotificationItem> _notifications = [];
  List<QuickAction> _quickActions = [];

  double? _gpa;
  int? _soTinChiTichLuy;
  StudentCardDto? _studentCard;

  StudentCardDto? get studentCard => _studentCard;

  final AuthService _auth = AuthService();

  bool get isLoading => _isLoading;
  ScheduleItem get nextSchedule => _nextSchedule;
  List<NotificationItem> get notifications => _notifications;
  List<QuickAction> get quickActions => _quickActions;

  double? get gpa => _gpa;
  int? get soTinChiTichLuy => _soTinChiTichLuy;

  void _loadMock() {
    _nextSchedule = ScheduleItem(
      timeRange: '10:00 AM - 11:30 AM',
      courseCode: 'IE307.Q12',
      courseName: 'Công nghệ lập trình...',
      room: 'B1.22',
      lecturer: 'ThS.',
      countdown: '2h 15m',
    );
    _notifications = [
      NotificationItem(
        title: 'New Quantum Computing Lab Opens on Campus',
        body: 'Thông báo quan trọng từ nhà trường',
        time: '2 giờ trước',
        isUnread: true,
      ),
      NotificationItem(
        title: 'Thông báo lịch thi cuối kỳ',
        body: 'Lịch thi đã được cập nhật',
        time: '5 giờ trước',
        isUnread: true,
      ),
      NotificationItem(
        title: 'Kết quả học tập đã được cập nhật',
        body: 'Xem điểm học kỳ mới nhất',
        time: '1 ngày trước',
        isUnread: false,
      ),
    ];
    _quickActions = [
      QuickAction(label: 'Kết quả học tập', type: 'results', iconName: 'school_outlined'),
      QuickAction(label: 'Thời khóa biểu', type: 'schedule', iconName: 'calendar_today_outlined'),
      QuickAction(label: 'Học phí', type: 'tuition', iconName: 'monetization_on_outlined'),
      QuickAction(label: 'Gửi xe', type: 'parking', textIcon: 'P'),
      QuickAction(label: 'Phúc khảo', type: 'regrade', iconName: 'edit_document'),
      QuickAction(label: 'Đăng ký GXN', type: 'gxn', iconName: 'check_box_outlined'),
      QuickAction(label: 'Giấy giới thiệu', type: 'reference', iconName: 'description_outlined'),
      QuickAction(label: 'Chứng chỉ', type: 'certificate', iconName: 'workspace_premium_outlined'),
    ];
    // notifyListeners(); // not necessary here because ctor will cause initial build
  }

  /// Fetch quick GPA from backend: GET /quickgpa
  /// Requires JWT token stored by AuthService
  Future<void> fetchQuickGpa() async {
    try {
      final token = await _auth.getToken();
      if (token == null || token.isEmpty) {
        // No token available; cannot fetch
        return;
      }

      final uri = _auth.buildUri('/quickgpa');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
        // Parse fields safely
        final gpaVal = body['gpa'];
        if (gpaVal != null) {
          if (gpaVal is num) {
            _gpa = gpaVal.toDouble();
          } else {
            _gpa = double.tryParse(gpaVal.toString());
          }
        } else {
          _gpa = null;
        }

        final creditVal = body['soTinChiTichLuy'];
        if (creditVal != null) {
          if (creditVal is int) {
            _soTinChiTichLuy = creditVal;
          } else {
            _soTinChiTichLuy = int.tryParse(creditVal.toString());
          }
        } else {
          _soTinChiTichLuy = null;
        }

        notifyListeners();
      } else if (res.statusCode == 401) {
        // Unauthorized - token likely expired. Clear it so UX can re-authenticate.
        await _auth.deleteToken();
      }
    } catch (e) {
      // Silently ignore network/parse errors for now; UI will continue using mock or empty state.
    }
  }

  /// Fetch student card from backend: GET /card
  Future<void> fetchStudentCard() async {
    try {
      final token = await _auth.getToken();
      if (token == null || token.isEmpty) return;

      final uri = _auth.buildUri('/card');
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
        _studentCard = StudentCardDto.fromJson(body);
        notifyListeners();
      } else if (res.statusCode == 401) {
        await _auth.deleteToken();
      }
    } catch (e) {
      // ignore network/parse errors for now
    }
  }
}
