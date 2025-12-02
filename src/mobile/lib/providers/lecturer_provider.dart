import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/lecturer_models.dart';
import '../models/teaching_class.dart';
import '../models/notification_item.dart';
import '../models/quick_action.dart';
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

  TeachingScheduleItem? _nextClass;
  TeachingScheduleItem? get nextClass => _nextClass;

  List<TeachingClass> _teachingClasses = [];
  List<TeachingClass> get teachingClasses => _teachingClasses;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  List<QuickAction> _quickActions = [];
  List<QuickAction> get quickActions => _quickActions;

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
      developer.log('LecturerProvider init error: $e', name: 'LecturerProvider');
    }

    _initQuickActions();
    _isLoading = false;
    notifyListeners();
  }

  void _initQuickActions() {
    _quickActions = [
      QuickAction(
        label: 'Thẻ GV',
        type: 'lecturer_card',
        iconName: 'badge_outlined',
      ),
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
        label: 'Điểm danh',
        type: 'lecturer_attendance',
        iconName: 'check_box_outlined',
      ),
      QuickAction(
        label: 'Tài liệu',
        type: 'lecturer_documents',
        iconName: 'description_outlined',
      ),
    ];
  }

  Future<void> _fetchLecturerCard() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/card');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _lecturerCard = LecturerCard.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error fetching lecturer card: $e', name: 'LecturerProvider');
    }
  }

  Future<void> fetchLecturerProfile() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/profile');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _lecturerProfile = LecturerProfile.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error fetching lecturer profile: $e', name: 'LecturerProvider');
    }
  }

  Future<void> _fetchNextClass() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/next-class');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

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
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _teachingSchedule = data.map((item) => TeachingScheduleItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error fetching teaching schedule: $e', name: 'LecturerProvider');
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/notifications');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

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
      developer.log('Error fetching notifications: $e', name: 'LecturerProvider');
      // Mock data for development
      _notifications = [
        NotificationItem(
          id: '1',
          title: 'Nhắc nhở nhập điểm',
          body: 'Vui lòng nhập điểm cho lớp NT101.O11 trước 15/12/2025',
          isUnread: true,
          time: '2 giờ trước',
        ),
        NotificationItem(
          id: '2',
          title: 'Lịch họp khoa',
          body: 'Họp khoa vào thứ 5 tuần sau lúc 14:00',
          isUnread: true,
          time: '1 ngày trước',
        ),
      ];
    }
  }

  Future<void> fetchTeachingClasses() async {
    try {
      final token = await auth.getToken();
      if (token == null) return;

      final uri = auth.buildUri('/api/Lecturer/classes');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _teachingClasses = data.map((item) => TeachingClass.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error fetching teaching classes: $e', name: 'LecturerProvider');
      // Mock data for development
      _teachingClasses = [
        TeachingClass(
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          nhom: 'O11',
          siSo: 45,
          soTinChi: 4,
          phong: 'E4.1',
          thu: '2',
          tietBatDau: '1',
          tietKetThuc: '3',
          hocKy: 'hk1',
          namHoc: '2024-2025',
          trangThai: 'Đang học',
        ),
        TeachingClass(
          maMon: 'NT106',
          tenMon: 'Lập trình mạng căn bản',
          nhom: 'O21',
          siSo: 40,
          soTinChi: 4,
          phong: 'E4.2',
          thu: '4',
          tietBatDau: '4',
          tietKetThuc: '6',
          hocKy: 'hk1',
          namHoc: '2024-2025',
          trangThai: 'Đang học',
        ),
        TeachingClass(
          maMon: 'NT131',
          tenMon: 'Lập trình hướng đối tượng',
          nhom: 'O12',
          siSo: 50,
          soTinChi: 4,
          phong: 'E3.5',
          thu: '5',
          tietBatDau: '7',
          tietKetThuc: '9',
          hocKy: 'hk1',
          namHoc: '2024-2025',
          trangThai: 'Đang học',
        ),
        TeachingClass(
          maMon: 'NT118',
          tenMon: 'Phát triển ứng dụng trên thiết bị di động',
          nhom: 'O11',
          siSo: 35,
          soTinChi: 4,
          phong: 'E4.3',
          thu: '3',
          tietBatDau: '1',
          tietKetThuc: '3',
          hocKy: 'hk2',
          namHoc: '2024-2025',
          trangThai: 'Sắp bắt đầu',
        ),
        TeachingClass(
          maMon: 'NT209',
          tenMon: 'Nhập môn trí tuệ nhân tạo',
          nhom: 'O13',
          siSo: 42,
          soTinChi: 4,
          phong: 'E4.4',
          thu: '6',
          tietBatDau: '4',
          tietKetThuc: '6',
          hocKy: 'hk2',
          namHoc: '2024-2025',
          trangThai: 'Sắp bắt đầu',
        ),
      ];
    }
  }

  Future<void> refresh() async {
    await _init();
  }
}
