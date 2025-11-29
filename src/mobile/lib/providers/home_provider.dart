import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/schedule_item.dart';
import '../models/notification_item.dart';
import '../models/quick_action.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/student_card_dto.dart';

class HomeProvider extends ChangeNotifier {
  final bool _isLoading = false;
  final NotificationService _notificationService = NotificationService();
  final List<StreamSubscription> _subscriptions = [];

  HomeProvider() {
    _loadMock();
    // Try to fetch quick GPA in background when provider is created
    Future.microtask(() => fetchQuickGpa());
    // Fetch student card in background
    Future.microtask(() => fetchStudentCard());
    // Fetch next class in background
    Future.microtask(() => fetchNextClass());
    // Setup realtime notification listeners
    _setupNotificationListeners();
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

  /// Setup realtime notification listeners from SignalR
  void _setupNotificationListeners() {
    // Kết quả học tập
    _subscriptions.add(
      _notificationService.onKetQuaHocTap.listen((notification) {
        _addNotification(NotificationItem(
          title: 'Cập nhật điểm: ${notification.tenMonHoc}',
          body: 'QT: ${notification.diemQuaTrinh ?? "-"} | '
              'GK: ${notification.diemGiuaKy ?? "-"} | '
              'CK: ${notification.diemCuoiKy ?? "-"}',
          time: 'Vừa xong',
          isUnread: true,
          category: NotificationCategory.ketQuaHocTap,
        ));
      }),
    );

    // Báo bù
    _subscriptions.add(
      _notificationService.onBaoBu.listen((notification) {
        // Tạo danh sách tiết từ tiết bắt đầu đến tiết kết thúc
        final tietBatDau = int.tryParse(notification.tietBatDau) ?? 1;
        final tietKetThuc = int.tryParse(notification.tietKetThuc) ?? tietBatDau;
        final danhSachTiet = List.generate(
          tietKetThuc - tietBatDau + 1,
          (i) => (tietBatDau + i).toString(),
        ).join(', ');

        _addNotification(NotificationItem(
          title: 'Lịch học bù: ${notification.tenMonHoc}',
          body: 'Ngày: ${_formatDate(notification.ngayBu)}\n'
              'Tiết: $danhSachTiet\n'
              'Phòng: ${notification.phongHoc}',
          time: 'Vừa xong',
          isUnread: true,
          category: NotificationCategory.baoBu,
        ));
      }),
    );

    // Báo nghỉ
    _subscriptions.add(
      _notificationService.onBaoNghi.listen((notification) {
        _addNotification(NotificationItem(
          title: 'Nghỉ học: ${notification.tenMonHoc}',
          body: 'Ngày: ${_formatDate(notification.ngayNghi)}\n'
              'Lý do: ${notification.lyDo}',
          time: 'Vừa xong',
          isUnread: true,
          category: NotificationCategory.baoNghi,
        ));
      }),
    );

    // Điểm rèn luyện
    _subscriptions.add(
      _notificationService.onDiemRenLuyen.listen((notification) {
        _addNotification(NotificationItem(
          title: 'Điểm rèn luyện HK${notification.hocKy}',
          body: 'Điểm: ${notification.diemRenLuyen} - ${notification.xepLoai}',
          time: 'Vừa xong',
          isUnread: true,
          category: NotificationCategory.diemRenLuyen,
        ));
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Thêm notification mới vào đầu danh sách
  void _addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Đánh dấu notification đã đọc
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isUnread: false);
      notifyListeners();
    }
  }

  /// Đánh dấu tất cả đã đọc
  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isUnread: false)).toList();
    notifyListeners();
  }

  /// Số lượng notification chưa đọc
  int get unreadNotificationCount => _notifications.where((n) => n.isUnread).length;

  /// Kết nối SignalR với MSSV
  Future<void> connectNotifications(String mssv) async {
    await _notificationService.connect(mssv);
  }

  /// Ngắt kết nối SignalR
  Future<void> disconnectNotifications() async {
    await _notificationService.disconnect();
  }

  /// Trạng thái kết nối SignalR
  bool get isNotificationConnected => _notificationService.isConnected;

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _notificationService.disconnect();
    super.dispose();
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
        
        // Kết nối SignalR sau khi có MSSV
        if (_studentCard?.mssv != null) {
          connectNotifications(_studentCard!.mssv.toString());
        }
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

    final start = startMap[startPeriod] ?? '$startPeriod';
    final end = endMap[endPeriod] ?? '$endPeriod';
    return '$start - $end';
  }
}
