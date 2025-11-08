language plpgsql;-- This script creates the eUIT database and its initial tables for managing student information, courses, and
--DROP DATABASE IF EXISTS "eUIT";



CREATE DATABASE "eUIT"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'vi-VN'
    LC_CTYPE = 'vi-VN'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

--Tao bang sinh vien
CREATE TABLE sinh_vien
(
	--Thong tin co ban
	mssv INT primary key,
	ho_ten VARCHAR(50) NOT NULL,
	ngay_sinh DATE NOT NULL,
	nganh_hoc VARCHAR(100) NOT NULL,
	khoa_hoc INT NOT NULL,
	lop_sinh_hoat CHAR(10) NOT NULL,

	--Thong tin ca nhan sinh vien
	noi_sinh VARCHAR(200) NOT NULL,
	cccd CHAR(12) NOT NULL,
	ngay_cap_cccd DATE NOT NULL,
	noi_cap_cccd VARCHAR(50) NOT NULL,
	dan_toc VARCHAR(10) NOT NULL,
	ton_giao VARCHAR(20) NOT NULL,
	so_dien_thoai CHAR(10) NOT NULL,
    dia_chi_thuong_tru VARCHAR(200) NOT NULL,
	tinh_thanh_pho	VARCHAR(20) NOT NULL,
	phuong_xa text NOT NULL,
	qua_trinh_hoc_tap_cong_tac VARCHAR(500) NOT NULL,
	thanh_tich VARCHAR(500) NOT NULL,
	email_ca_nhan VARCHAR(50) NOT NULL,

	--Thong tin ngan hang
	ma_ngan_hang char(4),
	ten_ngan_hang varchar(20),
	so_tai_khoan VARCHAR(20),
	chi_nhanh varchar(50),

	--Thong tin ve phu huynh sinh vien - Cha
	ho_ten_cha varchar(50),
	quoc_tich_cha varchar(20),
	dan_toc_cha varchar(10),
	ton_giao_cha varchar(20),
	sdt_cha char(10),
	email_cha varchar(50), 
	dia_chi_thuong_tru_cha varchar(200),
	cong_viec_cha varchar(20),
	
	--Thong tin ve phu huynh sinh vien - Me
	ho_ten_me varchar(50),
	quoc_tich_me varchar(20),
	dan_toc_me varchar(10),
	ton_giao_me varchar(20),
	sdt_me char(10),
	email_me varchar(50), 
	dia_chi_thuong_tru_me varchar(200),
	cong_viec_me varchar(20),

	--Thong tin ve phu huynh sinh vien - Nguoi giam ho
	ho_ten_ngh varchar(50),
	quoc_tich_ngh varchar(20),
	dan_toc_ngh varchar(10),
	ton_giao_ngh varchar(20),
	sdt_ngh char(10),
	email_ngh varchar(50), 
	dia_chi_thuong_tru_ngh varchar(200),
	cong_viec_ngh varchar(20),

	--Khi can bao tin cho ai? o dau
	thong_tin_nguoi_can_bao_tin varchar(200) NOT NULL,
	so_dien_thoai_bao_tin char(10) NOT NULL,

	anh_the_url VARCHAR(255)
)

CREATE TABLE giang_vien
(
	ma_giang_vien char(5) primary key,
	ho_ten varchar(50) NOT NULL,
	khoa_bo_mon char(5) NOT NULL, -- Khoa bo mon giang vien thuoc ve
	--Thong tin ca nhan giang vien
	ngay_sinh DATE NOT NULL,
	noi_sinh VARCHAR(200) NOT NULL,
	cccd CHAR(12) NOT NULL,
	ngay_cap_cccd DATE NOT NULL,
	noi_cap_cccd VARCHAR(50) NOT NULL,
	dan_toc VARCHAR(10) NOT NULL,
	ton_giao VARCHAR(20) NOT NULL,
	so_dien_thoai CHAR(10) NOT NULL,
	dia_chi_thuong_tru VARCHAR(200) NOT NULL,
	tinh_thanh_pho	VARCHAR(20) NOT NULL,
	phuong_xa text NOT NULL

	-- Cac thong tin khac ve giang vien co the them vao sau
)


CREATE TABLE mon_hoc
(
	ma_mon_hoc char(8) primary key,
	ten_mon_hoc_vn varchar(255),
	ten_mon_hoc_en varchar(255),
	con_mo_lop char(5),
	khoa_bo_mon_quan_ly char(5),
	loai_mon_hoc char(4),
	so_tc_ly_thuyet int,
	so_tc_thuc_hanh int
)
 


CREATE TABLE dieu_kien_mon_hoc
(
	ma_mon_hoc char(8) NOT NULL,
	ma_mon_hoc_dieu_kien char(8) NOT NULL,
	--Dieu kien co the la mon hoc tien quyet, hoac mon hoc truoc
	loai_dieu_kien varchar(10) NOT NULL,
	PRIMARY KEY (ma_mon_hoc, ma_mon_hoc_dieu_kien),
	FOREIGN KEY (ma_mon_hoc) REFERENCES mon_hoc(ma_mon_hoc),
	FOREIGN KEY (ma_mon_hoc_dieu_kien) REFERENCES mon_hoc(ma_mon_hoc)
)


CREATE TABLE thoi_khoa_bieu 
(
	hoc_ky char(11), --Vi du: 2023-2024_1
	ma_mon_hoc char(8), --Vi du: IT001
	ma_lop char(20), --Vi du: IT001.P11.CNVN
	so_tin_chi int,
	ma_giang_vien char(5), --Vi du: 80001
	thu char(2), --Thu 2, Thu 3, ...
	tiet_bat_dau int, --Tiet bat dau cua lop hoc
	tiet_ket_thuc int, --Tiet ket thuc cua lop hoc
	cach_tuan int, --Cach tuan cua lop hoc (1: moi tuan, 2: cach 2 tuan, ...)
	ngay_bat_dau DATE, --Ngay bat dau lop hoc
	ngay_ket_thuc DATE , --Ngay ket thuc lop hoc
	phong_hoc varchar(10), --Vi du: A101
	si_so int, --Si so lop hoc
	hinh_thuc_giang_day char(5), --Hinh thuc giang day (Ly thuyet:LT, DA, TTTN, KLTN; Thuc hanh: HT1, HT2, ...)
	ghi_chu VARCHAR(255), --Ghi chu ve lop hoc
	PRIMARY KEY (ma_lop, ma_giang_vien),
	FOREIGN KEY (ma_mon_hoc) REFERENCES mon_hoc(ma_mon_hoc),
	FOREIGN KEY (ma_giang_vien) REFERENCES giang_vien(ma_giang_vien)
)


CREATE TABLE bang_diem (
    ma_lop CHAR(20) PRIMARY KEY,              -- Ví dụ: IT001.P11.CNVN
    ma_giang_vien CHAR(5),                 -- Ví dụ: 80001
    trong_so_qua_trinh INT,               -- Ví dụ: 10%
    trong_so_giua_ki INT,                 -- Ví dụ: 30%
    trong_so_thuc_hanh INT,               -- Ví dụ: 20%
    trong_so_cuoi_ki INT,                 -- Ví dụ: 40%
    FOREIGN KEY (ma_lop, ma_giang_vien) REFERENCES thoi_khoa_bieu(ma_lop, ma_giang_vien)
);

CREATE TABLE ket_qua_hoc_tap (
    ma_lop CHAR(20) NOT NULL,
    mssv INT NOT NULL,
    diem_qua_trinh NUMERIC(4,2),
    diem_giua_ki NUMERIC(4,2),
    diem_thuc_hanh NUMERIC(4,2),
    diem_cuoi_ki NUMERIC(4,2),
    diem_tong_ket NUMERIC(4,2), -- Sẽ được tính bằng trigger
    ghi_chu VARCHAR(20),
    PRIMARY KEY (ma_lop, mssv),
    FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv),
    FOREIGN KEY (ma_lop) REFERENCES bang_diem(ma_lop)
);


CREATE TABLE hoc_phi
(
	mssv INT NOT NULL,
	hoc_ky char(11) NOT NULL, --Vi du: 2023-2024_1
	so_tin_chi int ,
	don_gia_tin_chi int , --Don gia cho 1 tin chi
	hoc_phi NUMERIC(12,2) , --So tien hoc phi can dong
	no_hoc_ky_truoc float , --No hoc phi cua hoc ky truoc
	da_dong float , --So tien da dong
	so_tien_con_lai float , --So tien con lai can dong/con thua
	PRIMARY KEY (mssv, hoc_ky),
	FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv)
)
-- Update so tien da dong
UPDATE hoc_phi
SET da_dong = 17000000.00
WHERE mssv = '21520541' AND hoc_ky = '2022_2023_1';

-- Update so tien da dong
UPDATE hoc_phi
SET hoc_phi = 17000000.00
WHERE mssv = '21520541' AND hoc_ky = '2022_2023_1';

CREATE TABLE dang_ky_gui_xe
(
	mssv INT NOT NULL, --Ma so sinh vien
	ngay_dang_ky DATE NOT NULL, --Ngay dang ky gui xe
	ngay_thanh_toan DATE, --Ngay thanh toan
	so_tien NUMERIC(12,2), --So tien thanh toan
	so_thang float, --So thang gui xe
	ma_bien_so VARCHAR(10) NOT NULL, --Ma bien so xe
	tinh_trang VARCHAR(20) NOT NULL, --Tinh trang dang ky (Da dang ky, Da thanh toan, Da xoa)
	ngay_het_han DATE NOT NULL, --Ngay het han dang ky
	PRIMARY KEY (mssv, ma_bien_so),
	FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv)	
)

CREATE TABLE xac_nhan_chung_chi
(
	mssv INT NOT NULL, -- Ma so sinh vien
	ma_chung_chi VARCHAR(20) NOT NULL, -- Ma chung chi
	loai_chung_chi VARCHAR(20) NOT NULL, -- Loai chung chi (Ngoai ngu, Tin hoc, ...)
	ngay_thi DATE NOT NULL, -- Ngay thi chung chi
	tinh_trang VARCHAR(20) NOT NULL, -- Tinh trang chung chi (Da xac nhan, Da xoa, cho duyet)
	ngay_dang_ky DATE NOT NULL, -- Ngay dang ky cap chung chi
	ghi_chu VARCHAR(100), -- Ghi chu ve chung chi
	PRIMARY KEY (mssv, ma_chung_chi),
	FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv)
)

CREATE TABLE thong_bao
(
	id SERIAL PRIMARY KEY, -- Ma so thong bao
	tieu_de VARCHAR(100) NOT NULL, -- Tieu de thong bao
	noi_dung TEXT NOT NULL, -- Noi dung thong bao
	ngay_tao DATE NOT NULL, -- Ngay tao thong bao
	ngay_cap_nhat DATE NOT NULL -- Ngay cap nhat thong bao
);

CREATE TABLE bao_nghi_day
(
	id SERIAL PRIMARY KEY, -- Ma so bao nghi
	ma_lop char(20) NOT NULL, -- Ma lop hoc
	ma_giang_vien char(5), -- Vi du: 80001
	ly_do VARCHAR(200), -- Ly do bao nghi
	ngay_nghi DATE, -- Ngay bao nghi
	tinh_trang VARCHAR(20), -- Tinh trang bao nghi (Da duyet, Cho duyet)
	FOREIGN KEY (ma_lop, ma_giang_vien) REFERENCES thoi_khoa_bieu(ma_lop, ma_giang_vien)
);

CREATE TABLE bao_hoc_bu
(
	id SERIAL PRIMARY KEY, -- Ma so bao hoc bu
	ma_lop char(20) NOT NULL, -- Ma lop hoc
	ly_do VARCHAR(200) NOT NULL, -- Ly do bao hoc bu
	ngay_hoc_bu DATE NOT NULL, -- Ngay hoc bu
	tiet_bat_dau int NOT NULL, -- Tiet bat dau hoc bu
	tiet_ket_thuc int NOT NULL, -- Tiet ket thuc hoc bu
	tinh_trang VARCHAR(20) NOT NULL, -- Tinh trang bao hoc bu (Da duyet, Chua duyet)
	FOREIGN KEY (ma_lop) REFERENCES thoi_khoa_bieu(ma_lop)
);

CREATE TABLE lich_thi 
(
	ma_mon_hoc char(8) NOT NULL, -- Ma mon hoc
	ma_lop char(20) NOT NULL, -- Ma lop hoc
	ma_giang_vien char(5), -- Ma giang vien, co the bo trong neu khong co
	ngay_thi DATE NOT NULL, -- Ngay thi
	ca_thi int NOT NULL, -- Ca thi (1, 2, 3, 4)
	phong_thi varchar(10) NOT NULL, -- Phong thi

	hinh_thuc_thi VARCHAR(20) DEFAULT NULL, -- Hinh thuc thi (Do an, Van dap,...), bo trong neu thi tap trung
	gk_ck char(2), -- Thi giua ky hay cuoi ky
	
	PRIMARY KEY (ma_lop, phong_thi),
	FOREIGN KEY (ma_mon_hoc) REFERENCES mon_hoc(ma_mon_hoc),
	FOREIGN KEY (ma_lop, ma_giang_vien) REFERENCES thoi_khoa_bieu(ma_lop, ma_giang_vien)
);

CREATE TABLE coi_thi
(
	ma_lop char(20) NOT NULL, -- Ma lop hoc
	phong_thi varchar(10) NOT NULL, -- Phong thi
	giam_thi_1 char(5), -- Ma so giam thi 1
	giam_thi_2 char(5), -- Ma so giam thi 2, -- Co the bo trong neu chi co 1 giam thi

	PRIMARY KEY (ma_lop, phong_thi),
	FOREIGN KEY (ma_lop, phong_thi) REFERENCES lich_thi(ma_lop, phong_thi),
	FOREIGN KEY (giam_thi_1) REFERENCES giang_vien(ma_giang_vien) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (giam_thi_2) REFERENCES giang_vien(ma_giang_vien) ON DELETE SET NULL

)

--Nhom bang diem ren luyen
CREATE TABLE tieu_chi
(
	tieu_chi char(5) PRIMARY KEY, -- Ma so tieu chi, vi du 1.1, 1.2, 2.1, ...
	ten_tieu_chi VARCHAR(255) NOT NULL, -- Ten tieu chi
	tieu_chi_cha char(5), -- Tieu chi cha, NULL neu khong co; dung de tao quan he phan cap giua cac tieu chi (hierarchical relationship)
	diem_toi_da int NOT NULL, -- Diem toi da dat cho tieu chi

	FOREIGN KEY (tieu_chi_cha) REFERENCES tieu_chi(tieu_chi)

)

CREATE TABLE hoat_dong_ren_luyen
(
	ma_hoat_dong SERIAL PRIMARY KEY, -- Ma so hoat dong ren luyen
	tieu_chi char(5) NOT NULL, -- Ma so tieu chi
	ten_hoat_dong VARCHAR(100) NOT NULL, -- Ten hoat dong
	diem int NOT NULL, -- Diem dat duoc cho hoat dong
	ngay_bat_dau DATE NOT NULL, -- Ngay bat dau hoat dong
	ngay_ket_thuc DATE NOT NULL, -- Ngay ket thuc hoat dong
	ghi_chu VARCHAR(255), -- Ghi chu ve hoat dong

	FOREIGN KEY (tieu_chi) REFERENCES tieu_chi(tieu_chi)

);

CREATE TABLE chi_tiet_hoat_dong_ren_luyen
(
	mssv INT NOT NULL, -- Ma so sinh vien
	ma_hoat_dong INT NOT NULL, -- Ma so hoat dong ren luyen
	he_so_tham_gia int NOT NULL, -- Diem dat duoc cho hoat dong
	diem int NOT NULL, -- Diem dat duoc cho hoat dong
	ghi_chu VARCHAR(255), -- Ghi chu ve hoat dong

	PRIMARY KEY (mssv, ma_hoat_dong),
	FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv),
	FOREIGN KEY (ma_hoat_dong) REFERENCES hoat_dong_ren_luyen(ma_hoat_dong)
);






