----------------------------------------------------------------------------------------------------
-- FIX: func_get_lecturer_courses - Allow empty semester to return all classes
-- Issue: When semester is empty, no classes are returned
-- Solution: Change WHERE clause to allow empty semester parameter
----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION func_get_lecturer_courses(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR,
    ma_lop CHAR(20),
    so_tin_chi INTEGER,
    si_so INTEGER,
    phong_hoc VARCHAR(10),
    hinh_thuc_giang_day CHAR(5)
) AS $$
BEGIN
RETURN QUERY
SELECT
    t.hoc_ky,
    t.ma_mon_hoc,
    m.ten_mon_hoc_vn,
    t.ma_lop,
    t.so_tin_chi,
    t.si_so,
    t.phong_hoc,
    t.hinh_thuc_giang_day
FROM thoi_khoa_bieu t
         JOIN mon_hoc m ON m.ma_mon_hoc = t.ma_mon_hoc
WHERE t.ma_giang_vien = p_ma_giang_vien
  AND (p_hoc_ky = '' OR t.hoc_ky = p_hoc_ky);
END;
$$ LANGUAGE plpgsql;
