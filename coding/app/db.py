from __future__ import annotations

from pathlib import Path
from typing import Any

from flask import current_app, Flask, g
from tinydb import TinyDB


DB_G_KEY = "tinydb_instance"


def init_db(app: Flask) -> None:
    data_path = Path(app.config["TINYDB_PATH"])  # type: ignore[index]
    data_path.parent.mkdir(parents=True, exist_ok=True)

    @app.before_request
    def _open_db() -> None:
        if getattr(g, DB_G_KEY, None) is None:
            g.tinydb_instance = TinyDB(data_path)

    @app.teardown_request
    def _close_db(exception: Exception | None) -> None:
        db: TinyDB | None = getattr(g, DB_G_KEY, None)
        if db is not None:
            db.close()
            g.tinydb_instance = None


def get_db() -> TinyDB:
    db: TinyDB | None = getattr(g, DB_G_KEY, None)
    if db is None:
        # Fallback for contexts where before_request did not run (e.g., CLI)
        path = Path(current_app.config["TINYDB_PATH"])  # type: ignore[index]
        path.parent.mkdir(parents=True, exist_ok=True)
        db = TinyDB(path)
        g.tinydb_instance = db
    return db


def get_table(name: str) -> Any:
    return get_db().table(name)


