using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.DTOs;

// ========================================
// PROFILE DTOs - Based on giang_vien table
// ========================================

public sealed record LecturerProfileDto
{
    [Column("ma_giang_vien")] public string MaGiangVien { get; init; } = "";
    [Column("ho_ten")] public string HoTen { get; init; } = "";
    [Column("khoa_bo_mon")] public string? KhoaBoMon { get; init; }
    [Column("ngay_sinh")] public DateTime? NgaySinh { get; init; }
    [Column("noi_sinh")] public string? NoiSinh { get; init; }
    [Column("cccd")] public string? Cccd { get; init; }
    [Column("ngay_cap_cccd")] public DateTime? NgayCapCccd { get; init; }
    [Column("noi_cap_cccd")] public string? NoiCapCccd { get; init; }
    [Column("dan_toc")] public string? DanToc { get; init; }
    [Column("ton_giao")] public string? TonGiao { get; init; }
    [Column("so_dien_thoai")] public string? SoDienThoai { get; init; }
    [Column("dia_chi_thuong_tru")] public string? DiaChiThuongTru { get; init; }
    [Column("tinh_thanh_pho")] public string? TinhThanhPho { get; init; }
    [Column("phuong_xa")] public string? PhuongXa { get; init; }
}

public sealed record UpdateLecturerProfileDto
{
    public string? Phone { get; init; }
    public string? Address { get; init; }
}

// ========================================
// COURSE DTOs - Based on thoi_khoa_bieu table
// ========================================

public sealed record LecturerCourseDto
{
    [Column("hoc_ky")] public string? HocKy { get; init; }
    [Column("ma_mon_hoc")] public string? MaMonHoc { get; init; }
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("so_tin_chi")] public int? SoTinChi { get; init; }
    [Column("si_so")] public int? SiSo { get; init; }
    [Column("phong_hoc")] public string? PhongHoc { get; init; }
    [Column("hinh_thuc_giang_day")] public string? HinhThucGiangDay { get; init; }
}

public sealed record LecturerCourseDetailDto
{
    [Column("hoc_ky")] public string? HocKy { get; init; }
    [Column("ma_mon_hoc")] public string? MaMonHoc { get; init; }
    [Column("ten_mon_hoc_vn")] public string? TenMonHocVn { get; init; }
    [Column("ten_mon_hoc_en")] public string? TenMonHocEn { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("so_tin_chi")] public int? SoTinChi { get; init; }
    [Column("si_so")] public int? SiSo { get; init; }
    [Column("phong_hoc")] public string? PhongHoc { get; init; }
    [Column("thu")] public string? Thu { get; init; }
    [Column("tiet_bat_dau")] public int? TietBatDau { get; init; }
    [Column("tiet_ket_thuc")] public int? TietKetThuc { get; init; }
    [Column("cach_tuan")] public int? CachTuan { get; init; }
    [Column("ngay_bat_dau")] public DateTime? NgayBatDau { get; init; }
    [Column("ngay_ket_thuc")] public DateTime? NgayKetThuc { get; init; }
    [Column("hinh_thuc_giang_day")] public string? HinhThucGiangDay { get; init; }
    [Column("ghi_chu")] public string? GhiChu { get; init; }
}

public sealed record LecturerScheduleDto
{
    [Column("hoc_ky")] public string? HocKy { get; init; }
    [Column("ma_mon_hoc")] public string? MaMonHoc { get; init; }
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("thu")] public string? Thu { get; init; }
    [Column("tiet_bat_dau")] public int? TietBatDau { get; init; }
    [Column("tiet_ket_thuc")] public int? TietKetThuc { get; init; }
    [Column("phong_hoc")] public string? PhongHoc { get; init; }
    [Column("ngay_bat_dau")] public DateTime? NgayBatDau { get; init; }
    [Column("ngay_ket_thuc")] public DateTime? NgayKetThuc { get; init; }
    [Column("cach_tuan")] public int? CachTuan { get; init; }
    [Column("hinh_thuc_giang_day")] public string? HinhThucGiangDay { get; init; }
}

// ========================================
// GRADE MANAGEMENT DTOs - Based on ket_qua_hoc_tap + bang_diem tables
// ========================================

public sealed record LecturerGradeViewDto
{
    [Column("mssv")] public int Mssv { get; init; }
    [Column("ho_ten")] public string? HoTen { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("ma_lop_goc")] public string? MaLopGoc { get; init; }
    [Column("diem_qua_trinh")] public decimal? DiemQuaTrinh { get; init; }
    [Column("diem_giua_ki")] public decimal? DiemGiuaKi { get; init; }
    [Column("diem_thuc_hanh")] public decimal? DiemThucHanh { get; init; }
    [Column("diem_cuoi_ki")] public decimal? DiemCuoiKi { get; init; }
    [Column("diem_tong_ket")] public decimal? DiemTongKet { get; init; }
    [Column("diem_chu")] public string? DiemChu { get; init; }
    [Column("ghi_chu")] public string? GhiChu { get; init; }
}


public sealed record StudentGradeDetailDto
{
    [Column("mssv")] public int Mssv { get; init; }
    [Column("ho_ten")] public string? HoTen { get; init; }
    [Column("ma_mon_hoc")] public string? MaMonHoc { get; init; }
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("ma_lop_goc")] public string? MaLopGoc { get; init; }
    [Column("diem_qua_trinh")] public decimal? DiemQuaTrinh { get; init; }
    [Column("diem_giua_ki")] public decimal? DiemGiuaKi { get; init; }
    [Column("diem_thuc_hanh")] public decimal? DiemThucHanh { get; init; }
    [Column("diem_cuoi_ki")] public decimal? DiemCuoiKi { get; init; }
    [Column("diem_tong_ket")] public decimal? DiemTongKet { get; init; }
    [Column("diem_chu")] public string? DiemChu { get; init; }
    [Column("ghi_chu")] public string? GhiChu { get; init; }
    [Column("trong_so_qua_trinh")] public int? TrongSoQuaTrinh { get; init; }
    [Column("trong_so_giua_ki")] public int? TrongSoGiuaKi { get; init; }
    [Column("trong_so_thuc_hanh")] public int? TrongSoThucHanh { get; init; }
    [Column("trong_so_cuoi_ki")] public int? TrongSoCuoiKi { get; init; }
}

public sealed record LecturerUpdateGradeDto
{
    public string MaLop { get; init; } = "";
    public decimal? DiemQuaTrinh { get; init; }
    public decimal? DiemGiuaKy { get; init; }
    public decimal? DiemThucHanh { get; init; }
    public decimal? DiemCuoiKy { get; init; }
}

public sealed record UpdateGradeResultDto
{
    [Column("success")] public bool Success { get; init; }
    [Column("message")] public string? Message { get; init; }
    [Column("ma_mon_hoc")] public string? MaMonHoc { get; init; }
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("hoc_ky")] public string? HocKy { get; init; }
    [Column("diem_tong_ket")] public decimal? DiemTongKet { get; init; }
    [Column("diem_chu")] public string? DiemChu { get; init; }
}

// ========================================
// EXAM DTOs - Based on lich_thi + coi_thi tables
// ========================================

public sealed record LecturerExamDto
{
    [Column("ma_mon_hoc")] public string? MaMonHoc { get; init; }
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("ngay_thi")] public DateTime? NgayThi { get; init; }
    [Column("ca_thi")] public int? CaThi { get; init; }
    [Column("phong_thi")] public string? PhongThi { get; init; }
    [Column("hinh_thuc_thi")] public string? HinhThucThi { get; init; }
    [Column("gk_ck")] public string? GkCk { get; init; }
    [Column("si_so")] public int? SiSo { get; init; }
}

public sealed record LecturerExamDetailDto
{
    [Column("ma_mon_hoc")] public string? MaMonHoc { get; init; }
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("ngay_thi")] public DateTime? NgayThi { get; init; }
    [Column("ca_thi")] public int? CaThi { get; init; }
    [Column("phong_thi")] public string? PhongThi { get; init; }
    [Column("hinh_thuc_thi")] public string? HinhThucThi { get; init; }
    [Column("gk_ck")] public string? GkCk { get; init; }
    [Column("si_so")] public int? SiSo { get; init; }
    [Column("giam_thi_1")] public string? GiamThi1 { get; init; }
    [Column("giam_thi_2")] public string? GiamThi2 { get; init; }
}

public sealed record ExamStudentDto
{
    [Column("mssv")] public int Mssv { get; init; }
    [Column("ho_ten")] public string? HoTen { get; init; }
    [Column("lop_sinh_hoat")] public string? LopSinhHoat { get; init; }
    [Column("phong_thi")] public string? PhongThi { get; init; }
}

// ========================================
// ADMINISTRATIVE SERVICE DTOs - Based on confirmation_letters table
// ========================================

public sealed record LecturerConfirmationLetterDto
{
    public int Mssv { get; init; }
    public string? Purpose { get; init; }
}

public sealed record ConfirmationLetterResultDto
{
    [Column("serial_number")] public int SerialNumber { get; init; }
    [Column("expiry_date")] public DateTime? ExpiryDate { get; init; }
}

// ========================================
// TUITION DTOs - Based on hoc_phi table
// ========================================

public sealed record StudentTuitionDto
{
    [Column("mssv")] public int Mssv { get; init; }
    [Column("ho_ten")] public string? HoTen { get; init; }
    [Column("hoc_ky")] public string? HocKy { get; init; }
    [Column("so_tin_chi")] public int? SoTinChi { get; init; }
    [Column("hoc_phi")] public decimal? HocPhi { get; init; }
    [Column("no_hoc_ky_truoc")] public double? NoHocKyTruoc { get; init; }
    [Column("da_dong")] public double? DaDong { get; init; }
    [Column("so_tien_con_lai")] public double? SoTienConLai { get; init; }
    [Column("don_gia_tin_chi")] public int? DonGiaTinChi { get; init; }
}

// ========================================
// APPEAL DTOs - Based on appeals table
// ========================================

public sealed record LecturerAppealDto
{
    [Column("id")] public int Id { get; init; }
    [Column("mssv")] public int Mssv { get; init; }
    [Column("ho_ten")] public string? HoTen { get; init; }
    [Column("course_id")] public string? CourseId { get; init; }
    [Column("course_name")] public string? CourseName { get; init; }
    [Column("reason")] public string? Reason { get; init; }
    [Column("payment_method")] public string? PaymentMethod { get; init; }
    [Column("payment_status")] public string? PaymentStatus { get; init; }
    [Column("status")] public string? Status { get; init; }
    [Column("created_at")] public DateTime? CreatedAt { get; init; }
}

public sealed record LecturerAppealDetailDto
{
    [Column("id")] public int Id { get; init; }
    [Column("mssv")] public int Mssv { get; init; }
    [Column("ho_ten")] public string? HoTen { get; init; }
    [Column("course_id")] public string? CourseId { get; init; }
    [Column("course_name")] public string? CourseName { get; init; }
    [Column("reason")] public string? Reason { get; init; }
    [Column("payment_method")] public string? PaymentMethod { get; init; }
    [Column("payment_status")] public string? PaymentStatus { get; init; }
    [Column("status")] public string? Status { get; init; }
    [Column("created_at")] public DateTime? CreatedAt { get; init; }
    [Column("updated_at")] public DateTime? UpdatedAt { get; init; }
}

public sealed record ProcessAppealDto
{
    public string Status { get; init; } = "";
    public string? Comment { get; init; }
}

public sealed record AppealProcessResultDto
{
    [Column("success")] public bool Success { get; init; }
    [Column("message")] public string? Message { get; init; }
}

// ========================================
// NOTIFICATION DTOs - Based on thong_bao table
// ========================================

public sealed record NotificationDto
{
    [Column("id")] public int Id { get; init; }
    [Column("tieu_de")] public string? TieuDe { get; init; }
    [Column("noi_dung")] public string? NoiDung { get; init; }
    [Column("ngay_tao")] public DateTime? NgayTao { get; init; }
    [Column("ngay_cap_nhat")] public DateTime? NgayCapNhat { get; init; }
}

// ========================================
// ABSENCE & MAKEUP CLASS DTOs - Based on bao_nghi_day + bao_hoc_bu tables
// ========================================

public sealed record LecturerAbsenceDto
{
    public string MaLop { get; init; } = "";
    public DateTime NgayNghi { get; init; }
    public string? LyDo { get; init; }
}

public sealed record AbsenceResultDto
{
    [Column("success")] public bool Success { get; init; }
    [Column("message")] public string? Message { get; init; }
    [Column("absence_id")] public int AbsenceId { get; init; }
}

public sealed record LecturerMakeupClassDto
{
    public string MaLop { get; init; } = "";
    public DateTime NgayHocBu { get; init; }
    public int TietBatDau { get; init; }
    public int TietKetThuc { get; init; }
    public string? PhongHoc { get; init; }
    public string? LyDo { get; init; }
}


public sealed record MakeupClassResultDto
{
    [Column("success")] public bool Success { get; init; }
    [Column("message")] public string? Message { get; init; }
    [Column("makeup_id")] public int MakeupId { get; init; }
}

public sealed record LecturerAbsenceHistoryDto
{
    [Column("id")] public int Id { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("ngay_nghi")] public DateTime? NgayNghi { get; init; }
    [Column("ly_do")] public string? LyDo { get; init; }
    [Column("tinh_trang")] public string? TinhTrang { get; init; }
}

public sealed record LecturerMakeupClassHistoryDto
{
    [Column("id")] public int Id { get; init; }
    [Column("ma_lop")] public string MaLop { get; init; } = "";
    [Column("ten_mon_hoc")] public string? TenMonHoc { get; init; }
    [Column("ngay_hoc_bu")] public DateTime? NgayHocBu { get; init; }
    [Column("tiet_bat_dau")] public int? TietBatDau { get; init; }
    [Column("tiet_ket_thuc")] public int? TietKetThuc { get; init; }
    [Column("phong_hoc")] public string? PhongHoc { get; init; }
    [Column("ly_do")] public string? LyDo { get; init; }
    [Column("tinh_trang")] public string? TinhTrang { get; init; }
}
