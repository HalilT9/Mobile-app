from flask import Flask
from .db import init_db
from .routes import api_bp


def create_app() -> Flask:
    app = Flask(__name__)

    # Basic config
    app.config.setdefault("TINYDB_PATH", "data/db.json")

    # Initialize DB and blueprints
    init_db(app)
    app.register_blueprint(api_bp, url_prefix="/api")

    @app.get("/health")
    def health() -> tuple[dict, int]:
        return {"status": "ok"}, 200

    return app


