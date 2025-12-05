----------------------------------------------------------------------------------------------------
-- 1. func_get_lecturer_profile
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_profile(p_ma_giang_vien TEXT)
RETURNS TABLE (
    ma_giang_vien CHAR(5),
    ho_ten VARCHAR,
    khoa_bo_mon CHAR(5),
    ngay_sinh DATE,
    noi_sinh VARCHAR(200),
    cccd CHAR(12),
    ngay_cap_cccd DATE,
    noi_cap_cccd VARCHAR(50),
    dan_toc VARCHAR(10),
    ton_giao VARCHAR(20),
    so_dien_thoai CHAR(10),
    dia_chi_thuong_tru VARCHAR(200),
    tinh_thanh_pho VARCHAR(20),
    phuong_xa TEXT
) AS $$
BEGIN
RETURN QUERY
SELECT
    gv.ma_giang_vien,
    gv.ho_ten,
    gv.khoa_bo_mon,
    gv.ngay_sinh,
    gv.noi_sinh,
    gv.cccd,
    gv.ngay_cap_cccd,
    gv.noi_cap_cccd,
    gv.dan_toc,
    gv.ton_giao,
    gv.so_dien_thoai,
    gv.dia_chi_thuong_tru,
    gv.tinh_thanh_pho,
    gv.phuong_xa
FROM giang_vien gv
WHERE gv.ma_giang_vien = p_ma_giang_vien;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 2. func_update_lecturer_profile
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_update_lecturer_profile(
    p_ma_giang_vien TEXT,
    p_so_dien_thoai TEXT,
    p_dia_chi_thuong_tru TEXT
)
RETURNS VOID AS $$
BEGIN
UPDATE giang_vien
SET
    so_dien_thoai = p_so_dien_thoai,
    dia_chi_thuong_tru = p_dia_chi_thuong_tru
WHERE ma_giang_vien = p_ma_giang_vien;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 3. func_get_lecturer_courses
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


----------------------------------------------------------------------------------------------------
-- 4. func_get_lecturer_course_detail
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_course_detail(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc_vn VARCHAR,
    ten_mon_hoc_en VARCHAR,
    ma_lop CHAR(20),
    so_tin_chi INTEGER,
    si_so INTEGER,
    phong_hoc VARCHAR(10),
    thu CHAR(2),
    tiet_bat_dau INTEGER,
    tiet_ket_thuc INTEGER,
    cach_tuan INTEGER,
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    hinh_thuc_giang_day CHAR(5),
    ghi_chu VARCHAR(255)
) AS $$
BEGIN
RETURN QUERY
SELECT
    t.hoc_ky,
    t.ma_mon_hoc,
    m.ten_mon_hoc_vn,
    m.ten_mon_hoc_en,
    t.ma_lop,
    t.so_tin_chi,
    t.si_so,
    t.phong_hoc,
    t.thu,
    t.tiet_bat_dau,
    t.tiet_ket_thuc,
    t.cach_tuan,
    t.ngay_bat_dau,
    t.ngay_ket_thuc,
    t.hinh_thuc_giang_day,
    t.ghi_chu
FROM thoi_khoa_bieu t
         JOIN mon_hoc m ON m.ma_mon_hoc = t.ma_mon_hoc
WHERE t.ma_giang_vien = p_ma_giang_vien
  AND t.ma_lop = p_ma_lop;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 5. func_get_lecturer_schedule
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_schedule(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT,
    p_start TEXT,
    p_end TEXT
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR,
    ma_lop CHAR(20),
    thu CHAR(2),
    tiet_bat_dau INTEGER,
    tiet_ket_thuc INTEGER,
    phong_hoc VARCHAR(10),
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    cach_tuan INTEGER,
    hinh_thuc_giang_day CHAR(5)
) AS $$
DECLARE
    v_current_year INT := EXTRACT(YEAR FROM CURRENT_DATE);
    v_prev_year INT := v_current_year - 1;

    v_hoc_ky_list TEXT[];
BEGIN
    -- If p_hoc_ky is empty → automatically find all semesters of
    -- previous year + current year
    IF p_hoc_ky = '' THEN
        v_hoc_ky_list := ARRAY[
            -- Niên khóa (prev_year_current_year)
            v_prev_year::TEXT || '_' || v_current_year::TEXT || '_1',
            v_prev_year::TEXT || '_' || v_current_year::TEXT || '_2',
            v_prev_year::TEXT || '_' || v_current_year::TEXT || '_3',

            -- Niên khóa (current_year_next_year)
            v_current_year::TEXT || '_' || (v_current_year + 1)::TEXT || '_1',
            v_current_year::TEXT || '_' || (v_current_year + 1)::TEXT || '_2',
            v_current_year::TEXT || '_' || (v_current_year + 1)::TEXT || '_3'
        ];
    ELSE
        -- If specific semester is provided → use only that one
        v_hoc_ky_list := ARRAY[p_hoc_ky];
    END IF;

    RETURN QUERY
        SELECT
            t.hoc_ky,
            t.ma_mon_hoc,
            m.ten_mon_hoc_vn,
            t.ma_lop,
            t.thu,
            t.tiet_bat_dau,
            t.tiet_ket_thuc,
            t.phong_hoc,
            t.ngay_bat_dau,
            t.ngay_ket_thuc,
            t.cach_tuan,
            t.hinh_thuc_giang_day
        FROM thoi_khoa_bieu t
        JOIN mon_hoc m ON m.ma_mon_hoc = t.ma_mon_hoc
        WHERE t.ma_giang_vien = p_ma_giang_vien
          AND t.hoc_ky = ANY(v_hoc_ky_list)

          -- p_start filter (overlap)
          AND (
                p_start = ''
                OR (t.ngay_bat_dau IS NULL OR t.ngay_ket_thuc IS NULL)
                OR (t.ngay_bat_dau <= (p_end::timestamptz)::date AND t.ngay_ket_thuc >= (p_start::timestamptz)::date)
              )

          -- p_end filter (already included in overlap)
          AND (
                p_end = ''
                OR t.ngay_ket_thuc IS NULL
                OR t.ngay_ket_thuc <= (p_end::timestamptz)::date
            )



        ORDER BY t.hoc_ky, t.thu, t.tiet_bat_dau;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 6. func_get_lecturer_class_grades
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_class_grades(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    ma_lop CHAR(20),
    ma_lop_goc CHAR(20),
    diem_qua_trinh NUMERIC,
    diem_giua_ki NUMERIC,
    diem_thuc_hanh NUMERIC,
    diem_cuoi_ki NUMERIC,
    diem_tong_ket NUMERIC,
    diem_chu VARCHAR(2),
    ghi_chu VARCHAR(20)
) AS $$
BEGIN
RETURN QUERY
SELECT
    k.mssv,
    s.ho_ten,
    k.ma_lop,
    k.ma_lop_goc,
    k.diem_qua_trinh,
    k.diem_giua_ki,
    k.diem_thuc_hanh,
    k.diem_cuoi_ki,
    (COALESCE(k.diem_qua_trinh,0) + COALESCE(k.diem_giua_ki,0) + COALESCE(k.diem_thuc_hanh,0) + COALESCE(k.diem_cuoi_ki,0)) AS diem_tong_ket,
    CAST(CASE
        WHEN (COALESCE(k.diem_qua_trinh,0) + COALESCE(k.diem_giua_ki,0) + COALESCE(k.diem_thuc_hanh,0) + COALESCE(k.diem_cuoi_ki,0)) >= 8 THEN 'A'
        WHEN (COALESCE(k.diem_qua_trinh,0) + COALESCE(k.diem_giua_ki,0) + COALESCE(k.diem_thuc_hanh,0) + COALESCE(k.diem_cuoi_ki,0)) >= 6.5 THEN 'B'
        WHEN (COALESCE(k.diem_qua_trinh,0) + COALESCE(k.diem_giua_ki,0) + COALESCE(k.diem_thuc_hanh,0) + COALESCE(k.diem_cuoi_ki,0)) >= 5 THEN 'C'
        WHEN (COALESCE(k.diem_qua_trinh,0) + COALESCE(k.diem_giua_ki,0) + COALESCE(k.diem_thuc_hanh,0) + COALESCE(k.diem_cuoi_ki,0)) >= 4 THEN 'D'
        ELSE 'F'
        END AS VARCHAR(2)) AS diem_chu,
    k.ghi_chu
FROM ket_qua_hoc_tap k
         JOIN sinh_vien s ON s.mssv = k.mssv
         JOIN thoi_khoa_bieu t ON t.ma_lop = k.ma_lop
WHERE t.ma_giang_vien = p_ma_giang_vien
  AND k.ma_lop = p_ma_lop;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 7. func_get_lecturer_student_grade
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_student_grade(
    p_ma_giang_vien TEXT,
    p_mssv INTEGER,
    p_ma_lop TEXT
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR,
    ma_lop CHAR(20),
    ma_lop_goc CHAR(20),
    diem_qua_trinh NUMERIC,
    diem_giua_ki NUMERIC,
    diem_thuc_hanh NUMERIC,
    diem_cuoi_ki NUMERIC,
    diem_tong_ket NUMERIC,
    diem_chu VARCHAR(2),
    ghi_chu VARCHAR(20),
    trong_so_qua_trinh INTEGER,
    trong_so_giua_ki INTEGER,
    trong_so_thuc_hanh INTEGER,
    trong_so_cuoi_ki INTEGER
) AS $$
BEGIN
RETURN QUERY
SELECT
    k.mssv,
    s.ho_ten,
    t.ma_mon_hoc,
    m.ten_mon_hoc_vn,
    k.ma_lop,
    k.ma_lop_goc,
    k.diem_qua_trinh,
    k.diem_giua_ki,
    k.diem_thuc_hanh,
    k.diem_cuoi_ki,
    (COALESCE(k.diem_qua_trinh,0)+COALESCE(k.diem_giua_ki,0)+COALESCE(k.diem_thuc_hanh,0)+COALESCE(k.diem_cuoi_ki,0)),
    CAST(NULL AS VARCHAR(2)),
    k.ghi_chu,
    b.trong_so_qua_trinh,
    b.trong_so_giua_ki,
    b.trong_so_thuc_hanh,
    b.trong_so_cuoi_ki
FROM ket_qua_hoc_tap k
         JOIN sinh_vien s ON s.mssv = k.mssv
         JOIN thoi_khoa_bieu t ON t.ma_lop = k.ma_lop
         JOIN mon_hoc m ON m.ma_mon_hoc = t.ma_mon_hoc
         JOIN bang_diem b ON b.ma_lop_goc = k.ma_lop_goc
WHERE t.ma_giang_vien = p_ma_giang_vien
  AND k.mssv = p_mssv
  AND k.ma_lop = p_ma_lop;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 8. func_lecturer_update_grade
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_lecturer_update_grade(
    p_ma_giang_vien TEXT,
    p_mssv INTEGER,
    p_ma_lop TEXT,
    p_diem_qua_trinh NUMERIC,
    p_diem_giua_ki NUMERIC,
    p_diem_thuc_hanh NUMERIC,
    p_diem_cuoi_ki NUMERIC
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR,
    hoc_ky CHAR(11),
    diem_tong_ket NUMERIC,
    diem_chu VARCHAR(2)
) AS $$
DECLARE
    v_ma_mon CHAR(8);
    v_ten_mon VARCHAR;
    v_hoc_ky CHAR(11);
    v_tong NUMERIC;
    v_chu VARCHAR(2);
BEGIN
    UPDATE ket_qua_hoc_tap
    SET
        diem_qua_trinh = p_diem_qua_trinh,
        diem_giua_ki = p_diem_giua_ki,
        diem_thuc_hanh = p_diem_thuc_hanh,
        diem_cuoi_ki = p_diem_cuoi_ki
    WHERE mssv = p_mssv
      AND ma_lop = p_ma_lop;

    SELECT t.ma_mon_hoc, m.ten_mon_hoc_vn, t.hoc_ky
    INTO v_ma_mon, v_ten_mon, v_hoc_ky
    FROM thoi_khoa_bieu t
             JOIN mon_hoc m ON m.ma_mon_hoc = t.ma_mon_hoc
    WHERE t.ma_lop = p_ma_lop;

    v_tong := COALESCE(p_diem_qua_trinh,0)+COALESCE(p_diem_giua_ki,0)+COALESCE(p_diem_thuc_hanh,0)+COALESCE(p_diem_cuoi_ki,0);

    v_chu := CASE
                 WHEN v_tong >= 8 THEN 'A'
                 WHEN v_tong >= 6.5 THEN 'B'
                 WHEN v_tong >= 5 THEN 'C'
                 WHEN v_tong >= 4 THEN 'D'
                 ELSE 'F'
        END;

    RETURN QUERY
        SELECT TRUE, 'OK'::TEXT, v_ma_mon, v_ten_mon, v_hoc_ky, v_tong, v_chu;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 9. func_get_lecturer_exams
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_exams(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT,
    p_exam_type TEXT
)
RETURNS TABLE (
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR,
    ma_lop CHAR(20),
    ngay_thi DATE,
    ca_thi INTEGER,
    phong_thi VARCHAR(10),
    hinh_thuc_thi VARCHAR,
    gk_ck CHAR(2),
    si_so INTEGER
) AS $$
BEGIN
RETURN QUERY
SELECT
    lt.ma_mon_hoc,
    m.ten_mon_hoc_vn,
    lt.ma_lop,
    lt.ngay_thi,
    lt.ca_thi,
    lt.phong_thi,
    lt.hinh_thuc_thi,
    lt.gk_ck,
    t.si_so
FROM lich_thi lt
         JOIN mon_hoc m ON m.ma_mon_hoc = lt.ma_mon_hoc
         JOIN thoi_khoa_bieu t ON t.ma_lop = lt.ma_lop
WHERE lt.ma_giang_vien = p_ma_giang_vien
  AND t.hoc_ky = p_hoc_ky;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- Remaining functions omitted due to output size limit.
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 10. func_get_lecturer_exam_detail
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_exam_detail(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR,
    ma_lop CHAR(20),
    ngay_thi DATE,
    ca_thi INTEGER,
    phong_thi VARCHAR(10),
    hinh_thuc_thi VARCHAR,
    gk_ck CHAR(2),
    si_so INTEGER,
    giam_thi_1 CHAR(5),
    giam_thi_2 CHAR(5)
) AS $$
BEGIN
RETURN QUERY
SELECT
    lt.ma_mon_hoc,
    m.ten_mon_hoc_vn,
    lt.ma_lop,
    lt.ngay_thi,
    lt.ca_thi,
    lt.phong_thi,
    lt.hinh_thuc_thi,
    lt.gk_ck,
    t.si_so,
    ct.giam_thi_1,
    ct.giam_thi_2
FROM lich_thi lt
         JOIN thoi_khoa_bieu t ON t.ma_lop = lt.ma_lop
         JOIN mon_hoc m ON m.ma_mon_hoc = lt.ma_mon_hoc
         LEFT JOIN coi_thi ct ON ct.ma_lop = lt.ma_lop AND ct.phong_thi = lt.phong_thi
WHERE lt.ma_lop = p_ma_lop
  AND lt.ma_giang_vien = p_ma_giang_vien;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 11. func_get_exam_students
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_exam_students(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    lop_sinh_hoat CHAR(10),
    phong_thi VARCHAR(10)
) AS $$
BEGIN
RETURN QUERY
SELECT
    s.mssv,
    s.ho_ten,
    s.lop_sinh_hoat,
    lt.phong_thi
FROM ket_qua_hoc_tap k
         JOIN sinh_vien s ON s.mssv = k.mssv
         JOIN lich_thi lt ON lt.ma_lop = k.ma_lop
WHERE k.ma_lop = p_ma_lop
  AND lt.ma_giang_vien = p_ma_giang_vien;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 12. func_lecturer_create_confirmation_letter
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_lecturer_create_confirmation_letter(
    p_ma_giang_vien TEXT,
    p_mssv INTEGER,
    p_purpose TEXT
)
RETURNS TABLE (
    serial_number INTEGER,
    expiry_date TIMESTAMP
) AS $$
DECLARE
    v_serial INTEGER;
    v_exp TIMESTAMP;
BEGIN
    SELECT COALESCE(MAX(cl.serial_number), 0) + 1 INTO v_serial FROM confirmation_letters cl;

    v_exp := NOW() + INTERVAL '30 days';

    INSERT INTO confirmation_letters(mssv, purpose, serial_number, expiry_date, status)
    VALUES(p_mssv, p_purpose, v_serial, v_exp, 'approved');

    RETURN QUERY SELECT v_serial, v_exp;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 13. func_get_student_tuition
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_tuition(
    p_mssv INTEGER,
    p_hoc_ky TEXT
)
RETURNS TABLE (
    mssv INTEGER,
    ho_ten VARCHAR(50),
    hoc_ky CHAR(11),
    so_tin_chi INTEGER,
    hoc_phi NUMERIC,
    no_hoc_ky_truoc DOUBLE PRECISION,
    da_dong DOUBLE PRECISION,
    so_tien_con_lai DOUBLE PRECISION,
    don_gia_tin_chi INTEGER
) AS $$
BEGIN
RETURN QUERY
SELECT
    hp.mssv,
    sv.ho_ten,
    hp.hoc_ky,
    hp.so_tin_chi,
    hp.hoc_phi,
    hp.no_hoc_ky_truoc,
    hp.da_dong,
    hp.so_tien_con_lai,
    hp.don_gia_tin_chi
FROM hoc_phi hp
         JOIN sinh_vien sv ON sv.mssv = hp.mssv
WHERE hp.mssv = p_mssv
  AND hp.hoc_ky = p_hoc_ky;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 14. func_get_lecturer_appeals
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_appeals(
    p_ma_giang_vien TEXT,
    p_status TEXT
)
RETURNS TABLE (
    id INTEGER,
    mssv INTEGER,
    ho_ten VARCHAR(50),
    course_id VARCHAR(20),
    course_name VARCHAR(255),
    reason TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    status VARCHAR(20),
    created_at TIMESTAMP
) AS $$
BEGIN
RETURN QUERY
SELECT
    a.id,
    a.mssv,
    sv.ho_ten,
    a.course_id,
    m.ten_mon_hoc_vn,
    a.reason,
    a.payment_method,
    a.payment_status,
    a.status,
    a.created_at
FROM appeals a
         JOIN sinh_vien sv ON sv.mssv = a.mssv
         JOIN mon_hoc m ON m.ma_mon_hoc = a.course_id
WHERE a.status = COALESCE(p_status, a.status);
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 15. func_get_lecturer_appeal_detail
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_appeal_detail(
    p_ma_giang_vien TEXT,
    p_appeal_id INTEGER
)
RETURNS TABLE (
    id INTEGER,
    mssv INTEGER,
    ho_ten VARCHAR(50),
    course_id VARCHAR(20),
    course_name VARCHAR(255),
    reason TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    status VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
RETURN QUERY
SELECT
    a.id,
    a.mssv,
    sv.ho_ten,
    a.course_id,
    m.ten_mon_hoc_vn,
    a.reason,
    a.payment_method,
    a.payment_status,
    a.status,
    a.created_at,
    a.updated_at
FROM appeals a
         JOIN sinh_vien sv ON sv.mssv = a.mssv
         JOIN mon_hoc m ON m.ma_mon_hoc = a.course_id
WHERE a.id = p_appeal_id;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 16. func_lecturer_process_appeal
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_lecturer_process_appeal(
    p_ma_giang_vien TEXT,
    p_appeal_id INTEGER,
    p_status TEXT,
    p_comment TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
UPDATE appeals
SET
    status = p_status,
    comment = p_comment,
    updated_at = NOW()
WHERE id = p_appeal_id;

RETURN QUERY
SELECT TRUE, 'OK';
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 17. func_get_lecturer_notifications
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_notifications(
    p_ma_giang_vien TEXT,
    p_limit INTEGER,
    p_offset INTEGER
)
RETURNS TABLE (
    id INTEGER,
    tieu_de VARCHAR(100),
    noi_dung TEXT,
    ngay_tao DATE,
    ngay_cap_nhat DATE
) AS $$
BEGIN
RETURN QUERY
SELECT
    tb.id,
    tb.tieu_de,
    tb.noi_dung,
    tb.ngay_tao,
    tb.ngay_cap_nhat
FROM thong_bao tb
ORDER BY tb.ngay_cap_nhat DESC, tb.id DESC
LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 18. func_mark_notification_read
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_mark_notification_read(
    p_ma_giang_vien TEXT,
    p_notification_id INTEGER
)
RETURNS VOID AS $$
BEGIN
UPDATE thong_bao
SET ngay_cap_nhat = NOW()
WHERE id = p_notification_id;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 19. func_lecturer_report_absence
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_lecturer_report_absence(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT,
    p_ngay_nghi TIMESTAMP WITH TIME ZONE,
    p_ly_do TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    absence_id INTEGER
) AS $$
DECLARE v_id INTEGER;
BEGIN
    INSERT INTO bao_nghi_day(ma_lop, ma_giang_vien, ngay_nghi, ly_do, tinh_trang)
    VALUES (p_ma_lop, p_ma_giang_vien, p_ngay_nghi::DATE, p_ly_do, 'pending')
    RETURNING id INTO v_id;

    RETURN QUERY SELECT TRUE, 'OK'::TEXT, v_id;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 20. func_lecturer_schedule_makeup
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_lecturer_schedule_makeup(
    p_ma_giang_vien TEXT,
    p_ma_lop TEXT,
    p_ngay_hoc_bu TIMESTAMP WITH TIME ZONE,
    p_tiet_bat_dau INTEGER,
    p_tiet_ket_thuc INTEGER,
    p_phong_hoc TEXT,
    p_ly_do TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    makeup_id INTEGER
) AS $$
DECLARE v_id INTEGER;
BEGIN
    INSERT INTO bao_hoc_bu(ma_lop, ma_giang_vien, ngay_hoc_bu, tiet_bat_dau, tiet_ket_thuc, ly_do, tinh_trang)
    VALUES(p_ma_lop, p_ma_giang_vien, p_ngay_hoc_bu::DATE, p_tiet_bat_dau, p_tiet_ket_thuc, p_ly_do, 'pending')
    RETURNING id INTO v_id;

    RETURN QUERY SELECT TRUE, 'OK'::TEXT, v_id;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 21. func_get_lecturer_absences
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_absences(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT
)
RETURNS TABLE (
    id INTEGER,
    ma_lop CHAR(20),
    ten_mon_hoc VARCHAR(255),
    ngay_nghi DATE,
    ly_do VARCHAR(200),
    tinh_trang VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
        SELECT
            bnd.id,
            bnd.ma_lop,
            m.ten_mon_hoc_vn,
            bnd.ngay_nghi,
            bnd.ly_do,
            bnd.tinh_trang
        FROM bao_nghi_day bnd
                 JOIN thoi_khoa_bieu t ON t.ma_lop = bnd.ma_lop
                 JOIN mon_hoc m ON m.ma_mon_hoc = t.ma_mon_hoc
        WHERE bnd.ma_giang_vien = p_ma_giang_vien
          AND (p_hoc_ky = '' OR t.hoc_ky = p_hoc_ky)
        ORDER BY bnd.ngay_nghi DESC;
END;
$$ LANGUAGE plpgsql;


----------------------------------------------------------------------------------------------------
-- 22. func_get_lecturer_makeup_classes
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_lecturer_makeup_classes(
    p_ma_giang_vien TEXT,
    p_hoc_ky TEXT
)
RETURNS TABLE (
    id INTEGER,
    ma_lop CHAR(20),
    ten_mon_hoc VARCHAR(255),
    ngay_hoc_bu DATE,
    tiet_bat_dau INTEGER,
    tiet_ket_thuc INTEGER,
    phong_hoc VARCHAR(10),
    ly_do VARCHAR(200),
    tinh_trang VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
        SELECT
            bhb.id,
            bhb.ma_lop,
            m.ten_mon_hoc_vn,
            bhb.ngay_hoc_bu,
            bhb.tiet_bat_dau,
            bhb.tiet_ket_thuc,
            tkb.phong_hoc,
            bhb.ly_do,
            bhb.tinh_trang
        FROM bao_hoc_bu bhb
                 JOIN thoi_khoa_bieu tkb ON tkb.ma_lop = bhb.ma_lop
                 JOIN mon_hoc m ON m.ma_mon_hoc = tkb.ma_mon_hoc
        WHERE bhb.ma_giang_vien = p_ma_giang_vien
          AND (p_hoc_ky = '' OR tkb.hoc_ky = p_hoc_ky)
        ORDER BY bhb.ngay_hoc_bu DESC;
END;
$$ LANGUAGE plpgsql;
----------------------------------------------------------------------------------------------------
-- 23. func_lecturer_process_appeal
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_lecturer_process_appeal(
    p_ma_giang_vien TEXT,
    p_appeal_id INTEGER,
    p_status TEXT,
    p_comment TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE appeals
    SET
        status = p_status,
        updated_at = NOW()
    WHERE id = p_appeal_id;
    RETURN QUERY SELECT TRUE, 'Appeal processed successfully'::TEXT;
END;
$$ LANGUAGE plpgsql;
