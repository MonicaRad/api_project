
import psycopg
from pathlib import Path

DB_CONFIG = {
    "host": "db",
    "port": 5432,
    "dbname": "spotify_db",
    "user": "spotify_user",
    "password": "spotify_pwd"
}

# Cette fonction établit une connexion à la base de données et la retourne
def get_connection():
    return psycopg.connect(**DB_CONFIG)

# Cette fonction exécute une requête SQL, retourne les résultats si présents, sinon confirme la transaction
def execute_query(query, params=None):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params or ())
            if cur.description:
                cols = [c[0] for c in cur.description]
                rows = cur.fetchall()
                return [dict(zip(cols, r)) for r in rows]
            conn.commit()
            return {"success": True}
