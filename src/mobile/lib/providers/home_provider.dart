import 'package:flutter/material.dart';
import '../models/schedule_item.dart';
import '../models/notification_item.dart';
import '../models/quick_action.dart';

class HomeProvider extends ChangeNotifier {
  final bool _isLoading = false;

  HomeProvider() {
    _loadMock();
  }

  late ScheduleItem _nextSchedule;
  List<NotificationItem> _notifications = [];
  List<QuickAction> _quickActions = [];

  bool get isLoading => _isLoading;
  ScheduleItem get nextSchedule => _nextSchedule;
  List<NotificationItem> get notifications => _notifications;
  List<QuickAction> get quickActions => _quickActions;

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
  }
}

