from fastapi import APIRouter, HTTPException
from database import execute_query

router = APIRouter(prefix="/tracks", tags=["tracks"])

# Cette route retourne la liste complète des pistes enregistrées
@router.get(
    "/",
    responses={
        200: {"description": "liste de tous les tracks"},
        500: {"description": "erreur serveur"}
    }
)
def get_all_tracks():
    return execute_query("SELECT * FROM track ORDER BY track_id;")


# Cette route retourne les informations d'une piste via la fonction get_track_by_id
@router.get(
    "/{track_id}",
    responses={
        200: {"description": "track trouvé"},
        404: {"description": "track introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def get_track(track_id: str):
    result = execute_query("SELECT * FROM get_track_by_id(%s);", (track_id,))
    if not result:
        raise HTTPException(404, "track not found")
    return result[0]


# Cette route recherche une piste en fonction d'un mot clé avec la fonction search_track
@router.get(
    "/search/{keyword}",
    responses={
        200: {"description": "résultats de recherche"},
        500: {"description": "erreur serveur"}
    }
)
def search_track_route(keyword: str):
    return execute_query("SELECT * FROM search_track(%s);", (keyword,))


# Cette route crée une nouvelle piste via add_track
@router.post(
    "/",
    status_code=201,
    responses={
        201: {"description": "track créé"},
        400: {"description": "données invalides"},
        500: {"description": "erreur serveur"}
    }
)
def create_track(
    track_id: str,
    track_name: str,
    track_number: int = None,
    track_popularity: int = None,
    explicit: bool = None,
    track_duration_min: float = None
):
    execute_query("""
        SELECT add_track(%s,%s,%s,%s,%s,%s);
    """, (track_id, track_name, track_number, track_popularity, explicit, track_duration_min))
    return {"message": "track created (via function)"}


# Cette route met à jour une piste existante via la fonction update_track_data
@router.put(
    "/{track_id}",
    responses={
        200: {"description": "track mis à jour"},
        404: {"description": "track introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def update_track(
    track_id: str,
    track_name: str = None,
    track_number: int = None,
    track_popularity: int = None,
    explicit: bool = None,
    track_duration_min: float = None
):
    updated = execute_query("""
        SELECT update_track_data(%s,%s,%s,%s,%s,%s);
    """, (track_id, track_name, track_number, track_popularity, explicit, track_duration_min))
    
    if updated and updated[0].get("update_track_data") is False:
        raise HTTPException(404, "track not found for update")

    return {"message": "track updated (via function)"}


# Cette route supprime une piste via la fonction delete_track_data
@router.delete(
    "/{track_id}",
    responses={
        200: {"description": "track supprimé"},
        404: {"description": "track introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def delete_track(track_id: str):
    deleted = execute_query("SELECT delete_track_data(%s);", (track_id,))
    if deleted and deleted[0].get("delete_track_data") is False:
        raise HTTPException(404, "track not found for deletion")
    return {"message": "track deleted (via function)"}
