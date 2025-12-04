DROP TABLE IF exists spotify_raw

create  table if not exists spotify_raw(
	track_id varchar(200),
	track_name varchar(200),
	track_number integer,
	track_popularity integer,
	explicity boolean,
	track_duration_min float,
	artist_name varchar(100),
	artist_popularity integer,
	artist_followers integer,
	artist_genres varchar(200),
	album_id varchar(200),
	album_name varchar(150),
	album_release_date date,
	album_total_tracks integer,
	album_type varchar(20),
	
)


DROP TABLE IF exists Track;

create  table if not exists Track(
  track_id varchar(200) PRIMARY KEY,
  track_name varchar(200),
  track_number integer,
  track_popularity integer,
  explicit boolean,
  track_duration_min float
	
);

DROP TABLE IF exists Artist;

create  table if not exists Artist (
artist_id  SERIAL PRIMARY KEY, 
artist_name varchar(100),
artist_popularity integer,
	artist_followers integer
);