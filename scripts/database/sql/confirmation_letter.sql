-- =============================================
-- CONFIRMATION LETTER TABLE AND FUNCTIONS
-- =============================================

-- Create confirmation_letters table if not exists
CREATE TABLE IF NOT EXISTS confirmation_letters (
    letter_id SERIAL PRIMARY KEY,
    mssv INTEGER NOT NULL REFERENCES sinh_vien(mssv) ON DELETE CASCADE,
    purpose VARCHAR(500) NOT NULL,
    language VARCHAR(2) NOT NULL DEFAULT 'vi' CHECK (language IN ('vi', 'en')),
    serial_number INTEGER NOT NULL,
    expiry_date TIMESTAMP,
    requested_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_confirmation_letters_mssv ON confirmation_letters(mssv);
CREATE INDEX IF NOT EXISTS idx_confirmation_letters_language ON confirmation_letters(language);

-- Function to request a confirmation letter with language support
CREATE OR REPLACE FUNCTION func_request_confirmation_letter(
    p_mssv INTEGER,
    p_purpose TEXT,
    p_language VARCHAR(2) DEFAULT 'vi'
)
RETURNS TABLE (
    so_thu_tu INTEGER,
    ngay_het_han TIMESTAMP
) AS $$
DECLARE
    v_serial_number INTEGER;
    v_expiry_date TIMESTAMP;
BEGIN
    -- Validate language
    IF p_language NOT IN ('vi', 'en') THEN
        RAISE EXCEPTION 'Language must be vi or en' USING ERRCODE = 'P0001';
    END IF;

    -- Validate student exists
    IF NOT EXISTS (SELECT 1 FROM sinh_vien WHERE mssv = p_mssv) THEN
        RAISE EXCEPTION 'Student with MSSV % does not exist', p_mssv USING ERRCODE = 'P0001';
    END IF;

    -- Validate purpose
    IF p_purpose IS NULL OR trim(p_purpose) = '' THEN
        RAISE EXCEPTION 'Purpose cannot be empty' USING ERRCODE = 'P0001';
    END IF;

    -- Generate serial number (incremental per year)
    SELECT COALESCE(MAX(serial_number), 0) + 1
    INTO v_serial_number
    FROM confirmation_letters
    WHERE EXTRACT(YEAR FROM requested_at) = EXTRACT(YEAR FROM NOW());

    -- Set expiry date (30 days from now)
    v_expiry_date := NOW() + INTERVAL '30 days';

    -- Insert new confirmation letter request
    INSERT INTO confirmation_letters (mssv, purpose, language, serial_number, expiry_date, requested_at)
    VALUES (p_mssv, p_purpose, p_language, v_serial_number, v_expiry_date, NOW());

    -- Return the result
    so_thu_tu := v_serial_number;
    ngay_het_han := v_expiry_date;
    
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Function to get confirmation letter history for a student
CREATE OR REPLACE FUNCTION func_get_confirmation_letter_history(
    p_mssv INTEGER
)
RETURNS TABLE (
    letter_id INTEGER,
    mssv INTEGER,
    purpose VARCHAR(500),
    language VARCHAR(2),
    serial_number INTEGER,
    expiry_date TIMESTAMP,
    requested_at TIMESTAMP,
    status VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cl.letter_id,
        cl.mssv,
        cl.purpose,
        cl.language,
        cl.serial_number,
        cl.expiry_date,
        cl.requested_at,
        CASE 
            WHEN cl.expiry_date IS NULL THEN 'active'
            WHEN cl.expiry_date >= NOW() THEN 'active'
            ELSE 'expired'
        END::VARCHAR(20) AS status
    FROM confirmation_letters cl
    WHERE cl.mssv = p_mssv
    ORDER BY cl.requested_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get all confirmation letters (admin use)
CREATE OR REPLACE FUNCTION func_get_all_confirmation_letters(
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    letter_id INTEGER,
    mssv INTEGER,
    ho_ten VARCHAR(100),
    purpose VARCHAR(500),
    language VARCHAR(2),
    serial_number INTEGER,
    expiry_date TIMESTAMP,
    requested_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cl.letter_id,
        cl.mssv,
        sv.ho_ten,
        cl.purpose,
        cl.language,
        cl.serial_number,
        cl.expiry_date,
        cl.requested_at
    FROM confirmation_letters cl
    JOIN sinh_vien sv ON cl.mssv = sv.mssv
    ORDER BY cl.requested_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON TABLE confirmation_letters IS 'Stores confirmation letter requests from students with language preference';
COMMENT ON COLUMN confirmation_letters.language IS 'Language preference: vi (Vietnamese) or en (English)';
COMMENT ON FUNCTION func_request_confirmation_letter IS 'Creates a new confirmation letter request with language support';
COMMENT ON FUNCTION func_get_confirmation_letter_history IS 'Retrieves confirmation letter history for a specific student';
COMMENT ON FUNCTION func_get_all_confirmation_letters IS 'Retrieves all confirmation letters with pagination (admin only)';

