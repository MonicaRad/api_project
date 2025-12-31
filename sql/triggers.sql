CREATE TABLE IF NOT EXISTS log_track_updates (
    id SERIAL PRIMARY KEY,
    track_id VARCHAR(200),
    action TEXT,
    changed_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION track_log_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_track_updates(track_id, action)
    VALUES (NEW.track_id, TG_OP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trk_update_log ON track;

CREATE TRIGGER trk_update_log
AFTER UPDATE ON track
FOR EACH ROW
EXECUTE FUNCTION track_log_update();

DROP TRIGGER IF EXISTS trk_insert_log ON track;

CREATE TRIGGER trk_insert_log
AFTER INSERT ON track
FOR EACH ROW
EXECUTE FUNCTION track_log_update();
