-- =================================================================================
-- SQL FUNCTIONS FOR TRAINING SCORES (Điểm rèn luyện)
-- Mục đích: Hỗ trợ API tra cứu điểm rèn luyện của sinh viên
-- Xếp loại:
--   90+ = Xuất sắc
--   80-89 = Giỏi
--   70-79 = Khá
--   60-69 = Trung bình khá
--   < 60 = Trung bình
-- =================================================================================

-- ---------------------------------------------------------------------------------
-- Bước 1: Thêm cột hoc_ky vào bảng chi_tiet_hoat_dong_ren_luyen (nếu chưa có)
-- ---------------------------------------------------------------------------------
-- Chạy câu lệnh này nếu chưa có cột hoc_ky:
-- ALTER TABLE chi_tiet_hoat_dong_ren_luyen ADD COLUMN hoc_ky CHAR(11) DEFAULT '2025_2026_1';

-- ---------------------------------------------------------------------------------
-- HÀM: Lấy điểm rèn luyện của sinh viên theo học kỳ
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_training_scores
-- Mục đích: Trả về điểm rèn luyện của sinh viên
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tra cứu
-- Trả về: Bảng chứa thông tin điểm rèn luyện theo từng học kỳ
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_training_scores(
    p_mssv INT
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    tong_diem INT,
    xep_loai VARCHAR(20),
    tinh_trang VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Kiểm tra xem cột hoc_ky có tồn tại không
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'chi_tiet_hoat_dong_ren_luyen' 
        AND column_name = 'hoc_ky'
    ) THEN
        -- Nếu có cột hoc_ky, sử dụng nó
        RETURN QUERY
        SELECT 
            cthdrl.hoc_ky,
            COALESCE(SUM(cthdrl.diem), 0)::INT as tong_diem,
            CASE 
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 90 THEN 'Xuất sắc'
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 80 THEN 'Giỏi'
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 70 THEN 'Khá'
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 60 THEN 'Trung bình khá'
                ELSE 'Trung bình'
            END as xep_loai,
            'Đã xác nhận' as tinh_trang
        FROM 
            chi_tiet_hoat_dong_ren_luyen cthdrl
        WHERE 
            cthdrl.mssv = p_mssv
        GROUP BY 
            cthdrl.hoc_ky
        ORDER BY 
            cthdrl.hoc_ky DESC;
    ELSE
        -- Nếu chưa có cột hoc_ky, trả về dữ liệu mẫu hoặc tính toán dựa trên năm hiện tại
        RETURN QUERY
        SELECT 
            '2025_2026_1'::CHAR(11) as hoc_ky,
            COALESCE(SUM(cthdrl.diem), 0)::INT as tong_diem,
            CASE 
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 90 THEN 'Xuất sắc'
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 80 THEN 'Giỏi'
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 70 THEN 'Khá'
                WHEN COALESCE(SUM(cthdrl.diem), 0) >= 60 THEN 'Trung bình khá'
                ELSE 'Trung bình'
            END as xep_loai,
            'Đã xác nhận' as tinh_trang
        FROM 
            chi_tiet_hoat_dong_ren_luyen cthdrl
        WHERE 
            cthdrl.mssv = p_mssv;
    END IF;
END;
$$;

-- Ví dụ sử dụng:
-- SELECT * FROM func_get_student_training_scores(23520541);

-- ---------------------------------------------------------------------------------
-- Script để thêm dữ liệu mẫu điểm rèn luyện (nếu cần test)
-- ---------------------------------------------------------------------------------
-- Bạn có thể sử dụng script sau để thêm cột hoc_ky và dữ liệu mẫu:
/*
-- Thêm cột hoc_ky vào bảng
ALTER TABLE chi_tiet_hoat_dong_ren_luyen 
ADD COLUMN hoc_ky CHAR(11) DEFAULT '2025_2026_1';

-- Cập nhật dữ liệu có sẵn với học kỳ mặc định
UPDATE chi_tiet_hoat_dong_ren_luyen 
SET hoc_ky = '2025_2026_1' 
WHERE hoc_ky IS NULL;
*/
