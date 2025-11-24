-- =================================================================================
-- FUNCTIONS: Detailed transcript with component scores & weightings
-- =================================================================================
-- Returns each subject a student has taken including weight percentages and component scores.
-- This avoids N+1 queries by using LATERAL calls to existing func_get_student_subject_grade.
-- =================================================================================

-- Full transcript with details
CREATE OR REPLACE FUNCTION func_get_student_full_transcript_details(
    p_mssv INT
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    so_tin_chi INT,
    trong_so_qua_trinh INT,
    trong_so_giua_ki INT,
    trong_so_thuc_hanh INT,
    trong_so_cuoi_ki INT,
    diem_qua_trinh NUMERIC(4,2),
    diem_giua_ki NUMERIC(4,2),
    diem_thuc_hanh NUMERIC(4,2),
    diem_cuoi_ki NUMERIC(4,2),
    diem_tong_ket NUMERIC(4,2)
)
LANGUAGE sql
AS $$
WITH CacLopGocDaHoc AS (
    SELECT DISTINCT ma_lop_goc FROM ket_qua_hoc_tap WHERE mssv = p_mssv
)
SELECT
    tkb.hoc_ky,
    tkb.ma_mon_hoc,
    mh.ten_mon_hoc_vn,
    tkb.so_tin_chi,
    dtk.trong_so_qua_trinh,
    dtk.trong_so_giua_ki,
    dtk.trong_so_thuc_hanh,
    dtk.trong_so_cuoi_ki,
    dtk.diem_qua_trinh,
    dtk.diem_giua_ki,
    dtk.diem_thuc_hanh,
    dtk.diem_cuoi_ki,
    dtk.diem_tong_ket
FROM CacLopGocDaHoc AS clg
JOIN thoi_khoa_bieu AS tkb ON clg.ma_lop_goc = tkb.ma_lop
JOIN mon_hoc AS mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
JOIN LATERAL func_get_student_subject_grade(p_mssv, clg.ma_lop_goc) AS dtk ON TRUE
ORDER BY tkb.hoc_ky, tkb.ma_mon_hoc;
$$;

-- Semester transcript with details
CREATE OR REPLACE FUNCTION func_get_student_semester_transcript_details(
    p_mssv INT,
    p_hoc_ky CHAR(11)
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    so_tin_chi INT,
    trong_so_qua_trinh INT,
    trong_so_giua_ki INT,
    trong_so_thuc_hanh INT,
    trong_so_cuoi_ki INT,
    diem_qua_trinh NUMERIC(4,2),
    diem_giua_ki NUMERIC(4,2),
    diem_thuc_hanh NUMERIC(4,2),
    diem_cuoi_ki NUMERIC(4,2),
    diem_tong_ket NUMERIC(4,2)
)
LANGUAGE sql
AS $$
WITH CacLopGocTrongKy AS (
    SELECT DISTINCT kqht.ma_lop_goc
    FROM ket_qua_hoc_tap AS kqht
    JOIN thoi_khoa_bieu AS tkb ON kqht.ma_lop = tkb.ma_lop
    WHERE kqht.mssv = p_mssv AND tkb.hoc_ky = p_hoc_ky
)
SELECT
    tkb.hoc_ky,
    tkb.ma_mon_hoc,
    mh.ten_mon_hoc_vn,
    tkb.so_tin_chi,
    dtk.trong_so_qua_trinh,
    dtk.trong_so_giua_ki,
    dtk.trong_so_thuc_hanh,
    dtk.trong_so_cuoi_ki,
    dtk.diem_qua_trinh,
    dtk.diem_giua_ki,
    dtk.diem_thuc_hanh,
    dtk.diem_cuoi_ki,
    dtk.diem_tong_ket
FROM CacLopGocTrongKy AS clgtk
JOIN thoi_khoa_bieu AS tkb ON clgtk.ma_lop_goc = tkb.ma_lop
JOIN mon_hoc AS mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
JOIN LATERAL func_get_student_subject_grade(p_mssv, clgtk.ma_lop_goc) AS dtk ON TRUE
ORDER BY tkb.ma_mon_hoc;
$$;

-- Example usage:
-- SELECT * FROM func_get_student_full_transcript_details(23520541);
-- SELECT * FROM func_get_student_semester_transcript_details(23520541, '2025_2026_1');
