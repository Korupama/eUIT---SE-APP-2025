CREATE TABLE van_ban (
    ten_van_ban VARCHAR(255) PRIMARY KEY,
    url_van_ban VARCHAR(255) NOT NULL, -- Đường dẫn tương đối, ví dụ: /Regulations/QuyCheHocVu_2025.pdf
    ngay_ban_hanh DATE
);

CREATE TABLE bai_viet (
    tieu_de TEXT PRIMARY KEY,       -- Tiêu đề của bài viết
    url_bai_viet VARCHAR(255) NOT NULL,    -- Đường dẫn tới bài viết
    ngay_dang TIMESTAMPTZ DEFAULT NOW()  -- Ngày đăng bài
);

INSERT INTO bai_viet (tieu_de, url_bai_viet, ngay_dang)
VALUES ('Thông báo về việc thu học phí học kỳ 1, NH 2025-2026 trình độ ĐTĐH - K2025', 'https://daa.uit.edu.vn/thong-bao-ve-viec-thu-hoc-phi-hoc-ky-1-nh-2025-2026-trinh-do-dtdh-k2025','2025-08-26');

INSERT INTO bai_viet (tieu_de, url_bai_viet, ngay_dang)
VALUES ('Thông báo thu học phí học kỳ 1, năm học 2025-2026 - Khóa 2024 trở về trước', 'https://daa.uit.edu.vn/thong-bao-thu-hoc-phi-hoc-ky-1-nam-hoc-2025-2026-khoa-2024-tro-ve-truoc','2025-08-26');

INSERT INTO bai_viet (tieu_de, url_bai_viet, ngay_dang)
VALUES ('Những điều cần biết về kỳ thi tiếng Anh đầu vào cho tân SV Khóa năm 2025', 'https://daa.uit.edu.vn/nhung-dieu-can-biet-ve-ky-thi-tieng-anh-dau-vao-cho-tan-sv-khoa-nam-2025','2025-08-31');

INSERT INTO bai_viet (tieu_de, url_bai_viet, ngay_dang)
VALUES ('Thông báo lịch thi Kỹ năng nói ngày 08/9/2025 - dành cho sinh viên thi anh văn đầu vào năm 2025', 'https://daa.uit.edu.vn/thong-bao-lich-thi-ky-nang-noi-ngay-0892025-danh-cho-sinh-vien-thi-anh-van-dau-vao-nam-2025','2025-09-06');

INSERT INTO bai_viet (tieu_de, url_bai_viet, ngay_dang)
VALUES ('Thông báo Quyết định công nhận Tốt nghiệp đợt 3 năm 2025', 'https://daa.uit.edu.vn/thong-bao-quyet-dinh-cong-nhan-tot-nghiep-dot-3-nam-2025','2025-09-11');

-- Hàm trả về 3 bài viết mới nhất
CREATE OR REPLACE FUNCTION get_latest_bai_viet()
RETURNS TABLE (
    tieu_de TEXT,
    url_bai_viet VARCHAR,
    ngay_dang TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM bai_viet
    ORDER BY ngay_dang DESC
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;

SELECT * from get_latest_bai_viet();

