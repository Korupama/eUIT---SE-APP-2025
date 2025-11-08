-- Import du lieu sinh vien
COPY sinh_vien
FROM 'eUIT/scripts/database/data/sinh_vien.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


-- Import du lieu mon hoc
COPY mon_hoc
FROM 'D:\eUIT\scripts\database\data\danh_muc_mon_hoc.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

-- Import du lieu dieu kien mon hoc
copy select * from dieu_kien_mon_hoc
FROM 'D:\eUIT\scripts\database\data\dieu_kien_mon_hoc.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Import du lieu giang vien
COPY giang_vien
FROM 'D:\eUIT\scripts\database\data\giang_vien.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

    copy thoi_khoa_bieu
FROM 'D:\eUIT\scripts\database\main_data\thoi_khoa_bieu.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

 copy thoi_khoa_bieu
FROM 'D:\eUIT\scripts\database\main_data\kq_dkhp_with_gv.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

    copy bang_diem
    FROM 'D:\eUIT\scripts\database\main_data\bang_diem.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


select * from sinh_vien
where nganh_hoc in ('Công nghệ thông tin',  'Công nghệ thông tin - Định hướng Nhật Bản')
and khoa_hoc = 23;

    -- Import du lieu cot ma_lop, mssv, diem_qua_trinh, diem_giua_ki, diem_thuc_hanh, diem_cuoi_ki vao bang ket_qua_hoc_tap
copy ket_qua_hoc_tap (ma_lop, mssv, ma_lop_goc, diem_qua_trinh, diem_giua_ki, diem_thuc_hanh, diem_cuoi_ki, ghi_chu)
FROM 'D:\eUIT\scripts\database\other_data\ket_qua_hoc_tap_mau.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

copy ket_qua_hoc_tap (ma_lop, mssv, ma_lop_goc, diem_qua_trinh, diem_giua_ki, diem_thuc_hanh, diem_cuoi_ki, ghi_chu)
FROM 'D:\eUIT\scripts\database\other_data\ket_qua_hoc_tap_mau_expanded.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');



INSERT INTO ket_qua_hoc_tap (ma_lop, mssv, diem_qua_trinh, diem_giua_ki, diem_thuc_hanh, diem_cuoi_ki)
VALUES ('IT001.N11', '21520541', 10, NULL, 10, 9);

select create_student_account(21520541, 'password0541')

select *  from tai_khoan_sinh_vien;

SELECT kq.ma_lop, kq.diem_tong_ket FROM ket_qua_hoc_tap kq WHERE mssv = '21520541';
SELECT * FROM bang_diem
SELECT * from hoc_phi

SELECT * from ket_qua_hoc_tap


DELETE FROM bang_diem;
DELETE FROM ket_qua_hoc_tap;
DELETE FROM hoc_phi;