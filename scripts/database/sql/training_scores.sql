-- Function to get student training scores
-- Returns aggregated training scores by semester (excluding semester 3)
-- Calculates semester from activity date
CREATE OR REPLACE FUNCTION func_get_student_training_scores(
    p_mssv INT
)
RETURNS TABLE (
    hoc_ky VARCHAR(20),
    tong_diem INT,
    xep_loai VARCHAR(50),
    tinh_trang VARCHAR(50)
)
LANGUAGE sql
AS $$
    SELECT 
        -- Calculate semester from activity date
        -- Semester 1: Aug-Dec, Semester 2: Jan-May (merge semester 3 into semester 2)
        CASE 
            WHEN EXTRACT(MONTH FROM hdrl.ngay_bat_dau) >= 8 
            THEN EXTRACT(YEAR FROM hdrl.ngay_bat_dau)::text || '_' || (EXTRACT(YEAR FROM hdrl.ngay_bat_dau) + 1)::text || '_1'
            ELSE (EXTRACT(YEAR FROM hdrl.ngay_bat_dau) - 1)::text || '_' || EXTRACT(YEAR FROM hdrl.ngay_bat_dau)::text || '_2'
        END AS hoc_ky,
        SUM(ct.diem * ct.he_so_tham_gia) AS tong_diem,
        CASE 
            WHEN SUM(ct.diem * ct.he_so_tham_gia) >= 90 THEN 'Xuất sắc'
            WHEN SUM(ct.diem * ct.he_so_tham_gia) >= 80 THEN 'Giỏi'
            WHEN SUM(ct.diem * ct.he_so_tham_gia) >= 70 THEN 'Khá'
            WHEN SUM(ct.diem * ct.he_so_tham_gia) >= 60 THEN 'Trung bình khá'
            ELSE 'Trung bình'
        END AS xep_loai,
        'Đã xác nhận' AS tinh_trang
    FROM chi_tiet_hoat_dong_ren_luyen AS ct
    JOIN hoat_dong_ren_luyen AS hdrl ON ct.ma_hoat_dong = hdrl.ma_hoat_dong
    WHERE ct.mssv = p_mssv
    GROUP BY 
        CASE 
            WHEN EXTRACT(MONTH FROM hdrl.ngay_bat_dau) >= 8 
            THEN EXTRACT(YEAR FROM hdrl.ngay_bat_dau)::text || '_' || (EXTRACT(YEAR FROM hdrl.ngay_bat_dau) + 1)::text || '_1'
            ELSE (EXTRACT(YEAR FROM hdrl.ngay_bat_dau) - 1)::text || '_' || EXTRACT(YEAR FROM hdrl.ngay_bat_dau)::text || '_2'
        END
    ORDER BY hoc_ky DESC;
$$;
