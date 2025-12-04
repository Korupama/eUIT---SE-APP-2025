BEGIN;

-- 1) Truncate existing data with CASCADE to handle FKs (e.g., coi_thi -> lich_thi)
TRUNCATE TABLE lich_thi RESTART IDENTITY CASCADE;

-- 2) Import midterm (giữa kỳ)
COPY lich_thi FROM '/Users/home/Documents/GitHub/eUIT---SE-APP-2025/scripts/database/other_data/lich_thi_giua_ky_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- 3) Import final (cuối kỳ)
COPY lich_thi FROM '/Users/home/Documents/GitHub/eUIT---SE-APP-2025/scripts/database/other_data/lich_thi_cuoi_ky_clean.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

COMMIT;
