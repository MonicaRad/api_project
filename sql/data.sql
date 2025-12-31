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
