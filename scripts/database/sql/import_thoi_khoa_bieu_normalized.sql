-- Import lịch giảng từ file normalized (2024-2025)
-- Chạy script này để update data lịch giảng mới nhất

-- Xóa dữ liệu cũ trong thoi_khoa_bieu
TRUNCATE TABLE thoi_khoa_bieu CASCADE;

-- Import dữ liệu mới từ file normalized
COPY thoi_khoa_bieu
FROM '/path/to/eUIT---SE-APP-2025/scripts/database/main_data/thoi_khoa_bieu_normalized.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Kiểm tra kết quả
SELECT COUNT(*) as total_records FROM thoi_khoa_bieu;
SELECT hoc_ky, COUNT(*) as records_per_semester 
FROM thoi_khoa_bieu 
GROUP BY hoc_ky 
ORDER BY hoc_ky;

-- Kiểm tra lịch của giảng viên 80068
SELECT * 
FROM thoi_khoa_bieu 
WHERE ma_giang_vien = '80068'
ORDER BY ngay_bat_dau, thu, tiet_bat_dau;
