/// Model for Teaching Class (Lớp giảng dạy)
class TeachingClass {
  final String maMon;
  final String tenMon;
  final String nhom;
  final String maLop; // Full class code (e.g., DS005.Q11)
  final int siSo;
  final int soTinChi;
  final String? phong;
  final String? thu;
  final String? tietBatDau;
  final String? tietKetThuc;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final String? hocKy;
  final String? namHoc;
  final String? trangThai;

  TeachingClass({
    required this.maMon,
    required this.tenMon,
    required this.nhom,
    required this.maLop,
    required this.siSo,
    required this.soTinChi,
    this.phong,
    this.thu,
    this.tietBatDau,
    this.tietKetThuc,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.hocKy,
    this.namHoc,
    this.trangThai,
  });

  factory TeachingClass.fromJson(Map<String, dynamic> json) {
    // Parse namHoc from hocKy format: "2025_2026_1" -> "2025-2026"
    String? namHoc;
    final hocKy = json['hocKy'] as String?;
    if (hocKy != null && hocKy.contains('_')) {
      final parts = hocKy.split('_');
      if (parts.length >= 2) {
        namHoc = '${parts[0]}-${parts[1]}';
      }
    }
    
    // Parse nhom from maLop (e.g., "DS005.Q11" -> "Q11", "IE104.Q11.2" -> "Q11")
    String nhom = '';
    final maLop = json['maLop'] as String?;
    if (maLop != null && maLop.contains('.')) {
      final parts = maLop.split('.');
      if (parts.length >= 2) {
        nhom = parts[1]; // Get the group part
      }
    }
    
    // Map backend field names to frontend
    // Backend: maMonHoc, tenMonHoc, phongHoc
    // Frontend: maMon, tenMon, phong
    final maMon = json['maMonHoc'] as String? ?? json['maMon'] as String? ?? '';
    final tenMon = json['tenMonHoc'] as String? ?? json['tenMon'] as String? ?? '';
    final phong = json['phongHoc'] as String? ?? json['phong'] as String?;
    
    return TeachingClass(
      maMon: maMon,
      tenMon: tenMon,
      nhom: json['nhom'] as String? ?? nhom,
      maLop: maLop ?? '$maMon.$nhom', // Store maLop from backend or reconstruct it
      siSo: json['siSo'] as int? ?? 0,
      soTinChi: json['soTinChi'] as int? ?? 3,
      phong: phong,
      thu: json['thu'] as String?,
      tietBatDau: json['tietBatDau'] as String?,
      tietKetThuc: json['tietKetThuc'] as String?,
      ngayBatDau: json['ngayBatDau'] != null
          ? DateTime.tryParse(json['ngayBatDau'] as String)
          : null,
      ngayKetThuc: json['ngayKetThuc'] != null
          ? DateTime.tryParse(json['ngayKetThuc'] as String)
          : null,
      hocKy: hocKy,
      namHoc: namHoc ?? json['namHoc'] as String?,
      trangThai: json['trangThai'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maMon': maMon,
      'tenMon': tenMon,
      'nhom': nhom,
      'maLop': maLop,
      'siSo': siSo,
      'soTinChi': soTinChi,
      'phong': phong,
      'thu': thu,
      'tietBatDau': tietBatDau,
      'tietKetThuc': tietKetThuc,
      'ngayBatDau': ngayBatDau?.toIso8601String(),
      'ngayKetThuc': ngayKetThuc?.toIso8601String(),
      'hocKy': hocKy,
      'namHoc': namHoc,
      'trangThai': trangThai,
    };
  }

  // Helper: Get semester number from hocKy (e.g., "2024_2025_1" -> "hk1")
  String? get semesterNumber {
    if (hocKy != null && hocKy!.contains('_')) {
      final parts = hocKy!.split('_');
      if (parts.length >= 3) {
        return 'hk${parts[2]}'; // "2024_2025_1" -> "hk1"
      }
    }
    return null;
  }

  // Helper: Get formatted schedule text
  String get scheduleText {
    if (thu != null && tietBatDau != null && tietKetThuc != null) {
      return 'Thứ $thu, Tiết $tietBatDau-$tietKetThuc';
    }
    return 'Chưa xếp lịch';
  }

  // Helper: Get status color
  String get statusColor {
    switch (trangThai?.toLowerCase()) {
      case 'đang học':
      case 'active':
        return 'success';
      case 'sắp bắt đầu':
      case 'upcoming':
        return 'warning';
      case 'đã kết thúc':
      case 'completed':
        return 'neutral';
      default:
        return 'neutral';
    }
  }
}
