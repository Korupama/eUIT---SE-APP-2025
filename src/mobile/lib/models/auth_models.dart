class LoginRequest {
  final String userId;
  final String password;
  final String role;

  LoginRequest({
    required this.userId,
    required this.password,
    this.role = 'student',
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'password': password,
    'role': role,
  };
}

class LoginResponse {
  final String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(token: json['token'] as String);
  }
}

class StudentProfile {
  final int mssv;
  final String hoTen;
  final DateTime? ngaySinh;
  final String? nganhHoc;
  final int? khoaHoc;
  final String? lopSinhHoat;
  final String? noiSinh;
  final String? cccd;
  final DateTime? ngayCapCccd;
  final String? noiCapCccd;
  final String? danToc;
  final String? tonGiao;
  final String? soDienThoai;
  final String? diaChiThuongTru;
  final String? tinhThanhPho;
  final String? phuongXa;
  final String? quaTrinhHocTapCongTac;
  final String? thanhTich;
  final String? emailCaNhan;
  final String? maNganHang;
  final String? tenNganHang;
  final String? soTaiKhoan;
  final String? chiNhanh;
  final String? hoTenCha;
  final String? quocTichCha;
  final String? danTocCha;
  final String? tonGiaoCha;
  final String? sdtCha;
  final String? emailCha;
  final String? diaChiThuongTruCha;
  final String? congViecCha;
  final String? hoTenMe;
  final String? quocTichMe;
  final String? danTocMe;
  final String? tonGiaoMe;
  final String? sdtMe;
  final String? emailMe;
  final String? diaChiThuongTruMe;
  final String? congViecMe;
  final String? hoTenNgh;
  final String? quocTichNgh;
  final String? danTocNgh;
  final String? tonGiaoNgh;
  final String? sdtNgh;
  final String? emailNgh;
  final String? diaChiThuongTruNgh;
  final String? congViecNgh;
  final String? thongTinNguoiCanBaoTin;
  final String? soDienThoaiBaoTin;
  final String? anhTheUrl;

  StudentProfile({
    required this.mssv,
    required this.hoTen,
    this.ngaySinh,
    this.nganhHoc,
    this.khoaHoc,
    this.lopSinhHoat,
    this.noiSinh,
    this.cccd,
    this.ngayCapCccd,
    this.noiCapCccd,
    this.danToc,
    this.tonGiao,
    this.soDienThoai,
    this.diaChiThuongTru,
    this.tinhThanhPho,
    this.phuongXa,
    this.quaTrinhHocTapCongTac,
    this.thanhTich,
    this.emailCaNhan,
    this.maNganHang,
    this.tenNganHang,
    this.soTaiKhoan,
    this.chiNhanh,
    this.hoTenCha,
    this.quocTichCha,
    this.danTocCha,
    this.tonGiaoCha,
    this.sdtCha,
    this.emailCha,
    this.diaChiThuongTruCha,
    this.congViecCha,
    this.hoTenMe,
    this.quocTichMe,
    this.danTocMe,
    this.tonGiaoMe,
    this.sdtMe,
    this.emailMe,
    this.diaChiThuongTruMe,
    this.congViecMe,
    this.hoTenNgh,
    this.quocTichNgh,
    this.danTocNgh,
    this.tonGiaoNgh,
    this.sdtNgh,
    this.emailNgh,
    this.diaChiThuongTruNgh,
    this.congViecNgh,
    this.thongTinNguoiCanBaoTin,
    this.soDienThoaiBaoTin,
    this.anhTheUrl,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      mssv: json['mssv'] as int,
      hoTen: json['hoTen'] as String,
      ngaySinh: json['ngaySinh'] != null
          ? DateTime.tryParse(json['ngaySinh'] as String)
          : null,
      nganhHoc: json['nganhHoc'] as String?,
      khoaHoc: json['khoaHoc'] as int?,
      lopSinhHoat: json['lopSinhHoat'] as String?,
      noiSinh: json['noiSinh'] as String?,
      cccd: json['cccd'] as String?,
      ngayCapCccd: json['ngayCapCccd'] != null
          ? DateTime.tryParse(json['ngayCapCccd'] as String)
          : null,
      noiCapCccd: json['noiCapCccd'] as String?,
      danToc: json['danToc'] as String?,
      tonGiao: json['tonGiao'] as String?,
      soDienThoai: json['soDienThoai'] as String?,
      diaChiThuongTru: json['diaChiThuongTru'] as String?,
      tinhThanhPho: json['tinhThanhPho'] as String?,
      phuongXa: json['phuongXa'] as String?,
      quaTrinhHocTapCongTac: json['quaTrinhHocTapCongTac'] as String?,
      thanhTich: json['thanhTich'] as String?,
      emailCaNhan: json['emailCaNhan'] as String?,
      maNganHang: json['maNganHang'] as String?,
      tenNganHang: json['tenNganHang'] as String?,
      soTaiKhoan: json['soTaiKhoan'] as String?,
      chiNhanh: json['chiNhanh'] as String?,
      hoTenCha: json['hoTenCha'] as String?,
      quocTichCha: json['quocTichCha'] as String?,
      danTocCha: json['danTocCha'] as String?,
      tonGiaoCha: json['tonGiaoCha'] as String?,
      sdtCha: json['sdtCha'] as String?,
      emailCha: json['emailCha'] as String?,
      diaChiThuongTruCha: json['diaChiThuongTruCha'] as String?,
      congViecCha: json['congViecCha'] as String?,
      hoTenMe: json['hoTenMe'] as String?,
      quocTichMe: json['quocTichMe'] as String?,
      danTocMe: json['danTocMe'] as String?,
      tonGiaoMe: json['tonGiaoMe'] as String?,
      sdtMe: json['sdtMe'] as String?,
      emailMe: json['emailMe'] as String?,
      diaChiThuongTruMe: json['diaChiThuongTruMe'] as String?,
      congViecMe: json['congViecMe'] as String?,
      hoTenNgh: json['hoTenNgh'] as String?,
      quocTichNgh: json['quocTichNgh'] as String?,
      danTocNgh: json['danTocNgh'] as String?,
      tonGiaoNgh: json['tonGiaoNgh'] as String?,
      sdtNgh: json['sdtNgh'] as String?,
      emailNgh: json['emailNgh'] as String?,
      diaChiThuongTruNgh: json['diaChiThuongTruNgh'] as String?,
      congViecNgh: json['congViecNgh'] as String?,
      thongTinNguoiCanBaoTin: json['thongTinNguoiCanBaoTin'] as String?,
      soDienThoaiBaoTin: json['soDienThoaiBaoTin'] as String?,
      anhTheUrl: json['anhTheUrl'] as String?,
    );
  }
}
