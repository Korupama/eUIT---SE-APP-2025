namespace eUIT.API.DTOs;

public class StudentProfileDto
{
    // Thông tin cơ bản
    public int Mssv { get; set; }
    public string HoTen { get; set; } = string.Empty;
    public DateTime NgaySinh { get; set; }
    public string NganhHoc { get; set; } = string.Empty;
    public int KhoaHoc { get; set; }
    public string LopSinhHoat { get; set; } = string.Empty;

    // Thông tin cá nhân
    public string NoiSinh { get; set; } = string.Empty;
    public string Cccd { get; set; } = string.Empty;
    public DateTime NgayCapCccd { get; set; }
    public string NoiCapCccd { get; set; } = string.Empty;
    public string DanToc { get; set; } = string.Empty;
    public string TonGiao { get; set; } = string.Empty;
    public string SoDienThoai { get; set; } = string.Empty;
    public string DiaChiThuongTru { get; set; } = string.Empty;
    public string TinhThanhPho { get; set; } = string.Empty;
    public string PhuongXa { get; set; } = string.Empty;
    public string QuaTrinhHocTapCongTac { get; set; } = string.Empty;
    public string ThanhTich { get; set; } = string.Empty;
    public string EmailCaNhan { get; set; } = string.Empty;

    // Thông tin ngân hàng
    public string? MaNganHang { get; set; }
    public string? TenNganHang { get; set; }
    public string? SoTaiKhoan { get; set; }
    public string? ChiNhanh { get; set; }

    // Thông tin phụ huynh - Cha
    public string? HoTenCha { get; set; }
    public string? QuocTichCha { get; set; }
    public string? DanTocCha { get; set; }
    public string? TonGiaoCha { get; set; }
    public string? SdtCha { get; set; }
    public string? EmailCha { get; set; }
    public string? DiaChiThuongTruCha { get; set; }
    public string? CongViecCha { get; set; }

    // Thông tin phụ huynh - Mẹ
    public string? HoTenMe { get; set; }
    public string? QuocTichMe { get; set; }
    public string? DanTocMe { get; set; }
    public string? TonGiaoMe { get; set; }
    public string? SdtMe { get; set; }
    public string? EmailMe { get; set; }
    public string? DiaChiThuongTruMe { get; set; }
    public string? CongViecMe { get; set; }

    // Thông tin người giám hộ
    public string? HoTenNgh { get; set; }
    public string? QuocTichNgh { get; set; }
    public string? DanTocNgh { get; set; }
    public string? TonGiaoNgh { get; set; }
    public string? SdtNgh { get; set; }
    public string? EmailNgh { get; set; }
    public string? DiaChiThuongTruNgh { get; set; }
    public string? CongViecNgh { get; set; }

    // Liên hệ khẩn cấp
    public string ThongTinNguoiCanBaoTin { get; set; } = string.Empty;
    public string SoDienThoaiBaoTin { get; set; } = string.Empty;
    public string? AnhTheUrl { get; set; }
}
