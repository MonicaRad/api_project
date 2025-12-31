from fastapi import FastAPI
from crud.artist_routes import router as artist_router
from crud.genre_routes import router as genre_router
from crud.album_routes import router as album_router
from crud.track_routes import router as track_router
from crud.log_routes import router as log_router



app = FastAPI(title="Spotify API")

# Initialisation de la base de données au démarrage de l'application

        

app.include_router(artist_router)
app.include_router(genre_router)
app.include_router(album_router)
app.include_router(track_router)
app.include_router(log_router)
