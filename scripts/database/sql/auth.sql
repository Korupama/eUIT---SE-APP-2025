--language plpgsql;

-- Tập tin: scripts/database/sql/auth.sql
-- Mục đích: Định nghĩa các bảng và hàm/procedure hỗ trợ xác thực (authentication)
-- Lưu ý bảo mật: sử dụng pgcrypto để hash mật khẩu (bcrypt) và lưu hash của token (SHA-256).

-- Kích hoạt extension cần thiết. Yêu cầu quyền SUPERUSER để cài đặt extension lần đầu.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Kiểu role dùng trong các hàm (student = sinh viên, lecturer = giảng viên, admin = quản trị)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'auth_user_role') THEN
        CREATE TYPE auth_user_role AS ENUM ('student','lecturer','admin');
    END IF;
END$$;

-- Bảng tài khoản cho từng loại người dùng. Giữ tách biệt theo hệ thống hiện có nhưng đồng nhất các cột quản lý bảo mật.
-- Lưu mật khẩu dưới dạng hash (bcrypt) trong cột password_hash.
CREATE TABLE IF NOT EXISTS tai_khoan_sinh_vien (
    mssv bigint PRIMARY KEY,
    password_hash text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    last_login timestamptz,
    failed_attempts integer NOT NULL DEFAULT 0,
    locked_until timestamptz
);

CREATE TABLE IF NOT EXISTS tai_khoan_giang_vien (
    ma_giang_vien text PRIMARY KEY,
    password_hash text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    last_login timestamptz,
    failed_attempts integer NOT NULL DEFAULT 0,
    locked_until timestamptz
);

CREATE TABLE IF NOT EXISTS tai_khoan_quan_tri (
    tai_khoan text PRIMARY KEY,
    password_hash text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    last_login timestamptz,
    failed_attempts integer NOT NULL DEFAULT 0,
    locked_until timestamptz
);

-- Bảng lưu refresh token / session token. Lưu hash của token (không lưu token plaintext) để giảm rủi ro khi DB bị lộ.
CREATE TABLE IF NOT EXISTS auth_refresh_tokens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_role auth_user_role NOT NULL,
    user_id text NOT NULL, -- lưu dạng text để chứa mssv hoặc mã giảng viên hoặc tên tài khoản
    token_hash text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    revoked boolean NOT NULL DEFAULT false,
    replaced_by uuid
);
CREATE INDEX IF NOT EXISTS idx_auth_refresh_tokens_token_hash ON auth_refresh_tokens(token_hash);

-- Bảng lưu token reset mật khẩu (hash), sử dụng 1 lần và có hạn.
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_role auth_user_role NOT NULL,
    user_id text NOT NULL,
    token_hash text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    used boolean NOT NULL DEFAULT false
);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_hash ON password_reset_tokens(token_hash);

-- =========================
-- Hàm hỗ trợ: hash & verify mật khẩu
-- =========================
-- hash_password: tạo bcrypt hash từ password plaintext
CREATE OR REPLACE FUNCTION auth_hash_password(p_password text)
RETURNS text
LANGUAGE sql
AS $$
    SELECT crypt(p_password, gen_salt('bf', 12));
$$;

-- verify: kiểm tra password plaintext so với bcrypt hash
CREATE OR REPLACE FUNCTION auth_verify_password(p_password text, p_hash text)
RETURNS boolean
LANGUAGE sql
AS $$
    SELECT crypt(p_password, p_hash) = p_hash;
$$;

-- =========================
-- Hàm tạo tài khoản (an toàn): kiểm tra tồn tại, hash mật khẩu
-- =========================
CREATE OR REPLACE FUNCTION create_student_account(p_mssv bigint, p_password text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_password IS NULL OR length(trim(p_password)) < 8 THEN
        RAISE EXCEPTION 'Mật khẩu quá ngắn (cần >=8 ký tự)';
    END IF;
    IF EXISTS (SELECT 1 FROM tai_khoan_sinh_vien WHERE mssv = p_mssv) THEN
        RAISE EXCEPTION 'Tài khoản sinh viên % đã tồn tại', p_mssv;
    END IF;
    INSERT INTO tai_khoan_sinh_vien(mssv, password_hash)
    VALUES (p_mssv, auth_hash_password(p_password));
END;
$$;
-- Tạo 8 tài khoản sinh viên từ 23520541 đến 23520548 với mật khẩu mặc định 'Password123'
SELECT create_student_account(23520541, 'PasswordA1!');
SELECT create_student_account(23520542, 'PasswordB2@');
SELECT create_student_account(23520543, 'PasswordC3#');
SELECT create_student_account(23520544, 'PasswordD4$');
SELECT create_student_account(23520545, 'PasswordE5%');
SELECT create_student_account(23520546, 'PasswordF6^');
SELECT create_student_account(23520547, 'PasswordG7&');
SELECT create_student_account(23520548, 'PasswordH8*');



CREATE OR REPLACE FUNCTION create_lecturer_account(p_ma_giang_vien text, p_password text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_password IS NULL OR length(trim(p_password)) < 8 THEN
        RAISE EXCEPTION 'Mật khẩu quá ngắn (cần >=8 ký tự)';
    END IF;
    IF EXISTS (SELECT 1 FROM tai_khoan_giang_vien WHERE ma_giang_vien = p_ma_giang_vien) THEN
        RAISE EXCEPTION 'Tài khoản giảng viên % đã tồn tại', p_ma_giang_vien;
    END IF;
    INSERT INTO tai_khoan_giang_vien(ma_giang_vien, password_hash)
    VALUES (p_ma_giang_vien, auth_hash_password(p_password));
END;
$$;

CREATE OR REPLACE FUNCTION create_admin_account(p_tai_khoan text, p_password text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_password IS NULL OR length(trim(p_password)) < 10 THEN
        RAISE EXCEPTION 'Mật khẩu quản trị nên >=10 ký tự';
    END IF;
    IF EXISTS (SELECT 1 FROM tai_khoan_quan_tri WHERE tai_khoan = p_tai_khoan) THEN
        RAISE EXCEPTION 'Tài khoản quản trị % đã tồn tại', p_tai_khoan;
    END IF;
    INSERT INTO tai_khoan_quan_tri(tai_khoan, password_hash)
    VALUES (p_tai_khoan, auth_hash_password(p_password));
END;
$$;

-- =========================
-- Hàm xác thực (authenticate) theo role chung
-- Trả về TRUE nếu mật khẩu khớp. Đồng thời xử lý failed_attempts, locked_until, last_login.
-- Quy tắc khóa: sau 5 lần thất bại liên tiếp, khoá 15 phút (có thể điều chỉnh).
-- =========================
CREATE OR REPLACE FUNCTION auth_authenticate(p_role auth_user_role, p_user_id text, p_password text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    v_hash text;
    v_locked timestamptz;
    v_failed int;
    v_now timestamptz := now();
    v_allowed_failures constant int := 5;
    v_lock_duration interval := '60 minutes';
BEGIN
    -- Lấy hash tương ứng theo role
    IF p_role = 'student'::auth_user_role THEN
        SELECT password_hash, locked_until, failed_attempts INTO v_hash, v_locked, v_failed
        FROM tai_khoan_sinh_vien WHERE mssv = p_user_id::bigint;
    ELSIF p_role = 'lecturer'::auth_user_role THEN
        SELECT password_hash, locked_until, failed_attempts INTO v_hash, v_locked, v_failed
        FROM tai_khoan_giang_vien WHERE ma_giang_vien = p_user_id;
    ELSIF p_role = 'admin'::auth_user_role THEN
        SELECT password_hash, locked_until, failed_attempts INTO v_hash, v_locked, v_failed
        FROM tai_khoan_quan_tri WHERE tai_khoan = p_user_id;
    ELSE
        RAISE EXCEPTION 'Role không hợp lệ';
    END IF;

    IF v_hash IS NULL THEN
        -- Không lộ thông tin: trả về false khi không tồn tại
        RETURN false;
    END IF;

    -- Kiểm tra khóa
    IF v_locked IS NOT NULL AND v_locked > v_now THEN
        RETURN false; -- đang bị khoá
    END IF;

    -- Kiểm tra mật khẩu
    IF auth_verify_password(p_password, v_hash) THEN
        -- Thành công: reset failed_attempts, update last_login
        IF p_role = 'student'::auth_user_role THEN
            UPDATE tai_khoan_sinh_vien SET failed_attempts = 0, locked_until = NULL, last_login = v_now
            WHERE mssv = p_user_id::bigint;
        ELSIF p_role = 'lecturer'::auth_user_role THEN
            UPDATE tai_khoan_giang_vien SET failed_attempts = 0, locked_until = NULL, last_login = v_now
            WHERE ma_giang_vien = p_user_id;
        ELSE
            UPDATE tai_khoan_quan_tri SET failed_attempts = 0, locked_until = NULL, last_login = v_now
            WHERE tai_khoan = p_user_id;
        END IF;
        RETURN true;
    ELSE
        -- Thất bại: tăng failed_attempts và có thể khoá
        v_failed := COALESCE(v_failed, 0) + 1;
        IF p_role = 'student'::auth_user_role THEN
            UPDATE tai_khoan_sinh_vien SET failed_attempts = v_failed WHERE mssv = p_user_id::bigint;
        ELSIF p_role = 'lecturer'::auth_user_role THEN
            UPDATE tai_khoan_giang_vien SET failed_attempts = v_failed WHERE ma_giang_vien = p_user_id;
        ELSE
            UPDATE tai_khoan_quan_tri SET failed_attempts = v_failed WHERE tai_khoan = p_user_id;
        END IF;

        IF v_failed >= v_allowed_failures THEN
            -- đặt thời gian khoá
            IF p_role = 'student'::auth_user_role THEN
                UPDATE tai_khoan_sinh_vien SET locked_until = v_now + v_lock_duration WHERE mssv = p_user_id::bigint;
            ELSIF p_role = 'lecturer'::auth_user_role THEN
                UPDATE tai_khoan_giang_vien SET locked_until = v_now + v_lock_duration WHERE ma_giang_vien = p_user_id;
            ELSE
                UPDATE tai_khoan_quan_tri SET locked_until = v_now + v_lock_duration WHERE tai_khoan = p_user_id;
            END IF;
        END IF;

        RETURN false;
    END IF;
END;
$$;

-- =========================
-- Refresh token APIs: tạo, validate, revoke
-- Lưu ý: client nên tạo token ngẫu nhiên đủ dài (ví dụ 256-bit) và gửi plaintext vào hàm issue để lưu hash.
-- =========================

-- issue_refresh_token: lưu hash của token plaintext và trả về id
CREATE OR REPLACE FUNCTION issue_refresh_token(p_role auth_user_role, p_user_id text, p_token_plain text, p_ttl interval)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    v_hash text := encode(digest(p_token_plain, 'sha256'), 'hex');
    v_id uuid;
BEGIN
    INSERT INTO auth_refresh_tokens(user_role, user_id, token_hash, expires_at)
    VALUES (p_role, p_user_id, v_hash, now() + p_ttl)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$;

-- validate_refresh_token: kiểm tra token plaintext, trả về role,user_id nếu hợp lệ
CREATE OR REPLACE FUNCTION validate_refresh_token(p_token_plain text)
RETURNS TABLE(token_id uuid, user_role auth_user_role, user_id text)
LANGUAGE plpgsql
AS $$
DECLARE
    v_hash text := encode(digest(p_token_plain, 'sha256'), 'hex');
BEGIN
    RETURN QUERY
    SELECT id, user_role, user_id
    FROM auth_refresh_tokens
    WHERE token_hash = v_hash
      AND revoked = false
      AND expires_at > now();
END;
$$;

-- revoke_refresh_token_by_plain: đánh dấu revoked = true theo token plaintext
CREATE OR REPLACE FUNCTION revoke_refresh_token_by_plain(p_token_plain text)
RETURNS void
LANGUAGE sql
AS $$
    UPDATE auth_refresh_tokens SET revoked = true WHERE token_hash = encode(digest(p_token_plain, 'sha256'), 'hex');
$$;

-- revoke_refresh_token_by_id
CREATE OR REPLACE FUNCTION revoke_refresh_token_by_id(p_id uuid)
RETURNS void
LANGUAGE sql
AS $$
    UPDATE auth_refresh_tokens SET revoked = true WHERE id = p_id;
$$;

-- =========================
-- Password reset flow
-- - initiate_password_reset: tạo token (plaintext trả về để gửi email), lưu hash vào DB
-- - reset_password_with_token: xác thực token, set mật khẩu mới và mark token used
-- =========================

CREATE OR REPLACE FUNCTION initiate_password_reset(p_role auth_user_role, p_user_id text, p_ttl interval DEFAULT '1 hour')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    v_plain text := encode(gen_random_bytes(32), 'hex'); -- token plaintext (64 hex chars ~ 256 bit)
    v_hash text := encode(digest(v_plain, 'sha256'), 'hex');
BEGIN
    INSERT INTO password_reset_tokens(user_role, user_id, token_hash, expires_at)
    VALUES (p_role, p_user_id, v_hash, now() + p_ttl);
    -- Trả về token plaintext cho ứng dụng gửi email. Ứng dụng KHÔNG lưu token này ở server.
    RETURN v_plain;
END;
$$;

CREATE OR REPLACE FUNCTION reset_password_with_token(p_role auth_user_role, p_user_id text, p_token_plain text, p_new_password text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    v_hash text := encode(digest(p_token_plain, 'sha256'), 'hex');
    v_row password_reset_tokens%ROWTYPE;
BEGIN
    SELECT * INTO v_row FROM password_reset_tokens
    WHERE token_hash = v_hash AND user_role = p_role AND user_id = p_user_id LIMIT 1;

    IF NOT FOUND THEN
        RETURN false;
    END IF;

    IF v_row.used THEN
        RETURN false;
    END IF;

    IF v_row.expires_at < now() THEN
        RETURN false;
    END IF;

    -- Cập nhật password cho người dùng
    IF p_role = 'student'::auth_user_role THEN
        UPDATE tai_khoan_sinh_vien SET password_hash = auth_hash_password(p_new_password), failed_attempts = 0, locked_until = NULL
        WHERE mssv = p_user_id::bigint;
    ELSIF p_role = 'lecturer'::auth_user_role THEN
        UPDATE tai_khoan_giang_vien SET password_hash = auth_hash_password(p_new_password), failed_attempts = 0, locked_until = NULL
        WHERE ma_giang_vien = p_user_id;
    ELSE
        UPDATE tai_khoan_quan_tri SET password_hash = auth_hash_password(p_new_password), failed_attempts = 0, locked_until = NULL
        WHERE tai_khoan = p_user_id;
    END IF;

    -- Đánh dấu token đã dùng
    UPDATE password_reset_tokens SET used = true WHERE id = v_row.id;
    RETURN true;
END;
$$;

-- =========================
-- Tiện ích: thay đổi mật khẩu khi biết mật khẩu cũ
-- =========================
CREATE OR REPLACE FUNCTION change_password(p_role auth_user_role, p_user_id text, p_old_password text, p_new_password text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT auth_authenticate(p_role, p_user_id, p_old_password) THEN
        RETURN false;
    END IF;
    -- Cập nhật mật khẩu mới
    IF p_role = 'student'::auth_user_role THEN
        UPDATE tai_khoan_sinh_vien SET password_hash = auth_hash_password(p_new_password) WHERE mssv = p_user_id::bigint;
    ELSIF p_role = 'lecturer'::auth_user_role THEN
        UPDATE tai_khoan_giang_vien SET password_hash = auth_hash_password(p_new_password) WHERE ma_giang_vien = p_user_id;
    ELSE
        UPDATE tai_khoan_quan_tri SET password_hash = auth_hash_password(p_new_password) WHERE tai_khoan = p_user_id;
    END IF;
    RETURN true;
END;
$$;



-- =========================
-- Gợi ý và chú ý vận hành (comment bằng tiếng Việt):
/*
 - Lưu ý: Các hàm trên dùng extension pgcrypto; cần cài trên môi trường production.
 - Token (refresh/password reset) được tạo ở ứng dụng (client/server) bằng random secure bytes (thường gen_random_bytes) và plaintext được gửi đến hàm để lưu hash. Ứng dụng chịu trách nhiệm gửi token cho người dùng (email/SMS) và KHÔNG lưu plaintext lâu dài.
 - Không lưu mật khẩu plaintext ở bất kỳ đâu.
 - Có thể cân nhắc đặt SECURITY DEFINER cho một số hàm nếu muốn chúng chạy với quyền hạn định sẵn, nhưng cần review kỹ về bảo mật.
 - Các TTL (expiry) và policy (số lần sai, thời gian khoá) có thể điều chỉnh theo chính sách an ninh của tổ chức.
 - Ở tầng ứng dụng (API), khi trả về thông tin lỗi về xác thực, tránh đưa chi tiết: trả về chung chung "Tên đăng nhập hoặc mật khẩu không chính xác" để không giúp kẻ tấn công biết tài khoản tồn tại.
 - Nên thêm cơ chế logging (audit) bên ngoài DB cho các sự kiện đăng nhập/đổi mật khẩu nhạy cảm.
*/

