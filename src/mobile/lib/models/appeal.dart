class Appeal {
  final String id;
  final String mssv;
  final String tenSinhVien;
  final String maMon;
  final String tenMon;
  final String nhom;
  final String loaiDiem; // TX, GK, CK
  final double? diemCu;
  final double? diemMoi;
  final String lyDo;
  final String trangThai; // pending, approved, rejected
  final DateTime ngayGui;
  final DateTime? ngayXuLy;
  final String? ghiChu;

  Appeal({
    required this.id,
    required this.mssv,
    required this.tenSinhVien,
    required this.maMon,
    required this.tenMon,
    required this.nhom,
    required this.loaiDiem,
    this.diemCu,
    this.diemMoi,
    required this.lyDo,
    required this.trangThai,
    required this.ngayGui,
    this.ngayXuLy,
    this.ghiChu,
  });

  factory Appeal.fromJson(Map<String, dynamic> json) {
    return Appeal(
      id: json['id'] as String,
      mssv: json['mssv'] as String,
      tenSinhVien: json['tenSinhVien'] as String,
      maMon: json['maMon'] as String,
      tenMon: json['tenMon'] as String,
      nhom: json['nhom'] as String,
      loaiDiem: json['loaiDiem'] as String,
      diemCu: json['diemCu'] as double?,
      diemMoi: json['diemMoi'] as double?,
      lyDo: json['lyDo'] as String,
      trangThai: json['trangThai'] as String,
      ngayGui: DateTime.parse(json['ngayGui'] as String),
      ngayXuLy: json['ngayXuLy'] != null
          ? DateTime.parse(json['ngayXuLy'] as String)
          : null,
      ghiChu: json['ghiChu'] as String?,
    );
  }

  String get statusText {
    switch (trangThai) {
      case 'pending':
        return 'Chờ xử lý';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return trangThai;
    }
  }

  String get initials {
    final words = tenSinhVien.split(' ');
    if (words.length >= 2) {
      return '${words[words.length - 2][0]}${words.last[0]}'.toUpperCase();
    }
    return tenSinhVien.substring(0, 2).toUpperCase();
  }
}
