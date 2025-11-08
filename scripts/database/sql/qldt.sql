-- =================================================================================
-- TẬP TIN HOÀN CHỈNH: SCHEMA VÀ CÁC HÀM XỬ LÝ NGHIỆP VỤ ĐIỂM
-- MỤC ĐÍCH:
-- 1. Cung cấp schema đã tái cấu trúc cho hệ thống điểm.
-- 2. Đóng gói toàn bộ logic tra cứu và tính toán điểm vào các hàm PostgreSQL
--    để API backend có thể gọi một cách đơn giản và an toàn.
-- =================================================================================

-- =================================================================================
-- PHẦN 1: SCHEMA ĐÃ TÁI CẤU TRÚC (Để tham khảo)
-- =================================================================================

-- Xóa các bảng cũ nếu tồn tại để chạy lại script này mà không bị lỗi.
DROP TABLE IF EXISTS ket_qua_hoc_tap CASCADE;
DROP TABLE IF EXISTS bang_diem CASCADE;

-- Bảng Cấu trúc điểm: Mỗi môn học (đại diện bởi mã lớp gốc) chỉ có MỘT hàng.
CREATE TABLE bang_diem (
    ma_lop_goc CHAR(20) PRIMARY KEY,
    trong_so_qua_trinh INT,
    trong_so_giua_ki INT,
    trong_so_thuc_hanh INT,
    trong_so_cuoi_ki INT,
    CONSTRAINT chk_total_weight CHECK ((trong_so_qua_trinh + trong_so_giua_ki + trong_so_thuc_hanh + trong_so_cuoi_ki) = 100)
);

-- Bảng Điểm thành phần: Lưu các điểm riêng lẻ cho lớp lý thuyết, thực hành...
CREATE TABLE ket_qua_hoc_tap (
    ma_lop CHAR(20) NOT NULL,
    mssv INT NOT NULL,
    ma_lop_goc CHAR(20) NOT NULL,
    diem_qua_trinh NUMERIC(4,2),
    diem_giua_ki NUMERIC(4,2),
    diem_thuc_hanh NUMERIC(4,2),
    diem_cuoi_ki NUMERIC(4,2),
    ghi_chu VARCHAR(20),
    PRIMARY KEY (ma_lop, mssv),
    FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv),
    FOREIGN KEY (ma_lop_goc) REFERENCES bang_diem(ma_lop_goc)
);


-- =================================================================================
-- PHẦN 2: CÁC HÀM TRA CỨU VÀ TÍNH TOÁN
-- =================================================================================

-- ---------------------------------------------------------------------------------
-- HÀM 1: Lấy điểm chi tiết của MỘT môn học của MỘT sinh viên.
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_subject_grade
-- Mục đích: Trả về bảng điểm chi tiết (trọng số, điểm thành phần, điểm tổng kết)
--           của một sinh viên cho một môn học cụ thể.
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tra cứu.
--   p_ma_lop_goc VARCHAR(20): Mã lớp gốc của môn học cần tra cứu (ví dụ: 'IE307.Q12').
-- Trả về: Một hàng duy nhất chứa toàn bộ chi tiết điểm.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_subject_grade(
    p_mssv INT,
    p_ma_lop_goc VARCHAR(20)
)
RETURNS TABLE (
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
WITH 
DiemThanhPhan AS (
    SELECT
        MAX(kqht.diem_qua_trinh) AS diem_qt,
        MAX(kqht.diem_giua_ki) AS diem_gk,
        MAX(kqht.diem_thuc_hanh) AS diem_th,
        MAX(kqht.diem_cuoi_ki) AS diem_ck
    FROM ket_qua_hoc_tap AS kqht
    WHERE kqht.mssv = p_mssv AND kqht.ma_lop_goc = p_ma_lop_goc
)
SELECT
    bd.trong_so_qua_trinh,
    bd.trong_so_giua_ki,
    bd.trong_so_thuc_hanh,
    bd.trong_so_cuoi_ki,
    dtp.diem_qt,
    dtp.diem_gk,
    dtp.diem_th,
    dtp.diem_ck,
    CASE
        WHEN (COALESCE(bd.trong_so_qua_trinh,0) + COALESCE(bd.trong_so_giua_ki,0) + COALESCE(bd.trong_so_thuc_hanh,0) + COALESCE(bd.trong_so_cuoi_ki,0)) != 100
            THEN NULL
                WHEN (bd.trong_so_qua_trinh > 0 AND dtp.diem_qt IS NULL)
                    OR (bd.trong_so_giua_ki > 0 AND dtp.diem_gk IS NULL)
                    OR (bd.trong_so_thuc_hanh > 0 AND dtp.diem_th IS NULL)
                    OR (bd.trong_so_cuoi_ki > 0 AND dtp.diem_ck IS NULL)
                        THEN NULL
        ELSE ROUND(
          ( COALESCE(dtp.diem_qt, 0) * COALESCE(bd.trong_so_qua_trinh,0) +
            COALESCE(dtp.diem_gk, 0) * COALESCE(bd.trong_so_giua_ki,0) +
            COALESCE(dtp.diem_th, 0) * COALESCE(bd.trong_so_thuc_hanh,0) +
            COALESCE(dtp.diem_ck, 0) * COALESCE(bd.trong_so_cuoi_ki,0))
            / 100.0 , 2)
    END AS diem_tong_ket
FROM 
    bang_diem AS bd
CROSS JOIN 
    DiemThanhPhan AS dtp
WHERE 
    bd.ma_lop_goc = p_ma_lop_goc;
$$;

SELECT * FROM func_get_student_subject_grade(23520541, 'IE307.Q12');

-- ---------------------------------------------------------------------------------
-- HÀM 2: Lấy bảng điểm trong MỘT học kỳ của MỘT sinh viên.
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_semester_transcript
-- Mục đích: Trả về bảng điểm chi tiết của tất cả các môn mà một sinh viên
--           đã học trong một học kỳ cụ thể.
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tra cứu.
--   p_hoc_ky CHAR(11): Học kỳ cần tra cứu (ví dụ: '2025-2026_1').
-- Trả về: Một bảng, mỗi hàng là một môn học với đầy đủ chi tiết điểm.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_semester_transcript(
    p_mssv INT,
    p_hoc_ky CHAR(11)
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    so_tin_chi INT,
    diem_tong_ket NUMERIC(4,2)
)
LANGUAGE sql
AS $$
WITH 
CacLopGocTrongKy AS (
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
    (SELECT dtk.diem_tong_ket FROM func_get_student_subject_grade(p_mssv, clgtk.ma_lop_goc) AS dtk)
FROM 
    CacLopGocTrongKy AS clgtk
JOIN thoi_khoa_bieu AS tkb ON clgtk.ma_lop_goc = tkb.ma_lop
JOIN mon_hoc AS mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
ORDER BY tkb.ma_mon_hoc;
$$;

SELECT * FROM func_get_student_semester_transcript(23520541, '2025_2026_1')

-- ---------------------------------------------------------------------------------
-- HÀM 3: Lấy bảng điểm TOÀN KHÓA của MỘT sinh viên.
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_full_transcript
-- Mục đích: Trả về toàn bộ lịch sử học tập của một sinh viên.
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tra cứu.
-- Trả về: Một bảng, mỗi hàng là một môn học đã học, sắp xếp theo học kỳ.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_full_transcript(
    p_mssv INT
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    so_tin_chi INT,
    diem_tong_ket NUMERIC(4,2)
)
LANGUAGE sql
AS $$
WITH 
CacLopGocDaHoc AS (
    SELECT DISTINCT ma_lop_goc FROM ket_qua_hoc_tap WHERE mssv = p_mssv
)
SELECT
    tkb.hoc_ky,
    tkb.ma_mon_hoc,
    mh.ten_mon_hoc_vn,
    tkb.so_tin_chi,
    (SELECT dtk.diem_tong_ket FROM func_get_student_subject_grade(p_mssv, clgdh.ma_lop_goc) AS dtk)
FROM 
    CacLopGocDaHoc AS clgdh
JOIN thoi_khoa_bieu AS tkb ON clgdh.ma_lop_goc = tkb.ma_lop
JOIN mon_hoc AS mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
ORDER BY tkb.hoc_ky, tkb.ma_mon_hoc;
$$;

SELECT * FROM func_get_student_full_transcript(23520545)


-- ---------------------------------------------------------------------------------
-- HÀM 4: Tính điểm trung bình tích lũy (GPA) của MỘT sinh viên và tổng số tín chỉ tích lũy.
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_calculate_gpa
-- Mục đích: Tính điểm GPA dựa trên kết quả toàn khóa của sinh viên và tổng số tín chỉ tích lũy (điểm >= 5.0).
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tính GPA.
-- Trả về: Một hàng gồm điểm GPA và tổng số tín chỉ tích lũy.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_calculate_gpa(
    p_mssv INT
)
RETURNS TABLE (
    gpa NUMERIC(4,2),
    so_tin_chi_tich_luy INT
)
LANGUAGE sql
AS $$
WITH BangDiem AS (
    SELECT * FROM func_get_student_full_transcript(p_mssv)
    WHERE diem_tong_ket IS NOT NULL 
)
SELECT
    CASE 
        WHEN SUM(bd.so_tin_chi) > 0 THEN ROUND(SUM(bd.diem_tong_ket * bd.so_tin_chi) / SUM(bd.so_tin_chi), 2)
        ELSE 0.00
    END AS gpa,
    COALESCE(SUM(CASE WHEN bd.diem_tong_ket >= 5.0 THEN bd.so_tin_chi ELSE 0 END), 0) AS accumulated_credits
FROM 
    BangDiem AS bd;
$$;

SELECT * FROM func_calculate_gpa(23520541)


-- ---------------------------------------------------------------------------------
-- HÀM 5: Lấy bảng điểm của TOÀN BỘ sinh viên trong MỘT lớp học phần.
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_class_grade_list
-- Mục đích: Trả về danh sách điểm chi tiết của tất cả sinh viên
--           đã tham gia một môn học.
-- Tham số:
--   p_ma_lop_goc VARCHAR(20): Mã lớp gốc của môn học cần xem điểm.
-- Trả về: Một bảng, mỗi hàng là một sinh viên với đầy đủ chi tiết điểm.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_class_grade_list(
    p_ma_lop_goc VARCHAR(20)
)
RETURNS TABLE (
    mssv INT,
    ho_ten VARCHAR(50),
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
WITH 
DanhSachSinhVien AS (
    SELECT DISTINCT kqht.mssv
    FROM ket_qua_hoc_tap AS kqht
    WHERE kqht.ma_lop_goc = p_ma_lop_goc
)
SELECT
    dssv.mssv,
    sv.ho_ten,
    dtk.trong_so_qua_trinh,
    dtk.trong_so_giua_ki,
    dtk.trong_so_thuc_hanh,
    dtk.trong_so_cuoi_ki,
    dtk.diem_qua_trinh,
    dtk.diem_giua_ki,
    dtk.diem_thuc_hanh,
    dtk.diem_cuoi_ki,
    dtk.diem_tong_ket
FROM 
    DanhSachSinhVien AS dssv
JOIN sinh_vien AS sv ON dssv.mssv = sv.mssv
JOIN LATERAL func_get_student_subject_grade(dssv.mssv, p_ma_lop_goc) AS dtk ON TRUE
ORDER BY sv.ho_ten;
$$;

SELECT * FROM func_get_class_grade_list('IT001.O11')

-- ---------------------------------------------------------------------------------
-- HÀM 6: Lấy tiết học tiếp theo của MỘT sinh viên.
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_next_class
-- Mục đích: Trả về thông tin tiết học tiếp theo của sinh viên dựa trên thời gian hiện tại.
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tra cứu.
-- Trả về: Một hàng chứa thông tin lớp học tiếp theo (hoặc rỗng nếu không có).
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_next_class(
    p_mssv INT
)
RETURNS TABLE (
    ma_lop CHAR(20),
    thu CHAR(2),
    tiet_bat_dau INT,
    tiet_ket_thuc INT,
    phong_hoc VARCHAR(10),
    next_date DATE
)
LANGUAGE sql
AS $$
WITH 
Classes AS (
    SELECT DISTINCT kqht.ma_lop
    FROM ket_qua_hoc_tap AS kqht
    WHERE kqht.mssv = p_mssv
),
Schedules AS (
    SELECT 
        c.ma_lop,
        tkb.thu,
        tkb.tiet_bat_dau,
        tkb.tiet_ket_thuc,
        tkb.phong_hoc,
        tkb.ngay_bat_dau,
        tkb.ngay_ket_thuc,
        CASE 
            WHEN tkb.thu = '2' THEN 1
            WHEN tkb.thu = '3' THEN 2
            WHEN tkb.thu = '4' THEN 3
            WHEN tkb.thu = '5' THEN 4
            WHEN tkb.thu = '6' THEN 5
            WHEN tkb.thu = '7' THEN 6
            WHEN tkb.thu = '8' THEN 0
            ELSE NULL
        END AS target_dow
    FROM Classes AS c
    JOIN thoi_khoa_bieu AS tkb ON c.ma_lop = tkb.ma_lop
    WHERE tkb.hinh_thuc_giang_day != 'HT2'
      AND tkb.cach_tuan = 1
      AND tkb.ngay_ket_thuc >= CURRENT_DATE
),
NextDates AS (
    SELECT 
        s.*,
        CURRENT_DATE + INTERVAL '1 day' * (
            (s.target_dow - EXTRACT(DOW FROM CURRENT_DATE) + 7) % 7
        ) AS candidate_date
    FROM Schedules AS s
    WHERE s.target_dow IS NOT NULL
),
Adjusted AS (
    SELECT 
        nd.*,
        CASE 
            WHEN nd.candidate_date = CURRENT_DATE THEN nd.candidate_date + INTERVAL '7 days'
            ELSE nd.candidate_date
        END AS next_date
    FROM NextDates AS nd
),
Valid AS (
    SELECT 
        a.*
    FROM Adjusted AS a
    WHERE a.next_date BETWEEN a.ngay_bat_dau AND a.ngay_ket_thuc
)
SELECT 
    v.ma_lop,
    v.thu,
    v.tiet_bat_dau,
    v.tiet_ket_thuc,
    v.phong_hoc,
    v.next_date
FROM Valid AS v
ORDER BY v.next_date
LIMIT 1;
$$;