-- Import lịch giảng và danh sách lớp
-- File kq_dkhp_with_gv.csv chứa data năm học 2025-2026

-- Xóa dữ liệu cũ trong thoi_khoa_bieu
TRUNCATE TABLE thoi_khoa_bieu CASCADE;

-- Import dữ liệu từ file kq_dkhp_with_gv.csv
-- Lưu ý: File này dùng delimiter ';' (semicolon)
COPY thoi_khoa_bieu
FROM '/path/to/eUIT---SE-APP-2025/scripts/database/main_data/kq_dkhp_with_gv.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

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
    si_so,
    ngay_bat_dau,
    ngay_ket_thuc
FROM thoi_khoa_bieu 
WHERE ma_giang_vien = '80068'
ORDER BY ngay_bat_dau, thu, tiet_bat_dau;
