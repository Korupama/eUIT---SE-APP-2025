using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eUIT.API.Models;

[Table("sinh_vien")]
public class SinhVien
{
    [Key]
    [Column("mssv")]
    public int Mssv { get; set; }

    [Column("ho_ten")]
    [Required]
    [MaxLength(50)]
    public string HoTen { get; set; } = string.Empty;

    [Column("ngay_sinh")]
    [Required]
    public DateTime NgaySinh { get; set; }

    [Column("nganh_hoc")]
    [Required]
    [MaxLength(100)]
    public string NganhHoc { get; set; } = string.Empty;

    [Column("khoa_hoc")]
    [Required]
    public int KhoaHoc { get; set; }

    [Column("lop_sinh_hoat")]
    [Required]
    [MaxLength(10)]
    public string LopSinhHoat { get; set; } = string.Empty;

    [Column("noi_sinh")]
    [Required]
    [MaxLength(200)]
    public string NoiSinh { get; set; } = string.Empty;

    [Column("cccd")]
    [Required]
    [MaxLength(12)]
    public string Cccd { get; set; } = string.Empty;

    [Column("ngay_cap_cccd")]
    [Required]
    public DateTime NgayCapCccd { get; set; }

    [Column("noi_cap_cccd")]
    [Required]
    [MaxLength(50)]
    public string NoiCapCccd { get; set; } = string.Empty;

    [Column("dan_toc")]
    [Required]
    [MaxLength(10)]
    public string DanToc { get; set; } = string.Empty;

    [Column("ton_giao")]
    [Required]
    [MaxLength(20)]
    public string TonGiao { get; set; } = string.Empty;

    [Column("so_dien_thoai")]
    [Required]
    [MaxLength(10)]
    public string SoDienThoai { get; set; } = string.Empty;

    [Column("dia_chi_thuong_tru")]
    [Required]
    [MaxLength(200)]
    public string DiaChiThuongTru { get; set; } = string.Empty;

    [Column("tinh_thanh_pho")]
    [Required]
    [MaxLength(20)]
    public string TinhThanhPho { get; set; } = string.Empty;

    [Column("phuong_xa")]
    [Required]
    public string PhuongXa { get; set; } = string.Empty;

    [Column("qua_trinh_hoc_tap_cong_tac")]
    [Required]
    [MaxLength(500)]
    public string QuaTrinhHocTapCongTac { get; set; } = string.Empty;

    [Column("thanh_tich")]
    [Required]
    [MaxLength(500)]
    public string ThanhTich { get; set; } = string.Empty;

    [Column("email_ca_nhan")]
    [Required]
    [MaxLength(50)]
    public string EmailCaNhan { get; set; } = string.Empty;

    // Thông tin ngân hàng
    [Column("ma_ngan_hang")]
    [MaxLength(4)]
    public string? MaNganHang { get; set; }

    [Column("ten_ngan_hang")]
    [MaxLength(20)]
    public string? TenNganHang { get; set; }

    [Column("so_tai_khoan")]
    [MaxLength(20)]
    public string? SoTaiKhoan { get; set; }

    [Column("chi_nhanh")]
    [MaxLength(50)]
    public string? ChiNhanh { get; set; }

    // Thông tin phụ huynh - Cha
    [Column("ho_ten_cha")]
    [MaxLength(50)]
    public string? HoTenCha { get; set; }

    [Column("quoc_tich_cha")]
    [MaxLength(20)]
    public string? QuocTichCha { get; set; }

    [Column("dan_toc_cha")]
    [MaxLength(10)]
    public string? DanTocCha { get; set; }

    [Column("ton_giao_cha")]
    [MaxLength(20)]
    public string? TonGiaoCha { get; set; }

    [Column("sdt_cha")]
    [MaxLength(10)]
    public string? SdtCha { get; set; }

    [Column("email_cha")]
    [MaxLength(50)]
    public string? EmailCha { get; set; }

    [Column("dia_chi_thuong_tru_cha")]
    [MaxLength(200)]
    public string? DiaChiThuongTruCha { get; set; }

    [Column("cong_viec_cha")]
    [MaxLength(20)]
    public string? CongViecCha { get; set; }

    // Thông tin phụ huynh - Mẹ
    [Column("ho_ten_me")]
    [MaxLength(50)]
    public string? HoTenMe { get; set; }

    [Column("quoc_tich_me")]
    [MaxLength(20)]
    public string? QuocTichMe { get; set; }

    [Column("dan_toc_me")]
    [MaxLength(10)]
    public string? DanTocMe { get; set; }

    [Column("ton_giao_me")]
    [MaxLength(20)]
    public string? TonGiaoMe { get; set; }

    [Column("sdt_me")]
    [MaxLength(10)]
    public string? SdtMe { get; set; }

    [Column("email_me")]
    [MaxLength(50)]
    public string? EmailMe { get; set; }

    [Column("dia_chi_thuong_tru_me")]
    [MaxLength(200)]
    public string? DiaChiThuongTruMe { get; set; }

    [Column("cong_viec_me")]
    [MaxLength(20)]
    public string? CongViecMe { get; set; }

    // Thông tin người giám hộ
    [Column("ho_ten_ngh")]
    [MaxLength(50)]
    public string? HoTenNgh { get; set; }

    [Column("quoc_tich_ngh")]
    [MaxLength(20)]
    public string? QuocTichNgh { get; set; }

    [Column("dan_toc_ngh")]
    [MaxLength(10)]
    public string? DanTocNgh { get; set; }

    [Column("ton_giao_ngh")]
    [MaxLength(20)]
    public string? TonGiaoNgh { get; set; }

    [Column("sdt_ngh")]
    [MaxLength(10)]
    public string? SdtNgh { get; set; }

    [Column("email_ngh")]
    [MaxLength(50)]
    public string? EmailNgh { get; set; }

    [Column("dia_chi_thuong_tru_ngh")]
    [MaxLength(200)]
    public string? DiaChiThuongTruNgh { get; set; }

    [Column("cong_viec_ngh")]
    [MaxLength(20)]
    public string? CongViecNgh { get; set; }

    // Liên hệ khẩn cấp
    [Column("thong_tin_nguoi_can_bao_tin")]
    [Required]
    [MaxLength(200)]
    public string ThongTinNguoiCanBaoTin { get; set; } = string.Empty;

    [Column("so_dien_thoai_bao_tin")]
    [Required]
    [MaxLength(10)]
    public string SoDienThoaiBaoTin { get; set; } = string.Empty;

    [Column("anh_the_url")]
    [MaxLength(255)]
    public string? AnhTheUrl { get; set; }
}
