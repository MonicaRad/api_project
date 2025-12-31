from fastapi import APIRouter, HTTPException
from database import execute_query
from typing import Optional, List

router = APIRouter(
    prefix="/albums",
    tags=["albums"]
)

# Cette route retourne la liste complète des albums enregistrés
@router.get(
    "/",
    responses={
        200: {"description": "liste de tous les albums"},
        500: {"description": "erreur serveur"}
    }
)
def list_albums():
    return execute_query("SELECT * FROM album ORDER BY album_id;")


# Cette route retourne les informations d un album selon son identifiant
@router.get(
    "/{album_id}",
    responses={
        200: {"description": "album trouvé"},
        404: {"description": "album introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def get_album(album_id: str):
    data = execute_query("SELECT * FROM album WHERE album_id = %s;", (album_id,))
    if not data:
        raise HTTPException(404, "album not found")
    return data[0]


# Cette route permet de créer un nouvel album dans la base de données
@router.post(
    "/",
    status_code=201,
    responses={
        201: {"description": "album créé"},
        400: {"description": "données invalides"},
        500: {"description": "erreur serveur"}
    }
)
def create_album(
    album_id: str,
    album_name: str,
    album_release_date: Optional[str] = None,
    album_total_tracks: Optional[int] = None,
    album_type: Optional[str] = None
):
    created = execute_query("""
        INSERT INTO album (album_id, album_name, album_release_date, album_total_tracks, album_type)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING *;
    """, (album_id, album_name, album_release_date, album_total_tracks, album_type))
    
    return created[0]


# Cette route met à jour les informations d un album selon son identifiant
@router.put(
    "/{album_id}",
    responses={
        200: {"description": "album mis à jour"},
        404: {"description": "album introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def update_album(
    album_id: str,
    album_name: Optional[str] = None,
    album_release_date: Optional[str] = None,
    album_total_tracks: Optional[int] = None,
    album_type: Optional[str] = None
):
    execute_query("""
        UPDATE album SET
        album_name = COALESCE(%s, album_name),
        album_release_date = COALESCE(%s, album_release_date),
        album_total_tracks = COALESCE(%s, album_total_tracks),
        album_type = COALESCE(%s, album_type)
        WHERE album_id = %s;
    """, (album_name, album_release_date, album_total_tracks, album_type, album_id))
    return {"message": "album updated"}


# Cette route supprime un album de la base de données selon son identifiant
@router.delete(
    "/{album_id}",
    responses={
        200: {"description": "album supprimé"},
        404: {"description": "album introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def delete_album(album_id: str):
    execute_query("DELETE FROM album WHERE album_id = %s;", (album_id,))
    return {"message": "album deleted"}

