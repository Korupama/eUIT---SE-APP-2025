/// Model for Student in a Class (Sinh viên trong lớp)
class ClassStudent {
  final String mssv;
  final String hoTen;
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? email;
  final String? soDienThoai;
  final String? lopSinhHoat;
  final String? anhTheUrl;
  final double? diemThuongXuyen;
  final double? diemGiuaKy;
  final double? diemCuoiKy;
  final double? diemTongKet;
  final int? soTietVang;
  final String? trangThai;

  ClassStudent({
    required this.mssv,
    required this.hoTen,
    this.ngaySinh,
    this.gioiTinh,
    this.email,
    this.soDienThoai,
    this.lopSinhHoat,
    this.anhTheUrl,
    this.diemThuongXuyen,
    this.diemGiuaKy,
    this.diemCuoiKy,
    this.diemTongKet,
    this.soTietVang,
    this.trangThai,
  });

  factory ClassStudent.fromJson(Map<String, dynamic> json) {
    return ClassStudent(
      mssv: json['mssv']?.toString() ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      ngaySinh: json['ngaySinh'] != null
          ? DateTime.tryParse(json['ngaySinh'] as String)
          : null,
      gioiTinh: json['gioiTinh'] as String?,
      email: json['email'] as String?,
      soDienThoai: json['soDienThoai'] as String?,
      lopSinhHoat: json['lopSinhHoat'] as String?,
      anhTheUrl: json['anhTheUrl'] as String?,
      diemThuongXuyen: json['diemThuongXuyen'] != null
          ? (json['diemThuongXuyen'] as num).toDouble()
          : null,
      diemGiuaKy: json['diemGiuaKy'] != null
          ? (json['diemGiuaKy'] as num).toDouble()
          : null,
      diemCuoiKy: json['diemCuoiKy'] != null
          ? (json['diemCuoiKy'] as num).toDouble()
          : null,
      diemTongKet: json['diemTongKet'] != null
          ? (json['diemTongKet'] as num).toDouble()
          : null,
      soTietVang: json['soTietVang'] as int?,
      trangThai: json['trangThai'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mssv': mssv,
      'hoTen': hoTen,
      'ngaySinh': ngaySinh?.toIso8601String(),
      'gioiTinh': gioiTinh,
      'email': email,
      'soDienThoai': soDienThoai,
      'lopSinhHoat': lopSinhHoat,
      'anhTheUrl': anhTheUrl,
      'diemThuongXuyen': diemThuongXuyen,
      'diemGiuaKy': diemGiuaKy,
      'diemCuoiKy': diemCuoiKy,
      'diemTongKet': diemTongKet,
      'soTietVang': soTietVang,
      'trangThai': trangThai,
    };
  }

  // Helper: Get initials from name
  String get initials {
    final parts = hoTen.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // Helper: Get status color
  String get statusColor {
    switch (trangThai?.toLowerCase()) {
      case 'đang học':
      case 'active':
        return 'success';
      case 'bảo lưu':
      case 'hold':
        return 'warning';
      case 'đã thôi học':
      case 'dropout':
        return 'error';
      default:
        return 'neutral';
    }
  }

  // Helper: Check if student is at risk (nhiều vắng hoặc điểm thấp)
  bool get isAtRisk {
    if (soTietVang != null && soTietVang! >= 3) return true;
    if (diemTongKet != null && diemTongKet! < 4.0) return true;
    return false;
  }
}
