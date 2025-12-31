DROP FUNCTION IF EXISTS get_track_by_id(VARCHAR);
DROP FUNCTION IF EXISTS search_track(TEXT);
DROP FUNCTION IF EXISTS add_track(VARCHAR, VARCHAR, INTEGER, INTEGER, BOOLEAN, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS update_track_data(VARCHAR, VARCHAR, INTEGER, INTEGER, BOOLEAN, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS delete_track_data(VARCHAR);




-- Fonction 1 : récupérer un track par son id
CREATE OR REPLACE FUNCTION get_track_by_id(p_id VARCHAR)
RETURNS TABLE (
    track_id VARCHAR,
    track_name VARCHAR,
    track_number INTEGER,
    track_popularity INTEGER,
    explicit BOOLEAN,
    track_duration_min DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.track_id,
        t.track_name,
        t.track_number,
        t.track_popularity,
        t.explicit,
        t.track_duration_min
    FROM track t
    WHERE t.track_id = p_id;
END;
$$ LANGUAGE plpgsql;


-- Fonction 2 : rechercher un track par mot clé
CREATE OR REPLACE FUNCTION search_track(keyword TEXT)
RETURNS TABLE (
    track_id VARCHAR,
    track_name VARCHAR,
    track_popularity INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.track_id,
        t.track_name,
        t.track_popularity
    FROM track t
    WHERE LOWER(t.track_name) LIKE LOWER('%' || keyword || '%');
END;
$$ LANGUAGE plpgsql;


-- Fonction 3 : ajouter un track
CREATE OR REPLACE FUNCTION add_track(
    p_track_id VARCHAR,
    p_name VARCHAR,
    p_number INTEGER,
    p_popularity INTEGER,
    p_explicit BOOLEAN,
    p_duration DOUBLE PRECISION
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO track(
        track_id,
        track_name,
        track_number,
        track_popularity,
        explicit,
        track_duration_min
    ) VALUES (
        p_track_id,
        p_name,
        p_number,
        p_popularity,
        p_explicit,
        p_duration
    );
END;
$$ LANGUAGE plpgsql;


-- Fonction 4 : mettre à jour un track
CREATE OR REPLACE FUNCTION update_track_data(
    p_track_id VARCHAR,
    p_name VARCHAR DEFAULT NULL,
    p_number INTEGER DEFAULT NULL,
    p_popularity INTEGER DEFAULT NULL,
    p_explicit BOOLEAN DEFAULT NULL,
    p_duration DOUBLE PRECISION DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE track t SET
        track_name = COALESCE(p_name, t.track_name),
        track_number = COALESCE(p_number, t.track_number),
        track_popularity = COALESCE(p_popularity, t.track_popularity),
        explicit = COALESCE(p_explicit, t.explicit),
        track_duration_min = COALESCE(p_duration, t.track_duration_min)
    WHERE t.track_id = p_track_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;


-- Fonction 5 : supprimer un track
CREATE OR REPLACE FUNCTION delete_track_data(p_track_id VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM track t
    WHERE t.track_id = p_track_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
