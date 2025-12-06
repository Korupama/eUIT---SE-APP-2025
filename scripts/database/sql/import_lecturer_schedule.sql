-- Import lịch giảng cho giảng viên từ file kq_dkhp_with_gv.csv
-- File này chứa data năm học 2025-2026 HK1

-- Lưu ý: File CSV dùng delimiter ';' (semicolon)

-- Xóa dữ liệu cũ trong thoi_khoa_bieu (optional - bỏ comment nếu muốn xóa hết)
-- TRUNCATE TABLE thoi_khoa_bieu CASCADE;

-- Import dữ liệu từ file kq_dkhp_with_gv.csv
-- Path Windows: Sử dụng absolute path với forward slashes
COPY thoi_khoa_bieu (
    hoc_ky,
    ma_mon_hoc,
    ma_lop,
    so_tin_chi,
    ma_giang_vien,
    thu,
    tiet_bat_dau,
    tiet_ket_thuc,
    cach_tuan,
    ngay_bat_dau,
    ngay_ket_thuc,
    phong_hoc,
    si_so,
    hinh_thuc_giang_day,
    ghi_chu
)
FROM 'D:/eUIT---SE-APP-2025/scripts/database/main_data/kq_dkhp_with_gv.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';',
    ENCODING 'UTF8'
);

-- Kiểm tra kết quả
SELECT COUNT(*) as total_records FROM thoi_khoa_bieu;

SELECT hoc_ky, COUNT(*) as records_per_semester 
FROM thoi_khoa_bieu 
GROUP BY hoc_ky 
ORDER BY hoc_ky;

-- Kiểm tra lịch của giảng viên 80068
SELECT 
    hoc_ky,
    ma_mon_hoc,
    ma_lop,
    thu,
    tiet_bat_dau,
    tiet_ket_thuc,
    phong_hoc,
    ngay_bat_dau,
    ngay_ket_thuc
FROM thoi_khoa_bieu
WHERE ma_giang_vien = '80068'
ORDER BY thu, tiet_bat_dau;

-- Test function
SELECT * FROM func_get_lecturer_schedule(
    '80068',
    '',
    '2025-08-01'::timestamp,
    '2026-07-31'::timestamp
);
