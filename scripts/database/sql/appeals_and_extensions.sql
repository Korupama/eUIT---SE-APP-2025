-- Create appeals table for exam score appeals
CREATE TABLE IF NOT EXISTS appeals (
    id SERIAL PRIMARY KEY,
    mssv INTEGER NOT NULL,
    course_id VARCHAR(20) NOT NULL,
    reason TEXT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'awaiting_payment')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appeals_mssv FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv) ON DELETE CASCADE
);

-- Create tuition_extensions table for tuition payment extensions
CREATE TABLE IF NOT EXISTS tuition_extensions (
    id SERIAL PRIMARY KEY,
    mssv INTEGER NOT NULL,
    reason TEXT NOT NULL,
    desired_time TIMESTAMP NOT NULL,
    supporting_docs TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tuition_extensions_mssv FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_appeals_mssv ON appeals(mssv);
CREATE INDEX IF NOT EXISTS idx_appeals_status ON appeals(status);
CREATE INDEX IF NOT EXISTS idx_appeals_payment_status ON appeals(payment_status);

CREATE INDEX IF NOT EXISTS idx_tuition_extensions_mssv ON tuition_extensions(mssv);
CREATE INDEX IF NOT EXISTS idx_tuition_extensions_status ON tuition_extensions(status);
CREATE INDEX IF NOT EXISTS idx_tuition_extensions_desired_time ON tuition_extensions(desired_time);

-- Create trigger to auto-update updated_at for appeals
CREATE OR REPLACE FUNCTION update_appeals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_appeals_updated_at
    BEFORE UPDATE ON appeals
    FOR EACH ROW
    EXECUTE FUNCTION update_appeals_updated_at();

-- Create trigger to auto-update updated_at for tuition_extensions
CREATE OR REPLACE FUNCTION update_tuition_extensions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_tuition_extensions_updated_at
    BEFORE UPDATE ON tuition_extensions
    FOR EACH ROW
    EXECUTE FUNCTION update_tuition_extensions_updated_at();

-- Add comments for documentation
COMMENT ON TABLE appeals IS 'Table to store exam score appeal requests from students';
COMMENT ON COLUMN appeals.id IS 'Unique identifier for each appeal';
COMMENT ON COLUMN appeals.mssv IS 'Student ID (foreign key to sinh_vien table)';
COMMENT ON COLUMN appeals.course_id IS 'Course/Subject ID for the appeal';
COMMENT ON COLUMN appeals.reason IS 'Reason for the appeal';
COMMENT ON COLUMN appeals.payment_method IS 'Payment method chosen (banking, momo, vnpay, cash)';
COMMENT ON COLUMN appeals.payment_status IS 'Status of payment (pending, completed, failed)';
COMMENT ON COLUMN appeals.status IS 'Status of the appeal (pending, approved, rejected, awaiting_payment)';
COMMENT ON COLUMN appeals.created_at IS 'Timestamp when the appeal was created';
COMMENT ON COLUMN appeals.updated_at IS 'Timestamp when the appeal was last updated';

COMMENT ON TABLE tuition_extensions IS 'Table to store tuition payment extension requests';
COMMENT ON COLUMN tuition_extensions.id IS 'Unique identifier for each extension request';
COMMENT ON COLUMN tuition_extensions.mssv IS 'Student ID (foreign key to sinh_vien table)';
COMMENT ON COLUMN tuition_extensions.reason IS 'Reason for requesting extension';
COMMENT ON COLUMN tuition_extensions.desired_time IS 'Desired extension date';
COMMENT ON COLUMN tuition_extensions.supporting_docs IS 'Path to supporting document files';
COMMENT ON COLUMN tuition_extensions.status IS 'Status of the request (pending, approved, rejected)';
COMMENT ON COLUMN tuition_extensions.created_at IS 'Timestamp when the request was created';
COMMENT ON COLUMN tuition_extensions.updated_at IS 'Timestamp when the request was last updated';
