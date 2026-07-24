# plongee — notes projet

Application sur la plongée, prévue en plusieurs clients (web, iOS, Android).
Ce dépôt (`~/dev/plongee`) ne contient que le **backend API** ; les clients
seront des projets séparés qui consomment cette API, pas gérés ici.

## Décisions prises

- **Tooling : uv** (`pyproject.toml` + `uv.lock`), structure standard
  `uv init --app`.
- **Framework : FastAPI + uvicorn**, point d'entrée `main.py`.
- **Git : initialisé par `uv init`**, `.gitignore` par défaut (venv, cache
  Python, build artifacts).

## Lancer en local

```bash
uv run uvicorn main:app --reload
```

## État

Squelette initial seulement : un endpoint `GET /` de healthcheck
(`{"status": "ok"}`), testé et fonctionnel. Aucune fonctionnalité métier
(plongées, paliers, carnet, etc.) n'est encore définie — à préciser avec
l'utilisateur avant d'ajouter des modèles/endpoints.
