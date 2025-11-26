-- Create personal_events table for student personal schedule
CREATE TABLE IF NOT EXISTS personal_events (
    event_id SERIAL PRIMARY KEY,
    mssv INTEGER NOT NULL,
    event_name VARCHAR(255) NOT NULL,
    time TIMESTAMP NOT NULL,
    location VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_personal_events_mssv FOREIGN KEY (mssv) REFERENCES sinh_vien(mssv) ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_personal_events_mssv ON personal_events(mssv);
CREATE INDEX IF NOT EXISTS idx_personal_events_time ON personal_events(time);

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_personal_events_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_personal_events_updated_at
    BEFORE UPDATE ON personal_events
    FOR EACH ROW
    EXECUTE FUNCTION update_personal_events_updated_at();

-- Add comments for documentation
COMMENT ON TABLE personal_events IS 'Table to store student personal events/schedules';
COMMENT ON COLUMN personal_events.event_id IS 'Unique identifier for each personal event';
COMMENT ON COLUMN personal_events.mssv IS 'Student ID (foreign key to sinh_vien table)';
COMMENT ON COLUMN personal_events.event_name IS 'Name of the personal event';
COMMENT ON COLUMN personal_events.time IS 'Date and time of the event';
COMMENT ON COLUMN personal_events.location IS 'Location where the event takes place';
COMMENT ON COLUMN personal_events.description IS 'Additional details about the event';
COMMENT ON COLUMN personal_events.created_at IS 'Timestamp when the event was created';
COMMENT ON COLUMN personal_events.updated_at IS 'Timestamp when the event was last updated';
