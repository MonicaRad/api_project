"""
API FastAPI simple pour Netflix Database
Utilise les fonctions PL/pgSQL créées précédemment
"""
from fastapi import FastAPI, HTTPException
from database import execute_query

app = FastAPI(title="Spotify API", version="0.0.1")

# ============================================================
# LANCEMENT DE L'API
# ============================================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)