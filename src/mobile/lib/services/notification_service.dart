import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Các loại notification từ server
enum NotificationType {
  ketQuaHocTap,
  baoBu,
  baoNghi,
  diemRenLuyen,
}

/// Model cho notification Kết quả học tập
class KetQuaHocTapNotification {
  final String maMonHoc;
  final String tenMonHoc;
  final String maLopHocPhan;
  final double? diemQuaTrinh;
  final double? diemGiuaKy;
  final double? diemCuoiKy;
  final double? diemTongKet;
  final String? diemChu;
  final String hocKy;
  final String namHoc;

  KetQuaHocTapNotification({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.maLopHocPhan,
    this.diemQuaTrinh,
    this.diemGiuaKy,
    this.diemCuoiKy,
    this.diemTongKet,
    this.diemChu,
    required this.hocKy,
    required this.namHoc,
  });

  factory KetQuaHocTapNotification.fromJson(Map<String, dynamic> json) {
    return KetQuaHocTapNotification(
      maMonHoc: json['maMonHoc'] ?? '',
      tenMonHoc: json['tenMonHoc'] ?? '',
      maLopHocPhan: json['maLopHocPhan'] ?? '',
      diemQuaTrinh: (json['diemQuaTrinh'] as num?)?.toDouble(),
      diemGiuaKy: (json['diemGiuaKy'] as num?)?.toDouble(),
      diemCuoiKy: (json['diemCuoiKy'] as num?)?.toDouble(),
      diemTongKet: (json['diemTongKet'] as num?)?.toDouble(),
      diemChu: json['diemChu'],
      hocKy: json['hocKy'] ?? '',
      namHoc: json['namHoc'] ?? '',
    );
  }
}

/// Model cho notification Báo bù
class BaoBuNotification {
  final String maLopHocPhan;
  final String tenMonHoc;
  final DateTime ngayBu;
  final String tietBatDau;
  final String tietKetThuc;
  final String phongHoc;
  final String? ghiChu;

  BaoBuNotification({
    required this.maLopHocPhan,
    required this.tenMonHoc,
    required this.ngayBu,
    required this.tietBatDau,
    required this.tietKetThuc,
    required this.phongHoc,
    this.ghiChu,
  });

  factory BaoBuNotification.fromJson(Map<String, dynamic> json) {
    return BaoBuNotification(
      maLopHocPhan: json['maLopHocPhan'] ?? '',
      tenMonHoc: json['tenMonHoc'] ?? '',
      ngayBu: DateTime.parse(json['ngayBu']),
      tietBatDau: json['tietBatDau'] ?? '',
      tietKetThuc: json['tietKetThuc'] ?? '',
      phongHoc: json['phongHoc'] ?? '',
      ghiChu: json['ghiChu'],
    );
  }
}

/// Model cho notification Báo nghỉ
class BaoNghiNotification {
  final String maLopHocPhan;
  final String tenMonHoc;
  final DateTime ngayNghi;
  final String lyDo;
  final String? ghiChu;

  BaoNghiNotification({
    required this.maLopHocPhan,
    required this.tenMonHoc,
    required this.ngayNghi,
    required this.lyDo,
    this.ghiChu,
  });

  factory BaoNghiNotification.fromJson(Map<String, dynamic> json) {
    return BaoNghiNotification(
      maLopHocPhan: json['maLopHocPhan'] ?? '',
      tenMonHoc: json['tenMonHoc'] ?? '',
      ngayNghi: DateTime.parse(json['ngayNghi']),
      lyDo: json['lyDo'] ?? '',
      ghiChu: json['ghiChu'],
    );
  }
}

/// Model cho notification Điểm rèn luyện
class DiemRenLuyenNotification {
  final String hocKy;
  final String namHoc;
  final int diemRenLuyen;
  final String xepLoai;

  DiemRenLuyenNotification({
    required this.hocKy,
    required this.namHoc,
    required this.diemRenLuyen,
    required this.xepLoai,
  });

  factory DiemRenLuyenNotification.fromJson(Map<String, dynamic> json) {
    return DiemRenLuyenNotification(
      hocKy: json['hocKy'] ?? '',
      namHoc: json['namHoc'] ?? '',
      diemRenLuyen: json['diemRenLuyen'] ?? 0,
      xepLoai: json['xepLoai'] ?? '',
    );
  }
}

/// Service quản lý kết nối SignalR và nhận notifications
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  String? _currentMssv;

  // Stream controllers cho từng loại notification
  final _ketQuaHocTapController = StreamController<KetQuaHocTapNotification>.broadcast();
  final _baoBuController = StreamController<BaoBuNotification>.broadcast();
  final _baoNghiController = StreamController<BaoNghiNotification>.broadcast();
  final _diemRenLuyenController = StreamController<DiemRenLuyenNotification>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  // Streams để lắng nghe notifications
  Stream<KetQuaHocTapNotification> get onKetQuaHocTap => _ketQuaHocTapController.stream;
  Stream<BaoBuNotification> get onBaoBu => _baoBuController.stream;
  Stream<BaoNghiNotification> get onBaoNghi => _baoNghiController.stream;
  Stream<DiemRenLuyenNotification> get onDiemRenLuyen => _diemRenLuyenController.stream;
  Stream<bool> get onConnectionStateChanged => _connectionStateController.stream;

  bool get isConnected => _isConnected;
  String? get currentMssv => _currentMssv;

  /// Lấy URL của socket server
  String _getSocketUrl() {
    String baseUrl;
    try {
      final url = (dotenv.isInitialized ? dotenv.env['SOCKET_URL'] : null)?.trim();
      baseUrl = (url != null && url.isNotEmpty) ? url : 'http://localhost:5000';
    } catch (_) {
      baseUrl = 'http://localhost:5000';
    }

    // Android emulator localhost remap
    if (Platform.isAndroid) {
      try {
        final parsed = Uri.parse(baseUrl);
        if (parsed.host == 'localhost' || parsed.host == '127.0.0.1') {
          baseUrl = parsed.replace(host: '10.0.2.2').toString();
        }
      } catch (_) {
        // keep as-is
      }
    }

    return baseUrl;
  }

  /// Kết nối tới SignalR hub và subscribe với MSSV
  Future<void> connect(String mssv) async {
    if (_isConnected && _currentMssv == mssv) {
      debugPrint('NotificationService: Already connected for MSSV $mssv');
      return;
    }

    if (_isConnected) {
      await disconnect();
    }

    final socketUrl = _getSocketUrl();
    // The HubConnectionBuilder will handle the negotiation by replacing ws/wss with http/https.
    // We provide the base websocket URL.
    final hubUrl = '$socketUrl/notifications';

    debugPrint('NotificationService: Connecting to $hubUrl');

    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl, transportType: HttpTransportType.WebSockets) // Specify transport
          .withAutomaticReconnect()
          .build();

      // Đăng ký handlers cho các events
      _registerHandlers();

      // Kết nối
      await _hubConnection!.start();
      
      // Subscribe với MSSV
      await _hubConnection!.invoke('Subscribe', args: [mssv]);

      _currentMssv = mssv;
      _isConnected = true;
      _connectionStateController.add(true);
      notifyListeners();

      debugPrint('NotificationService: Connected and subscribed for MSSV $mssv');

      // Handle reconnection
      _hubConnection!.onreconnected(({connectionId}) {
        debugPrint('NotificationService: Reconnected with ID $connectionId');
        // Re-subscribe after reconnection
        _hubConnection!.invoke('Subscribe', args: [mssv]);
        _isConnected = true;
        _connectionStateController.add(true);
        notifyListeners();
      });

      _hubConnection!.onreconnecting(({error}) {
        debugPrint('NotificationService: Reconnecting... Error: $error');
        _isConnected = false;
        _connectionStateController.add(false);
        notifyListeners();
      });

      _hubConnection!.onclose(({error}) {
        debugPrint('NotificationService: Connection closed. Error: $error');
        _isConnected = false;
        _connectionStateController.add(false);
        notifyListeners();
      });

    } catch (e) {
      debugPrint('NotificationService: Connection error: $e');
      _isConnected = false;
      _connectionStateController.add(false);
      notifyListeners();
      rethrow;
    }
  }

  /// Đăng ký handlers cho các SignalR events
  void _registerHandlers() {
    // Kết quả học tập
    _hubConnection!.on('ReceiveKetQuaHocTap', (arguments) {
      debugPrint('NotificationService: Received KetQuaHocTap: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final payload = arguments[0] as Map<String, dynamic>;
          // Data nằm trong payload['data']
          final data = payload['data'] as Map<String, dynamic>;
          final notification = KetQuaHocTapNotification.fromJson(data);
          _ketQuaHocTapController.add(notification);
        } catch (e) {
          debugPrint('NotificationService: Error parsing KetQuaHocTap: $e');
        }
      }
    });

    // Báo bù
    _hubConnection!.on('ReceiveBaoBu', (arguments) {
      debugPrint('NotificationService: Received BaoBu: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final payload = arguments[0] as Map<String, dynamic>;
          // Data nằm trong payload['data']
          final data = payload['data'] as Map<String, dynamic>;
          final notification = BaoBuNotification.fromJson(data);
          _baoBuController.add(notification);
        } catch (e) {
          debugPrint('NotificationService: Error parsing BaoBu: $e');
        }
      }
    });

    // Báo nghỉ
    _hubConnection!.on('ReceiveBaoNghi', (arguments) {
      debugPrint('NotificationService: Received BaoNghi: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final payload = arguments[0] as Map<String, dynamic>;
          // Data nằm trong payload['data']
          final data = payload['data'] as Map<String, dynamic>;
          final notification = BaoNghiNotification.fromJson(data);
          _baoNghiController.add(notification);
        } catch (e) {
          debugPrint('NotificationService: Error parsing BaoNghi: $e');
        }
      }
    });

    // Điểm rèn luyện
    _hubConnection!.on('ReceiveDiemRenLuyen', (arguments) {
      debugPrint('NotificationService: Received DiemRenLuyen: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final payload = arguments[0] as Map<String, dynamic>;
          // Data nằm trong payload['data']
          final data = payload['data'] as Map<String, dynamic>;
          final notification = DiemRenLuyenNotification.fromJson(data);
          _diemRenLuyenController.add(notification);
        } catch (e) {
          debugPrint('NotificationService: Error parsing DiemRenLuyen: $e');
        }
      }
    });
  }

  /// Ngắt kết nối
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        if (_currentMssv != null) {
          await _hubConnection!.invoke('Unsubscribe', args: [_currentMssv!]);
        }
        await _hubConnection!.stop();
      } catch (e) {
        debugPrint('NotificationService: Error disconnecting: $e');
      }
    }

    _hubConnection = null;
    _currentMssv = null;
    _isConnected = false;
    _connectionStateController.add(false);
    notifyListeners();

    debugPrint('NotificationService: Disconnected');
  }

  /// Dispose resources
  @override
  void dispose() {
    disconnect();
    _ketQuaHocTapController.close();
    _baoBuController.close();
    _baoNghiController.close();
    _diemRenLuyenController.close();
    _connectionStateController.close();
    super.dispose();
  }
}
