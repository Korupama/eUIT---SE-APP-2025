-- ============================================================================
-- SCRIPT: Insert test lecture schedule data
-- PURPOSE: Add TEST1-TEST9 courses for lecturer testing
-- SCHEDULE: Starting 12/2025, running for 6 months
-- ============================================================================

-- Insert test courses into mon_hoc
INSERT INTO mon_hoc (ma_mon_hoc, ten_mon_hoc_vn, ten_mon_hoc_en, so_tc_ly_thuyet, so_tc_thuc_hanh)
VALUES 
  ('TEST01', 'Môn Test 1', 'Test Course 1', 3, 0),
  ('TEST02', 'Môn Test 2', 'Test Course 2', 3, 0),
  ('TEST03', 'Môn Test 3', 'Test Course 3', 3, 0),
  ('TEST04', 'Môn Test 4', 'Test Course 4', 3, 0),
  ('TEST05', 'Môn Test 5', 'Test Course 5', 3, 0),
  ('TEST06', 'Môn Test 6', 'Test Course 6', 3, 0),
  ('TEST07', 'Môn Test 7', 'Test Course 7', 3, 0),
  ('TEST08', 'Môn Test 8', 'Test Course 8', 3, 0),
  ('TEST09', 'Môn Test 9', 'Test Course 9', 3, 0)
ON CONFLICT (ma_mon_hoc) DO NOTHING;

-- Insert test schedule classes in thoi_khoa_bieu
-- Using lecturer 80001 (Nguyễn Minh Nam)
-- Schedule: Each class meets on different day/time, starting 12/2025 for 6 months
INSERT INTO thoi_khoa_bieu (
  hoc_ky, ma_mon_hoc, ma_lop, so_tin_chi, ma_giang_vien, 
  thu, tiet_bat_dau, tiet_ket_thuc, cach_tuan, 
  ngay_bat_dau, ngay_ket_thuc, phong_hoc, si_so, hinh_thuc_giang_day, ghi_chu
)
VALUES 
  ('2025_2026_1', 'TEST01', 'TEST01.Q11', 3, '80001', '2', 1, 3, 1, '2025-12-01', '2026-05-31', 'A101', 50, 'LT', 'Test course 1'),
  ('2025_2026_1', 'TEST02', 'TEST02.Q11', 3, '80001', '3', 4, 6, 1, '2025-12-01', '2026-05-31', 'A102', 50, 'LT', 'Test course 2'),
  ('2025_2026_1', 'TEST03', 'TEST03.Q11', 3, '80001', '4', 7, 9, 1, '2025-12-01', '2026-05-31', 'B101', 50, 'LT', 'Test course 3'),
  ('2025_2026_1', 'TEST04', 'TEST04.Q11', 3, '80001', '5', 1, 3, 1, '2025-12-01', '2026-05-31', 'B102', 50, 'LT', 'Test course 4'),
  ('2025_2026_1', 'TEST05', 'TEST05.Q11', 3, '80001', '2', 4, 6, 1, '2025-12-01', '2026-05-31', 'C101', 50, 'LT', 'Test course 5'),
  ('2025_2026_1', 'TEST06', 'TEST06.Q11', 3, '80001', '3', 7, 9, 1, '2025-12-01', '2026-05-31', 'C102', 50, 'LT', 'Test course 6'),
  ('2025_2026_1', 'TEST07', 'TEST07.Q11', 3, '80001', '4', 1, 3, 1, '2025-12-01', '2026-05-31', 'D101', 50, 'LT', 'Test course 7'),
  ('2025_2026_1', 'TEST08', 'TEST08.Q11', 3, '80001', '5', 4, 6, 1, '2025-12-01', '2026-05-31', 'D102', 50, 'LT', 'Test course 8'),
  ('2025_2026_1', 'TEST09', 'TEST09.Q11', 3, '80001', '2', 7, 9, 1, '2025-12-01', '2026-05-31', 'E101', 50, 'LT', 'Test course 9')
ON CONFLICT (ma_lop, ma_giang_vien) DO NOTHING;

-- Optional: Add grade weight configuration for these test courses
INSERT INTO bang_diem (ma_lop_goc, trong_so_qua_trinh, trong_so_giua_ki, trong_so_thuc_hanh, trong_so_cuoi_ki)
VALUES 
  ('TEST01.Q11', 10, 30, 20, 40),
  ('TEST02.Q11', 10, 30, 20, 40),
  ('TEST03.Q11', 10, 30, 20, 40),
  ('TEST04.Q11', 10, 30, 20, 40),
  ('TEST05.Q11', 10, 30, 20, 40),
  ('TEST06.Q11', 10, 30, 20, 40),
  ('TEST07.Q11', 10, 30, 20, 40),
  ('TEST08.Q11', 10, 30, 20, 40),
  ('TEST09.Q11', 10, 30, 20, 40)
ON CONFLICT (ma_lop_goc) DO NOTHING;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Verify courses were created
-- SELECT ma_mon_hoc, ten_mon_hoc_vn FROM mon_hoc WHERE ma_mon_hoc LIKE 'TEST%' ORDER BY ma_mon_hoc;

-- Verify schedule was created for lecturer 80001
-- SELECT ma_lop, thu, tiet_bat_dau, tiet_ket_thuc, ngay_bat_dau, ngay_ket_thuc, phong_hoc 
-- FROM thoi_khoa_bieu 
-- WHERE ma_giang_vien = '80001' AND ma_mon_hoc LIKE 'TEST%'
-- ORDER BY ma_lop;

-- Verify grade weights
-- SELECT ma_lop, trong_so_qua_trinh, trong_so_giua_ki, trong_so_thuc_hanh, trong_so_cuoi_ki
-- FROM bang_diem 
-- WHERE ma_lop LIKE 'TEST%'
-- ORDER BY ma_lop;
