/// Models for Lecturer (Giảng viên)
class LecturerProfile {
  final String maGv;
  final String hoTen;
  final String? khoaBoMon; // Khỏa/Bộ môn (HTTT, CNTT...)
  final DateTime? ngaySinh;
  final String? noiSinh;
  final String? gioiTinh;
  final String? email;
  final String? soDienThoai;
  final String? cccd;
  final DateTime? ngayCapCccd;
  final String? noiCapCccd;
  final String? danToc;
  final String? tonGiao;
  final String? diaChiThuongTru;
  final String? tinhThanhPho;
  final String? phuongXa;
  final String? anhTheUrl;

  LecturerProfile({
    required this.maGv,
    required this.hoTen,
    this.khoaBoMon,
    this.ngaySinh,
    this.noiSinh,
    this.gioiTinh,
    this.email,
    this.soDienThoai,
    this.cccd,
    this.ngayCapCccd,
    this.noiCapCccd,
    this.danToc,
    this.tonGiao,
    this.diaChiThuongTru,
    this.tinhThanhPho,
    this.phuongXa,
    this.anhTheUrl,
  });

  factory LecturerProfile.fromJson(Map<String, dynamic> json) {
    return LecturerProfile(
      maGv: (json['maGiangVien'] ?? json['maGv']) as String,
      hoTen: json['hoTen'] as String,
      khoaBoMon: json['khoaBoMon'] as String?,
      ngaySinh: json['ngaySinh'] != null
          ? DateTime.tryParse(json['ngaySinh'] as String)
          : null,
      noiSinh: json['noiSinh'] as String?,
      gioiTinh: json['gioiTinh'] as String?,
      email: json['email'] as String?,
      soDienThoai: json['soDienThoai'] as String?,
      cccd: json['cccd'] as String?,
      ngayCapCccd: json['ngayCapCccd'] != null
          ? DateTime.tryParse(json['ngayCapCccd'] as String)
          : null,
      noiCapCccd: json['noiCapCccd'] as String?,
      danToc: json['danToc'] as String?,
      tonGiao: json['tonGiao'] as String?,
      diaChiThuongTru: json['diaChiThuongTru'] as String?,
      tinhThanhPho: json['tinhThanhPho'] as String?,
      phuongXa: json['phuongXa'] as String?,
      anhTheUrl: json['anhTheUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maGv': maGv,
      'hoTen': hoTen,
      'khoaBoMon': khoaBoMon,
      'ngaySinh': ngaySinh?.toIso8601String(),
      'noiSinh': noiSinh,
      'gioiTinh': gioiTinh,
      'email': email,
      'soDienThoai': soDienThoai,
      'cccd': cccd,
      'ngayCapCccd': ngayCapCccd?.toIso8601String(),
      'noiCapCccd': noiCapCccd,
      'danToc': danToc,
      'tonGiao': tonGiao,
      'diaChiThuongTru': diaChiThuongTru,
      'tinhThanhPho': tinhThanhPho,
      'phuongXa': phuongXa,
      'anhTheUrl': anhTheUrl,
    };
  }
}

/// Card info for Lecturer
class LecturerCard {
  final String maGv;
  final String hoTen;
  final String? khoa;
  final String? boMon;
  final String? chucDanh;
  final String? email;

  LecturerCard({
    required this.maGv,
    required this.hoTen,
    this.khoa,
    this.boMon,
    this.chucDanh,
    this.email,
  });

  factory LecturerCard.fromJson(Map<String, dynamic> json) {
    return LecturerCard(
      maGv: json['maGv'] as String,
      hoTen: json['hoTen'] as String,
      khoa: json['khoa'] as String?,
      boMon: json['boMon'] as String?,
      chucDanh: json['chucDanh'] as String?,
      email: json['email'] as String?,
    );
  }
}

/// Teaching Schedule Item for Lecturer
class TeachingScheduleItem {
  final String maMon;
  final String tenMon;
  final String? nhom;
  final String? phong;
  final String? thu;
  final String? tietBatDau;
  final String? tietKetThuc;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final int? soTiet;
  final int? siSo;
  final int? cachTuan; // 1 = every week, 2 = every 2 weeks

  TeachingScheduleItem({
    required this.maMon,
    required this.tenMon,
    this.nhom,
    this.phong,
    this.thu,
    this.tietBatDau,
    this.tietKetThuc,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.soTiet,
    this.siSo,
    this.cachTuan,
  });

  factory TeachingScheduleItem.fromJson(Map<String, dynamic> json) {
    // Parse nhom from maLop (e.g., "DS005.Q11" -> "Q11")
    String? nhom;
    final maLop = json['maLop'] as String?;
    if (maLop != null && maLop.contains('.')) {
      final parts = maLop.split('.');
      if (parts.length >= 2) {
        nhom = parts[1];
      }
    }
    
    // Map backend field names (maMonHoc, tenMonHoc, phongHoc, tietBatDau, tietKetThuc)
    final maMon = json['maMonHoc'] as String? ?? json['maMon'] as String? ?? '';
    final tenMon = json['tenMonHoc'] as String? ?? json['tenMon'] as String? ?? '';
    final phong = json['phongHoc'] as String? ?? json['phong'] as String?;
    
    // Handle tietBatDau and tietKetThuc which can be int or String
    String? tietBatDau;
    String? tietKetThuc;
    
    if (json['tietBatDau'] != null) {
      tietBatDau = json['tietBatDau'].toString();
    }
    if (json['tietKetThuc'] != null) {
      tietKetThuc = json['tietKetThuc'].toString();
    }
    
    return TeachingScheduleItem(
      maMon: maMon,
      tenMon: tenMon,
      nhom: json['nhom'] as String? ?? nhom,
      phong: phong,
      thu: json['thu'] as String?,
      tietBatDau: tietBatDau,
      tietKetThuc: tietKetThuc,
      ngayBatDau: json['ngayBatDau'] != null
          ? DateTime.tryParse(json['ngayBatDau'] as String)
          : null,
      ngayKetThuc: json['ngayKetThuc'] != null
          ? DateTime.tryParse(json['ngayKetThuc'] as String)
          : null,
      soTiet: json['soTiet'] as int?,
      siSo: json['siSo'] as int?,
      cachTuan: json['cachTuan'] as int? ?? 1,
    );
  }
}
