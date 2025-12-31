DROP TABLE IF EXISTS artist_album;
DROP TABLE IF EXISTS artist_genre;
DROP TABLE IF EXISTS track_album;
DROP TABLE IF EXISTS spotify_raw;

CREATE TABLE IF NOT EXISTS spotify_raw (
  track_id              VARCHAR(200),
  track_name            VARCHAR(200),
  track_number          INTEGER,
  track_popularity      INTEGER,
  explicit              BOOLEAN,       
  track_duration_min    DOUBLE PRECISION,
  artist_name           VARCHAR(100),
  artist_popularity     INTEGER,
  artist_followers      INTEGER,
  artist_genres         TEXT,           
  album_id              VARCHAR(200),
  album_name            VARCHAR(150),
  album_release_date    DATE,
  album_total_tracks    INTEGER,
  album_type            VARCHAR(20)
);

-- TRACK
DROP TABLE IF EXISTS Track;

CREATE TABLE IF NOT EXISTS Track (
  track_id            VARCHAR(200) PRIMARY KEY,
  track_name          VARCHAR(200),
  track_number        INTEGER,
  track_popularity    INTEGER,
  explicit            BOOLEAN,
  track_duration_min  DOUBLE PRECISION
);

-- ARTIST
DROP TABLE IF EXISTS Artist;

CREATE TABLE IF NOT EXISTS Artist (
  artist_id          SERIAL PRIMARY KEY,
  artist_name        VARCHAR(100),
  artist_popularity  INTEGER,
  artist_followers   INTEGER
);

-- ALBUM
DROP TABLE IF EXISTS Album;

CREATE TABLE IF NOT EXISTS Album (
  album_id            VARCHAR(200) PRIMARY KEY,
  album_name          VARCHAR(150),
  album_release_date  DATE,
  album_total_tracks  INTEGER,
  album_type          VARCHAR(20)
);

-- GENRE
DROP TABLE IF EXISTS Genre;

CREATE TABLE IF NOT EXISTS Genre (
  genre_id    SERIAL PRIMARY KEY,
  genre_name  VARCHAR(100) UNIQUE
);

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
