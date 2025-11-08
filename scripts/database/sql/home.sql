-- ---------------------------------------------------------------------------------
-- HÀM 6: Lấy tiết học tiếp theo của MỘT sinh viên.
-- ---------------------------------------------------------------------------------
-- Tên hàm: func_get_next_class
-- Mục đích: Trả về thông tin tiết học tiếp theo của sinh viên dựa trên thời gian hiện tại.
-- Tham số:
--   p_mssv INT: Mã số sinh viên cần tra cứu.
-- Trả về: Một hàng chứa thông tin lớp học tiếp theo (hoặc rỗng nếu không có).
-- ---------------------------------------------------------------------------------


CREATE OR REPLACE  FUNCTION func_get_next_class(
    p_mssv INT
)
RETURNS TABLE (
    ma_lop CHAR(20),
    ten_mon_hoc_vn VARCHAR(255),
    thu CHAR(2),
    tiet_bat_dau INT,
    tiet_ket_thuc INT,
    phong_hoc VARCHAR(10),
    ngay_hoc DATE
)
LANGUAGE sql
AS $$
WITH Classes AS (
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
        tkb.cach_tuan,
        tkb.ma_mon_hoc,
        mh.ten_mon_hoc_vn,
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
    JOIN mon_hoc AS mh ON tkb.ma_mon_hoc = mh.ma_mon_hoc
    WHERE tkb.hinh_thuc_giang_day != 'HT2'
      AND tkb.ngay_ket_thuc >= CURRENT_DATE
),
PossibleDates AS (
    SELECT 
        s.ma_lop,
        s.thu,
        s.tiet_bat_dau,
        s.tiet_ket_thuc,
        s.phong_hoc,
        gs.date AS class_date,
        s.ten_mon_hoc_vn
    FROM Schedules AS s
    JOIN LATERAL (
        SELECT d::date AS date
        FROM generate_series(s.ngay_bat_dau, s.ngay_ket_thuc, INTERVAL '1 day') AS d
        WHERE EXTRACT(DOW FROM d) = s.target_dow
          AND ((EXTRACT(EPOCH FROM (d - s.ngay_bat_dau)) / 86400)::int / 7) % s.cach_tuan = 0
    ) AS gs ON TRUE
    WHERE gs.date >= CURRENT_DATE
),
NextClass AS (
    SELECT * FROM PossibleDates ORDER BY class_date LIMIT 1
)
SELECT 
    ma_lop,
    ten_mon_hoc_vn,
    thu,
    tiet_bat_dau,
    tiet_ket_thuc,
    phong_hoc,
    class_date AS ngay_hoc
FROM NextClass;
$$;


SELECT * from func_get_next_class(23520541)

CREATE OR REPLACE FUNCTION func_get_student_card_info( p_mssv INT )
RETURNS TABLE (
    mssv INT,
    ho_ten VARCHAR(50),
    khoa_hoc INT,    
    nganh_hoc VARCHAR(100),
    anh_the_url VARCHAR(255)    
)
LANGUAGE sql
as $$
SELECT mssv, ho_ten, khoa_hoc, nganh_hoc, anh_the_url from sinh_vien
where mssv = p_mssv;
$$;

UPDATE sinh_vien
set anh_the_url = 'students/avatars/23520547.png'
where mssv = 23520547

select * from func_get_student_card_info(23520541)

