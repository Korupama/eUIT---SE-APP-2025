/// Model for Teaching Class (Lớp giảng dạy)
class TeachingClass {
  final String maMon;
  final String tenMon;
  final String nhom;
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
    return TeachingClass(
      maMon: json['maMon'] as String,
      tenMon: json['tenMon'] as String,
      nhom: json['nhom'] as String,
      siSo: json['siSo'] as int? ?? 0,
      soTinChi: json['soTinChi'] as int? ?? 3,
      phong: json['phong'] as String?,
      thu: json['thu'] as String?,
      tietBatDau: json['tietBatDau'] as String?,
      tietKetThuc: json['tietKetThuc'] as String?,
      ngayBatDau: json['ngayBatDau'] != null
          ? DateTime.tryParse(json['ngayBatDau'] as String)
          : null,
      ngayKetThuc: json['ngayKetThuc'] != null
          ? DateTime.tryParse(json['ngayKetThuc'] as String)
          : null,
      hocKy: json['hocKy'] as String?,
      namHoc: json['namHoc'] as String?,
      trangThai: json['trangThai'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maMon': maMon,
      'tenMon': tenMon,
      'nhom': nhom,
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
