import 'dart:async';
import 'package:flutter/material.dart';
import '../models/schedule_item.dart';
import '../models/notification_item.dart';
import '../models/quick_action.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../services/notification_service.dart';
import '../models/student_card_dto.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  final NotificationService _notificationService = NotificationService();
  final List<StreamSubscription> _subscriptions = [];

  // Listen for token changes and refetch data when a new token is saved.
  late final VoidCallback _tokenListener;

  HomeProvider({required AuthService auth}) {
    _auth = auth;
    _client = ApiClient(auth);

    // When token changes, refresh data (or clear on null).
    _tokenListener = () {
      final tok = AuthService.tokenNotifier.value;
      if (tok == null || tok.isEmpty) {
        developer.log(
          'HomeProvider: token is null -> clearing data',
          name: 'HomeProvider',
        );
        clear();
      } else {
        developer.log(
          'HomeProvider: token available -> refreshing data',
          name: 'HomeProvider',
        );
        // Fire-and-forget background refresh
        fetchQuickGpa();
        fetchStudentCard();
        fetchNextClass();
      }
    };

    // Attach listener (also triggers initial reaction if token already present)
    AuthService.tokenNotifier.addListener(_tokenListener);
    // Trigger initial check immediately so if a token already exists we start fetching now
    _tokenListener();

    // Setup realtime notification listeners
    _setupNotificationListeners();
  }

  // _nextSchedule is initialized below with a default placeholder
  ScheduleItem _nextSchedule = ScheduleItem(
    timeRange: '',
    courseCode: '',
    courseName: '',
    room: '',
    lecturer: '',
    countdown: '',
  );
  List<NotificationItem> _notifications = [];
  List<QuickAction> _quickActions = [
    QuickAction(
      label: 'quick_action_results',
      type: 'results',
      iconName: 'school_outlined',
    ),
    QuickAction(
      label: 'quick_action_tuition',
      type: 'tuition',
      iconName: 'monetization_on_outlined',
    ),
    QuickAction(
      label: 'quick_action_schedule',
      type: 'schedule',
      iconName: 'calendar_today_outlined',
    ),
    QuickAction(
      label: 'quick_action_parking',
      type: 'parking',
      iconName: 'directions_car_outlined',
    ),
    QuickAction(
      label: 'quick_action_regrade',
      type: 'regrade',
      iconName: 'edit_document',
    ),
    QuickAction(
      label: 'quick_action_gxn',
      type: 'gxn',
      iconName: 'check_box_outlined',
    ),
    QuickAction(
      label: 'quick_action_reference',
      type: 'reference',
      iconName: 'description_outlined',
    ),
    QuickAction(
      label: 'quick_action_certificate',
      type: 'certificate',
      iconName: 'workspace_premium_outlined',
    ),
  ];

  double? _gpa;
  int? _soTinChiTichLuy;
  StudentCardDto? _studentCard;

  StudentCardDto? get studentCard => _studentCard;

  late AuthService _auth;
  late ApiClient _client;

  bool get isLoading => _isLoading;
  ScheduleItem get nextSchedule => _nextSchedule;
  List<NotificationItem> get notifications => _notifications;
  List<QuickAction> get quickActions => _quickActions;

  double? get gpa => _gpa;
  int? get soTinChiTichLuy => _soTinChiTichLuy;

  /// Get all available quick actions (for customization modal)
  List<QuickAction> get allAvailableQuickActions => [
    QuickAction(
      label: 'quick_action_results',
      type: 'results',
      iconName: 'school_outlined',
    ),
    QuickAction(
      label: 'quick_action_tuition',
      type: 'tuition',
      iconName: 'monetization_on_outlined',
    ),
    QuickAction(
      label: 'quick_action_schedule',
      type: 'schedule',
      iconName: 'calendar_today_outlined',
    ),
    QuickAction(
      label: 'quick_action_parking',
      type: 'parking',
      iconName: 'directions_car_outlined',
    ),
    QuickAction(
      label: 'quick_action_regrade',
      type: 'regrade',
      iconName: 'edit_document',
    ),
    QuickAction(
      label: 'quick_action_gxn',
      type: 'gxn',
      iconName: 'check_box_outlined',
    ),
    QuickAction(
      label: 'quick_action_reference',
      type: 'reference',
      iconName: 'description_outlined',
    ),
    QuickAction(
      label: 'quick_action_certificate',
      type: 'certificate',
      iconName: 'workspace_premium_outlined',
    ),
  ];

  // NOTE: _loadMock() intentionally removed; providers must be prefetched via LoadingScreen.

  /// Setup realtime notification listeners from SignalR
  void _setupNotificationListeners() {
    // Kết quả học tập
    _subscriptions.add(
      _notificationService.onKetQuaHocTap.listen((notification) {
        _addNotification(
          NotificationItem(
            title: 'Cập nhật điểm: ${notification.tenMonHoc}',
            body:
                'QT: ${notification.diemQuaTrinh ?? "-"} | '
                'GK: ${notification.diemGiuaKy ?? "-"} | '
                'CK: ${notification.diemCuoiKy ?? "-"}',
            time: 'Vừa xong',
            isUnread: true,
            category: NotificationCategory.ketQuaHocTap,
          ),
        );
      }),
    );

    // Báo bù
    _subscriptions.add(
      _notificationService.onBaoBu.listen((notification) {
        // Tạo danh sách tiết từ tiết bắt đầu đến tiết kết thúc
        final tietBatDau = int.tryParse(notification.tietBatDau) ?? 1;
        final tietKetThuc =
            int.tryParse(notification.tietKetThuc) ?? tietBatDau;
        final danhSachTiet = List.generate(
          tietKetThuc - tietBatDau + 1,
          (i) => (tietBatDau + i).toString(),
        ).join(', ');

        _addNotification(
          NotificationItem(
            title: 'Lịch học bù: ${notification.tenMonHoc}',
            body:
                'Ngày: ${_formatDate(notification.ngayBu)}\n'
                'Tiết: $danhSachTiet\n'
                'Phòng: ${notification.phongHoc}',
            time: 'Vừa xong',
            isUnread: true,
            category: NotificationCategory.baoBu,
          ),
        );
      }),
    );

    // Báo nghỉ
    _subscriptions.add(
      _notificationService.onBaoNghi.listen((notification) {
        _addNotification(
          NotificationItem(
            title: 'Nghỉ học: ${notification.tenMonHoc}',
            body:
                'Ngày: ${_formatDate(notification.ngayNghi)}\n'
                'Lý do: ${notification.lyDo}',
            time: 'Vừa xong',
            isUnread: true,
            category: NotificationCategory.baoNghi,
          ),
        );
      }),
    );

    // Điểm rèn luyện
    _subscriptions.add(
      _notificationService.onDiemRenLuyen.listen((notification) {
        _addNotification(
          NotificationItem(
            title: 'Điểm rèn luyện HK${notification.hocKy}',
            body:
                'Điểm: ${notification.diemRenLuyen} - ${notification.xepLoai}',
            time: 'Vừa xong',
            isUnread: true,
            category: NotificationCategory.diemRenLuyen,
          ),
        );
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
    _notifications = _notifications
        .map((n) => n.copyWith(isUnread: false))
        .toList();
    notifyListeners();
  }

  /// Số lượng notification chưa đọc
  int get unreadNotificationCount =>
      _notifications.where((n) => n.isUnread).length;

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
    try {
      AuthService.tokenNotifier.removeListener(_tokenListener);
    } catch (_) {}
    _notificationService.disconnect();
    super.dispose();
  }

  /// Fetch quick GPA from backend: GET /quickgpa
  Future<void> fetchQuickGpa() async {
    try {
      final body = await _client.get('/quickgpa');
      if (body == null) return;

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
    } catch (e) {
      // Silently ignore network/parse errors
    }
  }

  /// Fetch student card from backend: GET /card
  Future<void> fetchStudentCard() async {
    try {
      final body = await _client.get('/card');
      if (body == null) return;

      // ApiClient handles jsonDecode, so body is Map<String, dynamic>
      _studentCard = StudentCardDto.fromJson(body);
      notifyListeners();

      // Kết nối SignalR sau khi có MSSV
      if (_studentCard?.mssv != null) {
        connectNotifications(_studentCard!.mssv.toString());
      }
    } catch (e) {
      // ignore network/parse errors
    }
  }

  /// Fetch next class from backend: GET /nextclass
  Future<void> fetchNextClass() async {
    try {
      final body = await _client.get('/nextclass');
      if (body == null) return;

      final maLop = body['maLop']?.toString() ?? '';
      final tenMonHoc = body['tenMonHoc']?.toString() ?? '';
      final tenGiangVien = body['tenGiangVien']?.toString() ?? '';
      final phongHoc = body['phongHoc']?.toString() ?? '';

      int? tietBatDau;
      int? tietKetThuc;
      if (body['tietBatDau'] != null) {
        tietBatDau = (body['tietBatDau'] is int)
            ? body['tietBatDau'] as int
            : int.tryParse(body['tietBatDau'].toString());
      }
      if (body['tietKetThuc'] != null) {
        tietKetThuc = (body['tietKetThuc'] is int)
            ? body['tietKetThuc'] as int
            : int.tryParse(body['tietKetThuc'].toString());
      }

      String countdownStr = '';
      if (body['countdownMinutes'] != null) {
        final cm = (body['countdownMinutes'] is int)
            ? body['countdownMinutes'] as int
            : int.tryParse(body['countdownMinutes'].toString()) ?? 0;
        countdownStr = _formatMinutesToHoursMinutes(cm);
      }

      String timeRange = '';
      if (tietBatDau != null && body['ngayHoc'] != null) {
        try {
          final dt = DateTime.parse(body['ngayHoc'].toString());
          final dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
          final dayName = dayNames[dt.weekday % 7]; // weekday: 1=Monday, 7=Sunday

          final startTime = _getPeriodStartTime(tietBatDau);
          final endTime = _getPeriodEndTime(tietKetThuc ?? tietBatDau);
          timeRange = '$dayName $startTime - $endTime';
        } catch (_) {
          timeRange = _periodsToTimeRange(tietBatDau, tietKetThuc ?? tietBatDau);
        }
      } else if (tietBatDau != null && tietKetThuc != null) {
        // Fallback to old format if no date available
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
        countdown: countdownStr.isNotEmpty
            ? countdownStr
            : (body['countdownMinutes'] != null
                  ? '${body['countdownMinutes']} min'
                  : ''),
      );

      notifyListeners();
    } catch (e) {
      // Keep existing mock data on error
    }
  }

  String _formatMinutesToHoursMinutes(int minutes) {
    if (minutes <= 0) return '0s';

    final days = minutes ~/ (24 * 60);
    final hours = (minutes % (24 * 60)) ~/ 60;
    final mins = minutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h ${mins}m 0s';
    } else {
      return '${mins}m 0s';
    }
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

  /// Refresh all backend-backed fields. Useful to call immediately after login.
  Future<void> refreshAll() async {
    await Future.wait([fetchQuickGpa(), fetchStudentCard(), fetchNextClass()]);
  }

  /// Prefetch commonly used home data. Used by LoadingScreen on app start/login.
  Future<void> prefetch({bool forceRefresh = false}) async {
    try {
      developer.log('HomeProvider: starting prefetch', name: 'HomeProvider');
      _isLoading = true;
      notifyListeners();
      await refreshAll();
      developer.log('HomeProvider: prefetch completed', name: 'HomeProvider');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      developer.log('HomeProvider: prefetch error: $e', name: 'HomeProvider');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Save quick actions preferences (customize which actions are shown and their order)
  Future<void> saveQuickActionsPreferences(
    List<QuickAction> updatedActions,
  ) async {
    _quickActions = updatedActions;
    notifyListeners();

    // TODO: Implement localStorage persistence using shared_preferences
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // final actionTypes = updatedActions.map((a) => a.type).toList();
    // await prefs.setStringList('quick_actions', actionTypes);
    developer.log(
      'Quick actions saved: ${updatedActions.map((a) => a.type).toList()}',
      name: 'HomeProvider',
    );
  }

  /// Clear sensitive data when logged out or token removed.
  void clear() {
    _gpa = null;
    _soTinChiTichLuy = null;
    _studentCard = null;
    // leave mock schedule/notifications untouched or override as needed
    notifyListeners();
  }

  String _getPeriodStartTime(int period) {
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
    return startMap[period] ?? '$period';
  }

  String _getPeriodEndTime(int period) {
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
    return endMap[period] ?? '$period';
  }
}
