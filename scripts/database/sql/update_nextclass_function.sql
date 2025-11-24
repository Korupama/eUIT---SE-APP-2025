-- Drop the existing function first
DROP FUNCTION IF EXISTS func_get_next_class(INT);

-- Create the updated function with new columns
CREATE OR REPLACE FUNCTION func_get_next_class(
    p_mssv INT
)
RETURNS TABLE (
    ma_lop VARCHAR(20),
    ten_mon_hoc_vn VARCHAR(255),
    ho_ten VARCHAR(50),
    thu VARCHAR(2),
    tiet_bat_dau INT,
    tiet_ket_thuc INT,
    phong_hoc VARCHAR(10),
    ngay_hoc DATE,
    countdown_minutes INT
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
        tkb.ma_giang_vien,
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
        s.ma_giang_vien,
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
    SELECT * FROM PossibleDates ORDER BY class_date, tiet_bat_dau LIMIT 1
)
SELECT 
    nc.ma_lop,
    nc.ten_mon_hoc_vn,
    gv.ho_ten,
    nc.thu,
    nc.tiet_bat_dau,
    nc.tiet_ket_thuc,
    nc.phong_hoc,
    nc.class_date AS ngay_hoc,
    EXTRACT(EPOCH FROM (
        (nc.class_date + TIME '07:00:00' + (nc.tiet_bat_dau - 1) * INTERVAL '50 minutes') - NOW()
    ))::INT / 60 AS countdown_minutes
FROM NextClass nc
JOIN giang_vien gv ON nc.ma_giang_vien = gv.ma_giang_vien;
$$;
