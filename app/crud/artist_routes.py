from fastapi import APIRouter, HTTPException
from database import execute_query

router = APIRouter(prefix="/artists", tags=["artists"])

# Cette route retourne la liste complète des artistes enregistrés
@router.get(
    "/",
    responses={
        200: {"description": "liste de tous les artistes"},
        500: {"description": "erreur serveur"}
    }
)
def list_artists():
    return execute_query("SELECT * FROM artist ORDER BY artist_id;")


# Cette route retourne les informations d un artiste selon son identifiant
@router.get(
    "/{artist_id}",
    responses={
        200: {"description": "artiste trouvé"},
        404: {"description": "artiste introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def get_artist(artist_id: int):
    data = execute_query("SELECT * FROM artist WHERE artist_id = %s;", (artist_id,))
    if not data:
        raise HTTPException(404, "artist not found")
    return data[0]


# Cette route permet de créer un nouvel artiste dans la base de données
@router.post(
    "/",
    status_code=201,
    responses={
        201: {"description": "artiste créé"},
        400: {"description": "données invalides"},
        500: {"description": "erreur serveur"}
    }
)
def create_artist(artist_name: str, artist_popularity: int = None, artist_followers: int = None):
    execute_query("""
        INSERT INTO artist (artist_name, artist_popularity, artist_followers)
        VALUES (%s, %s, %s);
    """, (artist_name, artist_popularity, artist_followers))
    return {"message": "artist created"}


# Cette route met à jour les informations d un artiste selon son identifiant
@router.put(
    "/{artist_id}",
    responses={
        200: {"description": "artiste mis à jour"},
        404: {"description": "artiste introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def update_artist(artist_id: int, artist_name: str = None, artist_popularity: int = None, artist_followers: int = None):
    execute_query("""
        UPDATE artist SET
        artist_name = COALESCE(%s, artist_name),
        artist_popularity = COALESCE(%s, artist_popularity),
        artist_followers = COALESCE(%s, artist_followers)
        WHERE artist_id = %s;
    """, (artist_name, artist_popularity, artist_followers, artist_id))
    return {"message": "artist updated"}


# Cette route supprime un artiste de la base de données selon son identifiant
@router.delete(
    "/{artist_id}",
    responses={
        200: {"description": "artiste supprimé"},
        404: {"description": "artiste introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def delete_artist(artist_id: int):
    execute_query("DELETE FROM artist WHERE artist_id = %s;", (artist_id,))
    return {"message": "artist deleted"}
