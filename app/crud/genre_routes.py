from fastapi import APIRouter, HTTPException
from database import execute_query

router = APIRouter(prefix="/genres", tags=["genres"])

# Cette route retourne la liste de tous les genres disponibles
@router.get(
    "/",
    responses={
        200: {"description": "liste de tous les genres"},
        500: {"description": "erreur serveur"}
    }
)
def list_genres():
    return execute_query("SELECT * FROM genre ORDER BY genre_id;")


# Cette route permet de créer un nouveau genre dans la base de données
@router.post(
    "/",
    status_code=201,
    responses={
        201: {"description": "genre créé"},
        400: {"description": "données invalides"},
        500: {"description": "erreur serveur"}
    }
)
def create_genre(genre_name: str):
    execute_query("INSERT INTO genre (genre_name) VALUES (%s);", (genre_name,))
    return {"message": "genre created"}


# Cette route supprime un genre selon son identifiant
@router.delete(
    "/{genre_id}",
    responses={
        200: {"description": "genre supprimé"},
        404: {"description": "genre introuvable"},
        500: {"description": "erreur serveur"}
    }
)
def delete_genre(genre_id: int):
    deleted = execute_query("DELETE FROM genre WHERE genre_id = %s;", (genre_id,))
    return {"message": "genre deleted"}
