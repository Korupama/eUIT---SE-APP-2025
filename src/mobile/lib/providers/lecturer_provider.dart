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
      } else {
        // Mock data when API fails
        _createMockProfile();
      }
    } catch (e) {
      developer.log(
        'Error fetching lecturer profile: $e',
        name: 'LecturerProvider',
      );
      // Mock data for development
      _createMockProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _createMockProfile() {
    _lecturerProfile = LecturerProfile(
      maGv: '80001',
      hoTen: 'Nguyễn Minh Nam',
      khoaBoMon: 'HTTT',
      ngaySinh: DateTime(1970, 12, 9),
      noiSinh: 'Tỉnh Lạng Sơn',
      email: 'nguyenminhnam@uit.edu.vn',
      soDienThoai: '0901338908',
      cccd: '048170181960',
      ngayCapCccd: DateTime(1991, 2, 26),
      noiCapCccd: 'Công an tỉnh Bình Dương',
      danToc: 'Tày',
      tonGiao: 'Phật giáo',
      diaChiThuongTru: '734 đường Cách Mạng Tháng 8, Xã Ba Sơn',
      tinhThanhPho: 'Tỉnh Lạng Sơn',
      phuongXa: 'Xã Ba Sơn',
    );
  }

  Future<void> _fetchNextClass() async {
    try {
      final token = await auth.getToken();
      if (token == null) {
        _createMockNextClass();
        return;
      }

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
      } else {
        // Mock data when API returns non-200
        _createMockNextClass();
      }
    } catch (e) {
      developer.log('Error fetching next class: $e', name: 'LecturerProvider');
      // Mock data for development
      _createMockNextClass();
    }
  }

  void _createMockNextClass() {
    final now = DateTime.now();
    // Tính ngày thứ 2 tiếp theo
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    final nextMonday = now.add(
      Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday),
    );

    _nextClass = TeachingScheduleItem(
      maMon: 'NT101',
      tenMon: 'Mạng máy tính',
      nhom: 'O11',
      phong: 'E4.1',
      thu: '2',
      tietBatDau: '1',
      tietKetThuc: '3',
      ngayBatDau: nextMonday,
      siSo: 45,
    );
    notifyListeners();
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSchedule() async {
    // Fetch schedule - for now use mock data from _teachingSchedule
    // This is a placeholder for future API integration
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  // Fetch appeals
  Future<void> fetchAppeals({
    String? maMon,
    String? nhom,
    String? trangThai,
  }) async {
    // TODO: Implement API integration
    // For now, return mock data
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      _appeals = [
        Appeal(
          id: 'A001',
          mssv: '22520001',
          tenSinhVien: 'Nguyễn Văn A',
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          nhom: 'O13',
          loaiDiem: 'GK',
          diemCu: 5.5,
          diemMoi: null,
          lyDo:
              'Em xin phúc khảo điểm giữa kỳ môn Mạng máy tính vì em thấy bài thi của em có nhiều câu đúng nhưng điểm không tương xứng.',
          trangThai: 'pending',
          ngayGui: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Appeal(
          id: 'A002',
          mssv: '22520015',
          tenSinhVien: 'Trần Thị B',
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          nhom: 'O13',
          loaiDiem: 'CK',
          diemCu: 6.0,
          diemMoi: 7.5,
          lyDo: 'Em muốn phúc khảo câu 5 và câu 8 trong đề thi cuối kỳ.',
          trangThai: 'approved',
          ngayGui: DateTime.now().subtract(const Duration(days: 5)),
          ngayXuLy: DateTime.now().subtract(const Duration(days: 1)),
          ghiChu: 'Đã kiểm tra lại bài thi, điểm được cập nhật từ 6.0 lên 7.5',
        ),
        Appeal(
          id: 'A003',
          mssv: '22520032',
          tenSinhVien: 'Lê Văn C',
          maMon: 'NT106',
          tenMon: 'Lập trình mạng căn bản',
          nhom: 'N13',
          loaiDiem: 'TX',
          diemCu: 4.0,
          diemMoi: null,
          lyDo:
              'Em đã làm đầy đủ các bài thực hành nhưng điểm TX chỉ có 4.0. Em xin được kiểm tra lại.',
          trangThai: 'rejected',
          ngayGui: DateTime.now().subtract(const Duration(days: 7)),
          ngayXuLy: DateTime.now().subtract(const Duration(days: 3)),
          ghiChu:
              'Điểm TX đã được chấm chính xác, sinh viên thiếu 2 bài thực hành.',
        ),
        Appeal(
          id: 'A004',
          mssv: '22520048',
          tenSinhVien: 'Phạm Thị D',
          maMon: 'NT131',
          tenMon: 'Phân tích thiết kế hệ thống thông tin',
          nhom: 'M13',
          loaiDiem: 'GK',
          diemCu: 7.0,
          diemMoi: null,
          lyDo: 'Em xin phúc khảo câu 3 phần tự luận.',
          trangThai: 'pending',
          ngayGui: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        Appeal(
          id: 'A005',
          mssv: '22520055',
          tenSinhVien: 'Hoàng Văn E',
          maMon: 'NT118',
          tenMon: 'Phát triển ứng dụng trên thiết bị di động',
          nhom: 'N13',
          loaiDiem: 'CK',
          diemCu: 8.0,
          diemMoi: null,
          lyDo: 'Em thấy bài thi của em đạt yêu cầu tốt hơn điểm hiện tại.',
          trangThai: 'pending',
          ngayGui: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      // Apply filters
      if (maMon != null && maMon.isNotEmpty) {
        _appeals = _appeals.where((a) => a.maMon == maMon).toList();
      }
      if (nhom != null && nhom.isNotEmpty) {
        _appeals = _appeals.where((a) => a.nhom == nhom).toList();
      }
      if (trangThai != null && trangThai.isNotEmpty) {
        _appeals = _appeals.where((a) => a.trangThai == trangThai).toList();
      }
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
    // TODO: Implement API integration
    // For now, update mock data
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _appeals.indexWhere((a) => a.id == appealId);
    if (index != -1) {
      final oldAppeal = _appeals[index];
      _appeals[index] = Appeal(
        id: oldAppeal.id,
        mssv: oldAppeal.mssv,
        tenSinhVien: oldAppeal.tenSinhVien,
        maMon: oldAppeal.maMon,
        tenMon: oldAppeal.tenMon,
        nhom: oldAppeal.nhom,
        loaiDiem: oldAppeal.loaiDiem,
        diemCu: oldAppeal.diemCu,
        diemMoi: action == 'approved' ? diemMoi : null,
        lyDo: oldAppeal.lyDo,
        trangThai: action,
        ngayGui: oldAppeal.ngayGui,
        ngayXuLy: DateTime.now(),
        ghiChu: ghiChu,
      );
      notifyListeners();
    }
  }

  // Fetch documents
  Future<void> fetchDocuments({String? maMon, String? loaiTaiLieu}) async {
    // TODO: Implement API integration
    // For now, return mock data
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      _documents = [
        Document(
          id: 'D001',
          tieuDe: 'Slide bài 1: Giới thiệu mạng máy tính',
          moTa:
              'Slide giới thiệu tổng quan về mạng máy tính, mô hình OSI và TCP/IP',
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          loaiTaiLieu: 'slide',
          duongDan: 'documents/NT101/slide_bai1.pdf',
          dungLuong: 2548736, // ~2.4 MB
          ngayTao: DateTime.now().subtract(const Duration(days: 30)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 5)),
          luotXem: 156,
          luotTai: 89,
          tags: ['OSI', 'TCP/IP', 'Mạng'],
        ),
        Document(
          id: 'D002',
          tieuDe: 'Bài tập tuần 3: Địa chỉ IP và Subnetting',
          moTa:
              'Bài tập về cách tính toán địa chỉ IP, subnet mask và chia mạng con',
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          loaiTaiLieu: 'baitap',
          duongDan: 'documents/NT101/baitap_tuan3.docx',
          dungLuong: 524288, // 512 KB
          ngayTao: DateTime.now().subtract(const Duration(days: 20)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 20)),
          luotXem: 124,
          luotTai: 98,
          tags: ['IP', 'Subnetting'],
        ),
        Document(
          id: 'D003',
          tieuDe: 'Đề thi giữa kỳ năm 2023',
          moTa: 'Đề thi tham khảo cho kỳ thi giữa kỳ',
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          loaiTaiLieu: 'dethi',
          duongDan: 'documents/NT101/dethi_giuaky_2023.pdf',
          dungLuong: 1048576, // 1 MB
          ngayTao: DateTime.now().subtract(const Duration(days: 365)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 365)),
          luotXem: 234,
          luotTai: 187,
          tags: ['Đề thi', 'Giữa kỳ'],
        ),
        Document(
          id: 'D004',
          tieuDe: 'Slide bài 1: Socket Programming',
          moTa: 'Giới thiệu về lập trình socket với C#',
          maMon: 'NT106',
          tenMon: 'Lập trình mạng căn bản',
          loaiTaiLieu: 'slide',
          duongDan: 'documents/NT106/slide_socket.pptx',
          dungLuong: 3145728, // 3 MB
          ngayTao: DateTime.now().subtract(const Duration(days: 25)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 10)),
          luotXem: 189,
          luotTai: 134,
          tags: ['Socket', 'C#', 'Network Programming'],
        ),
        Document(
          id: 'D005',
          tieuDe: 'Tài liệu tham khảo: HTTP Protocol',
          moTa: 'Tài liệu chi tiết về giao thức HTTP và HTTPS',
          maMon: 'NT106',
          tenMon: 'Lập trình mạng căn bản',
          loaiTaiLieu: 'tailieu',
          duongDan: 'documents/NT106/http_protocol.pdf',
          dungLuong: 4194304, // 4 MB
          ngayTao: DateTime.now().subtract(const Duration(days: 40)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 15)),
          luotXem: 167,
          luotTai: 112,
          tags: ['HTTP', 'HTTPS', 'Protocol'],
        ),
        Document(
          id: 'D006',
          tieuDe: 'Slide bài 1: UML và Use Case',
          moTa: 'Giới thiệu về ngôn ngữ mô hình hóa UML và Use Case Diagram',
          maMon: 'NT131',
          tenMon: 'Phân tích thiết kế hệ thống thông tin',
          loaiTaiLieu: 'slide',
          duongDan: 'documents/NT131/slide_uml.pdf',
          dungLuong: 2097152, // 2 MB
          ngayTao: DateTime.now().subtract(const Duration(days: 28)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 7)),
          luotXem: 145,
          luotTai: 98,
          tags: ['UML', 'Use Case'],
        ),
        Document(
          id: 'D007',
          tieuDe: 'Bài tập: Vẽ Class Diagram',
          moTa: 'Bài tập thực hành vẽ Class Diagram cho hệ thống quản lý',
          maMon: 'NT131',
          tenMon: 'Phân tích thiết kế hệ thống thông tin',
          loaiTaiLieu: 'baitap',
          duongDan: 'documents/NT131/baitap_class_diagram.docx',
          dungLuong: 786432, // 768 KB
          ngayTao: DateTime.now().subtract(const Duration(days: 15)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 15)),
          luotXem: 112,
          luotTai: 89,
          tags: ['Class Diagram', 'UML'],
        ),
        Document(
          id: 'D008',
          tieuDe: 'Slide bài 1: Flutter Basics',
          moTa: 'Giới thiệu cơ bản về Flutter và Dart',
          maMon: 'NT118',
          tenMon: 'Phát triển ứng dụng trên thiết bị di động',
          loaiTaiLieu: 'slide',
          duongDan: 'documents/NT118/flutter_basics.pptx',
          dungLuong: 5242880, // 5 MB
          ngayTao: DateTime.now().subtract(const Duration(days: 22)),
          ngayCapNhat: DateTime.now().subtract(const Duration(days: 3)),
          luotXem: 201,
          luotTai: 156,
          tags: ['Flutter', 'Dart', 'Mobile'],
        ),
      ];

      // Apply filters
      if (maMon != null && maMon.isNotEmpty) {
        _documents = _documents.where((d) => d.maMon == maMon).toList();
      }
      if (loaiTaiLieu != null && loaiTaiLieu.isNotEmpty) {
        _documents = _documents
            .where((d) => d.loaiTaiLieu == loaiTaiLieu)
            .toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload document (mock)
  Future<void> uploadDocument(Document document) async {
    // TODO: Implement API integration
    await Future.delayed(const Duration(milliseconds: 500));

    _documents.insert(0, document);
    notifyListeners();
  }

  // Delete document (mock)
  Future<void> deleteDocument(String documentId) async {
    // TODO: Implement API integration
    await Future.delayed(const Duration(milliseconds: 500));

    _documents.removeWhere((d) => d.id == documentId);
    notifyListeners();
  }

  // Fetch exam schedules
  Future<void> fetchExamSchedules({String? loaiThi, String? vaiTro}) async {
    // TODO: Implement API integration
    // For now, return mock data
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      _examSchedules = [
        ExamSchedule(
          id: 'E001',
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          nhom: 'O13',
          loaiThi: 'giuaky',
          ngayThi: DateTime.now().add(const Duration(days: 5)),
          gioBatDau: '07:30',
          gioKetThuc: '09:00',
          phong: 'E4.1',
          toaNha: 'Nhà E4',
          siSo: 42,
          vaiTro: 'coithi',
          ghiChu: 'Mang theo CCCD',
        ),
        ExamSchedule(
          id: 'E002',
          maMon: 'NT106',
          tenMon: 'Lập trình mạng căn bản',
          nhom: 'N13',
          loaiThi: 'cuoiky',
          ngayThi: DateTime.now().add(const Duration(days: 12)),
          gioBatDau: '09:30',
          gioKetThuc: '11:30',
          phong: 'E4.2',
          toaNha: 'Nhà E4',
          siSo: 38,
          vaiTro: 'coithi',
        ),
        ExamSchedule(
          id: 'E003',
          maMon: 'NT131',
          tenMon: 'Phân tích thiết kế hệ thống thông tin',
          nhom: 'M13',
          loaiThi: 'giuaky',
          ngayThi: DateTime.now().add(const Duration(days: 7)),
          gioBatDau: '13:30',
          gioKetThuc: '15:00',
          phong: 'E3.3',
          toaNha: 'Nhà E3',
          siSo: 35,
          vaiTro: 'coithi',
        ),
        ExamSchedule(
          id: 'E004',
          maMon: 'NT118',
          tenMon: 'Phát triển ứng dụng trên thiết bị di động',
          nhom: 'N13',
          loaiThi: 'cuoiky',
          ngayThi: DateTime.now().add(const Duration(days: 15)),
          gioBatDau: '07:30',
          gioKetThuc: '09:30',
          phong: 'E4.4',
          toaNha: 'Nhà E4',
          siSo: 40,
          vaiTro: 'coithi',
        ),
        ExamSchedule(
          id: 'E005',
          maMon: 'NT101',
          tenMon: 'Mạng máy tính',
          nhom: 'O13',
          loaiThi: 'giuaky',
          ngayThi: DateTime.now().add(const Duration(days: 8)),
          gioBatDau: '14:00',
          gioKetThuc: '16:00',
          phong: 'Phòng giảng viên',
          toaNha: 'Nhà E4',
          siSo: 42,
          vaiTro: 'chamthi',
          ghiChu: 'Chấm bài thi giữa kỳ',
        ),
        ExamSchedule(
          id: 'E006',
          maMon: 'NT209',
          tenMon: 'An toàn và bảo mật thông tin',
          nhom: 'N13',
          loaiThi: 'cuoiky',
          ngayThi: DateTime.now().add(const Duration(days: 18)),
          gioBatDau: '09:30',
          gioKetThuc: '11:30',
          phong: 'E3.1',
          toaNha: 'Nhà E3',
          siSo: 37,
          vaiTro: 'coithi',
        ),
        // Past exam for testing
        ExamSchedule(
          id: 'E007',
          maMon: 'NT106',
          tenMon: 'Lập trình mạng căn bản',
          nhom: 'N13',
          loaiThi: 'giuaky',
          ngayThi: DateTime.now().subtract(const Duration(days: 10)),
          gioBatDau: '07:30',
          gioKetThuc: '09:00',
          phong: 'E4.1',
          toaNha: 'Nhà E4',
          siSo: 38,
          vaiTro: 'chamthi',
          ghiChu: 'Đã hoàn thành chấm thi',
        ),
      ];

      // Apply filters
      if (loaiThi != null && loaiThi.isNotEmpty) {
        _examSchedules = _examSchedules
            .where((e) => e.loaiThi == loaiThi)
            .toList();
      }
      if (vaiTro != null && vaiTro.isNotEmpty) {
        _examSchedules = _examSchedules
            .where((e) => e.vaiTro == vaiTro)
            .toList();
      }

      // Sort by date
      _examSchedules.sort((a, b) => a.ngayThi.compareTo(b.ngayThi));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _init();
  }
}
