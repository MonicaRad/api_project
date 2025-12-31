-- Cette section supprime les tables existantes dans l ordre des dépendances pour garantir une réinitialisation propre
DROP TABLE IF EXISTS artist_album CASCADE;
DROP TABLE IF EXISTS artist_genre CASCADE;
DROP TABLE IF EXISTS track_album CASCADE;
DROP TABLE IF EXISTS log_track_updates CASCADE;
DROP TABLE IF EXISTS track CASCADE;
DROP TABLE IF EXISTS album CASCADE;
DROP TABLE IF EXISTS artist CASCADE;
DROP TABLE IF EXISTS genre CASCADE;
DROP TABLE IF EXISTS spotify_raw CASCADE;

-- Cette table stocke les données brutes importées avant transformation
CREATE TABLE IF NOT EXISTS spotify_raw (
  track_id              VARCHAR(200),
  track_name            VARCHAR(200),
  track_number          INTEGER,
  track_popularity      INTEGER,
  explicit              BOOLEAN,
  artist_name           VARCHAR(100),
  artist_popularity     INTEGER,
  artist_followers      INTEGER,
  artist_genres         TEXT,
  album_id              VARCHAR(200),
  album_name            VARCHAR(150),
  album_release_date    DATE,
  album_total_tracks    INTEGER,
  album_type            VARCHAR(20),
  track_duration_min    DOUBLE PRECISION
);

-- Cette instruction vide la table temporaire avant rechargement
TRUNCATE TABLE spotify_raw RESTART IDENTITY;

-- Cette instruction charge les données CSV nettoyées vers spotify_raw
COPY spotify_raw (
  track_id,
  track_name,
  track_number,
  track_popularity,
  explicit,
  artist_name,
  artist_popularity,
  artist_followers,
  artist_genres,
  album_id,
  album_name,
  album_release_date,
  album_total_tracks,
  album_type,
  track_duration_min
)
FROM '/docker-entrypoint-initdb.d/spotify_data_clean_fixed.csv'
DELIMITER ',' CSV HEADER;


-- Cette section crée les tables principales de l application

CREATE TABLE IF NOT EXISTS Track (
  track_id            VARCHAR(200) PRIMARY KEY,
  track_name          VARCHAR(200),
  track_number        INTEGER,
  track_popularity    INTEGER,
  explicit            BOOLEAN,
  track_duration_min  DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS Artist (
  artist_id          SERIAL PRIMARY KEY,
  artist_name        VARCHAR(100),
  artist_popularity  INTEGER,
  artist_followers   INTEGER
);

CREATE TABLE IF NOT EXISTS Album (
  album_id            VARCHAR(200) PRIMARY KEY,
  album_name          VARCHAR(150),
  album_release_date  DATE,
  album_total_tracks  INTEGER,
  album_type          VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Genre (
  genre_id    SERIAL PRIMARY KEY,
  genre_name  VARCHAR(100) UNIQUE
);


-- Cette section crée les tables relationnelles représentant les associations entre les entités

CREATE TABLE track_album (
  track_id  VARCHAR(200) REFERENCES track(track_id) ON DELETE CASCADE,
  album_id  VARCHAR(200) REFERENCES album(album_id) ON DELETE CASCADE,
  PRIMARY KEY (track_id, album_id)
);

CREATE TABLE artist_genre (
  artist_id  INTEGER REFERENCES artist(artist_id) ON DELETE CASCADE,
  genre_id   INTEGER REFERENCES genre(genre_id) ON DELETE CASCADE,
  PRIMARY KEY (artist_id, genre_id)
);

CREATE TABLE artist_album (
  artist_id  INTEGER REFERENCES artist(artist_id) ON DELETE CASCADE,
  album_id   VARCHAR(200) REFERENCES album(album_id) ON DELETE CASCADE,
  PRIMARY KEY (artist_id, album_id)
);


-- Cette section supprime puis recrée les fonctions PL pgSQL utilisées par l API

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


-- Cette section gère la journalisation automatique des modifications de pistes

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
CREATE TRIGGER trk_update_log AFTER UPDATE ON track FOR EACH ROW EXECUTE FUNCTION track_log_update();

DROP TRIGGER IF EXISTS trk_insert_log ON track;
CREATE TRIGGER trk_insert_log AFTER INSERT ON track FOR EACH ROW EXECUTE FUNCTION track_log_update();


-- Cette section recharge les données nettoyées dans les tables réelles depuis spotify_raw

TRUNCATE TABLE genre, artist, album, track, track_album, artist_album, artist_genre RESTART IDENTITY CASCADE;

INSERT INTO genre (genre_name)
SELECT DISTINCT TRIM(unnest(string_to_array(artist_genres, ',')))
FROM spotify_raw
WHERE artist_genres IS NOT NULL AND artist_genres <> '';

INSERT INTO artist (artist_name, artist_popularity, artist_followers)
SELECT DISTINCT artist_name, artist_popularity, artist_followers
FROM spotify_raw
WHERE artist_name IS NOT NULL;

INSERT INTO album (album_id, album_name, album_release_date, album_total_tracks, album_type)
SELECT DISTINCT album_id, album_name, album_release_date, album_total_tracks, album_type
FROM spotify_raw
WHERE album_id IS NOT NULL;

INSERT INTO track (track_id, track_name, track_number, track_popularity, explicit, track_duration_min)
SELECT DISTINCT track_id, track_name, track_number, track_popularity, explicit, track_duration_min
FROM spotify_raw
WHERE track_id IS NOT NULL;

INSERT INTO track_album (track_id, album_id)
SELECT DISTINCT track_id, album_id
FROM spotify_raw
WHERE track_id IS NOT NULL AND album_id IS NOT NULL;

INSERT INTO artist_album (artist_id, album_id)
SELECT DISTINCT a.artist_id, s.album_id
FROM spotify_raw s
JOIN artist a ON a.artist_name = s.artist_name
WHERE s.album_id IS NOT NULL;

INSERT INTO artist_genre (artist_id, genre_id)
SELECT DISTINCT a.artist_id, g.genre_id
FROM spotify_raw s
JOIN artist a ON a.artist_name = s.artist_name
JOIN LATERAL unnest(string_to_array(s.artist_genres, ',')) AS genre_name(g_name) ON TRUE
JOIN genre g ON TRIM(g.genre_name) = TRIM(g_name);


COMMIT;
