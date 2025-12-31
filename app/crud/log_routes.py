from fastapi import APIRouter
from database import execute_query

router = APIRouter(prefix="/logs", tags=["logs"])

# Cette route retourne l'historique des modifications effectuées sur les pistes
@router.get(
    "/",
    responses={
        200: {"description": "liste des logs récupérée"},
        500: {"description": "erreur serveur"}
    }
)
def get_logs():
    return execute_query("""
        SELECT id, track_id, action, changed_at
        FROM log_track_updates
        ORDER BY changed_at DESC;
    """)
