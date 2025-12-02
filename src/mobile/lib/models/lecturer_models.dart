/// Models for Lecturer (Giảng viên)
class LecturerProfile {
  final String maGv;
  final String hoTen;
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? email;
  final String? soDienThoai;
  final String? khoa;
  final String? boMon;
  final String? hocVi;
  final String? chucDanh;
  final String? chuyenNganh;
  final String? cccd;
  final DateTime? ngayCapCccd;
  final String? noiCapCccd;
  final String? diaChiThuongTru;
  final String? tinhThanhPho;
  final String? phuongXa;
  final String? danToc;
  final String? tonGiao;
  final String? quocTich;
  final String? anhTheUrl;

  LecturerProfile({
    required this.maGv,
    required this.hoTen,
    this.ngaySinh,
    this.gioiTinh,
    this.email,
    this.soDienThoai,
    this.khoa,
    this.boMon,
    this.hocVi,
    this.chucDanh,
    this.chuyenNganh,
    this.cccd,
    this.ngayCapCccd,
    this.noiCapCccd,
    this.diaChiThuongTru,
    this.tinhThanhPho,
    this.phuongXa,
    this.danToc,
    this.tonGiao,
    this.quocTich,
    this.anhTheUrl,
  });

  factory LecturerProfile.fromJson(Map<String, dynamic> json) {
    return LecturerProfile(
      maGv: json['maGv'] as String,
      hoTen: json['hoTen'] as String,
      ngaySinh: json['ngaySinh'] != null
          ? DateTime.tryParse(json['ngaySinh'] as String)
          : null,
      gioiTinh: json['gioiTinh'] as String?,
      email: json['email'] as String?,
      soDienThoai: json['soDienThoai'] as String?,
      khoa: json['khoa'] as String?,
      boMon: json['boMon'] as String?,
      hocVi: json['hocVi'] as String?,
      chucDanh: json['chucDanh'] as String?,
      chuyenNganh: json['chuyenNganh'] as String?,
      cccd: json['cccd'] as String?,
      ngayCapCccd: json['ngayCapCccd'] != null
          ? DateTime.tryParse(json['ngayCapCccd'] as String)
          : null,
      noiCapCccd: json['noiCapCccd'] as String?,
      diaChiThuongTru: json['diaChiThuongTru'] as String?,
      tinhThanhPho: json['tinhThanhPho'] as String?,
      phuongXa: json['phuongXa'] as String?,
      danToc: json['danToc'] as String?,
      tonGiao: json['tonGiao'] as String?,
      quocTich: json['quocTich'] as String?,
      anhTheUrl: json['anhTheUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maGv': maGv,
      'hoTen': hoTen,
      'ngaySinh': ngaySinh?.toIso8601String(),
      'gioiTinh': gioiTinh,
      'email': email,
      'soDienThoai': soDienThoai,
      'khoa': khoa,
      'boMon': boMon,
      'hocVi': hocVi,
      'chucDanh': chucDanh,
      'chuyenNganh': chuyenNganh,
      'cccd': cccd,
      'ngayCapCccd': ngayCapCccd?.toIso8601String(),
      'noiCapCccd': noiCapCccd,
      'diaChiThuongTru': diaChiThuongTru,
      'tinhThanhPho': tinhThanhPho,
      'phuongXa': phuongXa,
      'danToc': danToc,
      'tonGiao': tonGiao,
      'quocTich': quocTich,
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
  });

  factory TeachingScheduleItem.fromJson(Map<String, dynamic> json) {
    return TeachingScheduleItem(
      maMon: json['maMon'] as String,
      tenMon: json['tenMon'] as String,
      nhom: json['nhom'] as String?,
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
      soTiet: json['soTiet'] as int?,
      siSo: json['siSo'] as int?,
    );
  }
}
