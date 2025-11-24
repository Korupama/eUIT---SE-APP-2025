-- =================================================================================
-- SQL FUNCTIONS FOR STUDENT SCHEDULE MANAGEMENT
-- Mục đích: Cung cấp các hàm xử lý nghiệp vụ lịch học và lịch thi
-- =================================================================================

-- ---------------------------------------------------------------------------------
-- HÀM 1: Lấy thời khóa biểu của sinh viên
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_schedule
-- Mục đích: Trả về toàn bộ lịch học của sinh viên (các lớp đã đăng ký)
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tra cứu
-- Trả về: Danh sách các lớp học với đầy đủ thông tin thời khóa biểu
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_schedule(
    p_mssv INT
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHAR(20),
    so_tin_chi INT,
    ma_giang_vien CHAR(5),
    ho_ten VARCHAR(50),
    thu CHAR(2),
    tiet_bat_dau INT,
    tiet_ket_thuc INT,
    cach_tuan INT,
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    phong_hoc VARCHAR(10),
    si_so INT,
    hinh_thuc_giang_day CHAR(5),
    ghi_chu VARCHAR(255)
)
LANGUAGE sql
AS $$
SELECT 
    tkb.hoc_ky,
    tkb.ma_mon_hoc,
    mh.ten_mon_hoc_vn AS ten_mon_hoc,
    tkb.ma_lop,
    tkb.so_tin_chi,
    tkb.ma_giang_vien,
    gv.ho_ten,
    tkb.thu,
    tkb.tiet_bat_dau,
    tkb.tiet_ket_thuc,
    tkb.cach_tuan,
    tkb.ngay_bat_dau,
    tkb.ngay_ket_thuc,
    tkb.phong_hoc,
    tkb.si_so,
    tkb.hinh_thuc_giang_day,
    tkb.ghi_chu
FROM ket_qua_hoc_tap AS kqht
JOIN thoi_khoa_bieu AS tkb ON kqht.ma_lop = tkb.ma_lop
JOIN mon_hoc AS mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
JOIN giang_vien AS gv ON tkb.ma_giang_vien = gv.ma_giang_vien
WHERE kqht.mssv = p_mssv
ORDER BY tkb.hoc_ky DESC, tkb.thu, tkb.tiet_bat_dau;
$$;

-- ---------------------------------------------------------------------------------
-- HÀM 2: Lấy thời khóa biểu theo học kỳ
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_schedule_by_semester
-- Mục đích: Trả về lịch học của sinh viên trong một học kỳ cụ thể
-- Tham số:
--   p_mssv INT: Mã số sinh viên
--   p_hoc_ky CHAR(11): Học kỳ cần tra cứu (ví dụ: '2025_2026_1')
-- Trả về: Danh sách các lớp học trong học kỳ đó
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_schedule_by_semester(
    p_mssv INT,
    p_hoc_ky CHAR(11)
)
RETURNS TABLE (
    hoc_ky CHAR(11),
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHAR(20),
    so_tin_chi INT,
    ma_giang_vien CHAR(5),
    ho_ten VARCHAR(50),
    thu CHAR(2),
    tiet_bat_dau INT,
    tiet_ket_thuc INT,
    cach_tuan INT,
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    phong_hoc VARCHAR(10),
    si_so INT,
    hinh_thuc_giang_day CHAR(5),
    ghi_chu VARCHAR(255)
)
LANGUAGE sql
AS $$
SELECT 
    tkb.hoc_ky,
    tkb.ma_mon_hoc,
    mh.ten_mon_hoc_vn AS ten_mon_hoc,
    tkb.ma_lop,
    tkb.so_tin_chi,
    tkb.ma_giang_vien,
    gv.ho_ten,
    tkb.thu,
    tkb.tiet_bat_dau,
    tkb.tiet_ket_thuc,
    tkb.cach_tuan,
    tkb.ngay_bat_dau,
    tkb.ngay_ket_thuc,
    tkb.phong_hoc,
    tkb.si_so,
    tkb.hinh_thuc_giang_day,
    tkb.ghi_chu
FROM ket_qua_hoc_tap AS kqht
JOIN thoi_khoa_bieu AS tkb ON kqht.ma_lop = tkb.ma_lop
JOIN mon_hoc AS mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
JOIN giang_vien AS gv ON tkb.ma_giang_vien = gv.ma_giang_vien
WHERE kqht.mssv = p_mssv 
  AND tkb.hoc_ky = p_hoc_ky
ORDER BY tkb.thu, tkb.tiet_bat_dau;
$$;

-- ---------------------------------------------------------------------------------
-- HÀM 3: Lấy lịch thi của sinh viên
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_exam_schedule
-- Mục đích: Trả về toàn bộ lịch thi của sinh viên
-- Tham số:
--   p_mssv INT: Mã số sinh viên
-- Trả về: Danh sách các môn thi với thông tin chi tiết
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_exam_schedule(
    p_mssv INT
)
RETURNS TABLE (
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHAR(20),
    ma_giang_vien CHAR(5),
    ho_ten VARCHAR(50),
    ngay_thi DATE,
    ca_thi INT,
    phong_thi VARCHAR(10),
    hinh_thuc_thi VARCHAR(20),
    gk_ck CHAR(2),
    so_tin_chi INT
)
LANGUAGE sql
AS $$
SELECT 
    lt.ma_mon_hoc,
    mh.ten_mon_hoc_vn AS ten_mon_hoc,
    lt.ma_lop,
    lt.ma_giang_vien,
    gv.ho_ten,
    lt.ngay_thi,
    lt.ca_thi,
    lt.phong_thi,
    lt.hinh_thuc_thi,
    lt.gk_ck,
    tkb.so_tin_chi
FROM ket_qua_hoc_tap AS kqht
JOIN lich_thi AS lt ON kqht.ma_lop = lt.ma_lop
JOIN mon_hoc AS mh ON lt.ma_mon_hoc = mh.ma_mon_hoc
JOIN giang_vien AS gv ON lt.ma_giang_vien = gv.ma_giang_vien
JOIN thoi_khoa_bieu AS tkb ON lt.ma_lop = tkb.ma_lop AND lt.ma_giang_vien = tkb.ma_giang_vien
WHERE kqht.mssv = p_mssv
ORDER BY lt.ngay_thi, lt.ca_thi;
$$;

-- ---------------------------------------------------------------------------------
-- HÀM 4: Lấy lịch thi theo học kỳ
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_student_exam_schedule_by_semester
-- Mục đích: Trả về lịch thi của sinh viên trong một học kỳ cụ thể
-- Tham số:
--   p_mssv INT: Mã số sinh viên
--   p_hoc_ky CHAR(11): Học kỳ cần tra cứu
-- Trả về: Danh sách các môn thi trong học kỳ đó
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION func_get_student_exam_schedule_by_semester(
    p_mssv INT,
    p_hoc_ky CHAR(11)
)
RETURNS TABLE (
    ma_mon_hoc CHAR(8),
    ten_mon_hoc VARCHAR(255),
    ma_lop CHAR(20),
    ma_giang_vien CHAR(5),
    ho_ten VARCHAR(50),
    ngay_thi DATE,
    ca_thi INT,
    phong_thi VARCHAR(10),
    hinh_thuc_thi VARCHAR(20),
    gk_ck CHAR(2),
    so_tin_chi INT
)
LANGUAGE sql
AS $$
SELECT 
    lt.ma_mon_hoc,
    mh.ten_mon_hoc_vn AS ten_mon_hoc,
    lt.ma_lop,
    lt.ma_giang_vien,
    gv.ho_ten,
    lt.ngay_thi,
    lt.ca_thi,
    lt.phong_thi,
    lt.hinh_thuc_thi,
    lt.gk_ck,
    tkb.so_tin_chi
FROM ket_qua_hoc_tap AS kqht
JOIN thoi_khoa_bieu AS tkb ON kqht.ma_lop = tkb.ma_lop
JOIN lich_thi AS lt ON tkb.ma_lop = lt.ma_lop AND tkb.ma_giang_vien = lt.ma_giang_vien
JOIN mon_hoc AS mh ON lt.ma_mon_hoc = mh.ma_mon_hoc
JOIN giang_vien AS gv ON lt.ma_giang_vien = gv.ma_giang_vien
WHERE kqht.mssv = p_mssv 
  AND tkb.hoc_ky = p_hoc_ky
ORDER BY lt.ngay_thi, lt.ca_thi;
$$;

-- Test queries
-- SELECT * FROM func_get_student_schedule(23520541);
-- SELECT * FROM func_get_student_schedule_by_semester(23520541, '2025_2026_1');
-- SELECT * FROM func_get_student_exam_schedule(23520541);
-- SELECT * FROM func_get_student_exam_schedule_by_semester(23520541, '2025_2026_1');
