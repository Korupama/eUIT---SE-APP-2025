import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/schedule_item.dart';
import '../models/notification_item.dart';
import '../models/quick_action.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/student_card_dto.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;

  // Listen for token changes and refetch data when a new token is saved.
  late final VoidCallback _tokenListener;

  HomeProvider({required AuthService auth}) {
    _loadMock();
    _auth = auth;

    // When token changes, refresh data (or clear on null).
    _tokenListener = () {
      final tok = AuthService.tokenNotifier.value;
      if (tok == null || tok.isEmpty) {
        developer.log('HomeProvider: token is null -> clearing data', name: 'HomeProvider');
        clear();
      } else {
        developer.log('HomeProvider: token available -> refreshing data', name: 'HomeProvider');
        // Fire-and-forget background refresh
        fetchQuickGpa();
        fetchStudentCard();
        fetchNextClass();
      }
    };

    // Attach listener (also triggers initial reaction if token already present)
    AuthService.tokenNotifier.addListener(_tokenListener);

    // Try to fetch quick GPA in background when provider is created
    Future.microtask(() => fetchQuickGpa());
    // Fetch student card in background
    Future.microtask(() => fetchStudentCard());
    // Fetch next class in background
    Future.microtask(() => fetchNextClass());
  }

  late ScheduleItem _nextSchedule;
  List<NotificationItem> _notifications = [];
  List<QuickAction> _quickActions = [];

  double? _gpa;
  int? _soTinChiTichLuy;
  StudentCardDto? _studentCard;

  StudentCardDto? get studentCard => _studentCard;

  late AuthService _auth;

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

  /// Fetch next class from backend: GET /nextclass
  /// Maps server response to local ScheduleItem used by UI.
  Future<void> fetchNextClass() async {
    try {
      final token = await _auth.getToken();
      if (token == null || token.isEmpty) return;

      final uri = _auth.buildUri('/nextclass');
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;

        final maLop = body['maLop']?.toString() ?? '';
        final tenMonHoc = body['tenMonHoc']?.toString() ?? '';
        final tenGiangVien = body['tenGiangVien']?.toString() ?? '';
        final phongHoc = body['phongHoc']?.toString() ?? '';

        int? tietBatDau;
        int? tietKetThuc;
        if (body['tietBatDau'] != null) {
          tietBatDau = (body['tietBatDau'] is int) ? body['tietBatDau'] as int : int.tryParse(body['tietBatDau'].toString());
        }
        if (body['tietKetThuc'] != null) {
          tietKetThuc = (body['tietKetThuc'] is int) ? body['tietKetThuc'] as int : int.tryParse(body['tietKetThuc'].toString());
        }

        String countdownStr = '';
        if (body['countdownMinutes'] != null) {
          final cm = (body['countdownMinutes'] is int) ? body['countdownMinutes'] as int : int.tryParse(body['countdownMinutes'].toString()) ?? 0;
          countdownStr = _formatMinutesToHoursMinutes(cm);
        }

        String timeRange = '';
        if (tietBatDau != null && tietKetThuc != null) {
          // Map periods to actual time-of-day ranges using the school's schedule
          timeRange = _periodsToTimeRange(tietBatDau, tietKetThuc);
        } else if (body['ngayHoc'] != null) {
          try {
            final dt = DateTime.parse(body['ngayHoc'].toString());
            timeRange = '${dt.day}/${dt.month}/${dt.year}';
          } catch (_) {
            timeRange = '';
          }
        }

        _nextSchedule = ScheduleItem(
          timeRange: timeRange.isNotEmpty ? timeRange : '—',
          courseCode: maLop,
          courseName: tenMonHoc,
          room: phongHoc,
          lecturer: tenGiangVien,
          countdown: countdownStr.isNotEmpty ? countdownStr : (body['countdownMinutes'] != null ? '${body['countdownMinutes']} min' : ''),
        );

        notifyListeners();
      } else if (res.statusCode == 401) {
        await _auth.deleteToken();
      }
    } catch (e) {
      // Keep existing mock data on error
    }
  }

  String _formatMinutesToHoursMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  // Convert start/end period numbers to human-readable time range using school schedule
  String _periodsToTimeRange(int startPeriod, int endPeriod) {
    const Map<int, String> startMap = {
      1: '7:30',
      2: '8:15',
      3: '9:00',
      4: '10:00',
      5: '10:45',
      6: '13:00',
      7: '13:45',
      8: '14:30',
      9: '15:30',
      0: '16:15',
    };
    const Map<int, String> endMap = {
      1: '8:15',
      2: '9:00',
      3: '9:45',
      4: '10:45',
      5: '11:30',
      6: '13:45',
      7: '14:30',
      8: '15:15',
      9: '16:15',
      0: '17:00',
    };

    final start = startMap[startPeriod] ?? '${startPeriod}';
    final end = endMap[endPeriod] ?? '${endPeriod}';
    return '$start - $end';
  }

  /// Refresh all backend-backed fields. Useful to call immediately after login.
  Future<void> refreshAll() async {
    await Future.wait([
      fetchQuickGpa(),
      fetchStudentCard(),
      fetchNextClass(),
    ]);
  }

  /// Clear sensitive data when logged out or token removed.
  void clear() {
    _gpa = null;
    _soTinChiTichLuy = null;
    _studentCard = null;
    // leave mock schedule/notifications untouched or override as needed
    notifyListeners();
  }

  @override
  void dispose() {
    try {
      AuthService.tokenNotifier.removeListener(_tokenListener);
    } catch (_) {}
    super.dispose();
  }
}
