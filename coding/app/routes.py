from __future__ import annotations

from datetime import datetime
from typing import Any

from dateutil import parser as dateparser
from flask import Blueprint, request
from tinydb import Query

from .db import get_table
from .models import (
    validate_macros,
    new_goals,
    new_intake,
)
from .recommender import recommend_meals


api_bp = Blueprint("api", __name__)


@api_bp.post("/users/<user_id>/goals")
def set_goals(user_id: str):
    body: dict[str, Any] = request.get_json(force=True) or {}
    daily_calories = int(body.get("daily_calories", 0))
    macros = validate_macros(body.get("macros", {}))

    goals = new_goals(user_id, daily_calories, macros)
    table = get_table("goals")
    User = Query()
    # Upsert behavior
    if table.contains(User.user_id == user_id):
        table.update(goals, User.user_id == user_id)
    else:
        table.insert(goals)

    return {"ok": True, "goals": goals}, 200


@api_bp.get("/users/<user_id>/goals")
def get_goals(user_id: str):
    table = get_table("goals")
    User = Query()
    goals = table.get(User.user_id == user_id)
    if not goals:
        return {"error": "goals_not_found"}, 404
    return {"goals": goals}, 200


@api_bp.post("/users/<user_id>/recommendations")
def get_recommendations(user_id: str):
    # use provided target or fallback to user's goals
    body: dict[str, Any] = request.get_json(silent=True) or {}

    table = get_table("goals")
    User = Query()
    goals = table.get(User.user_id == user_id)
    if goals is None and not body:
        return {"error": "goals_not_found"}, 404

    daily_calories = int(body.get("daily_calories") or (goals or {}).get("daily_calories", 0))
    macros_obj = body.get("macros") or (goals or {}).get("macros", {})
    macros = validate_macros(macros_obj)

    if daily_calories <= 0:
        return {"error": "invalid_daily_calories"}, 400

    plan = recommend_meals(
        daily_calories,
        macros["protein_g"],
        macros["carbs_g"],
        macros["fat_g"],
    )

    return {"recommendations": plan}, 200


@api_bp.post("/users/<user_id>/intake")
def log_intake(user_id: str):
    body: dict[str, Any] = request.get_json(force=True) or {}
    food_name = str(body.get("food_name", "")).strip()
    calories = int(body.get("calories", 0))
    protein_g = float(body.get("protein_g", 0))
    carbs_g = float(body.get("carbs_g", 0))
    fat_g = float(body.get("fat_g", 0))
    timestamp_str = body.get("timestamp")
    ts = dateparser.parse(timestamp_str) if timestamp_str else None

    item = new_intake(user_id, food_name, calories, protein_g, carbs_g, fat_g, ts)
    table = get_table("intake")
    table.insert(item)
    return {"ok": True, "intake": item}, 201


@api_bp.get("/users/<user_id>/summary/monthly")
def monthly_summary(user_id: str):
    # expects query param 'month' in YYYY-MM format
    month_str = request.args.get("month")
    if not month_str:
        return {"error": "missing_month"}, 400

    try:
        month_dt = dateparser.parse(month_str + "-01").date()
    except Exception:
        return {"error": "invalid_month"}, 400

    table = get_table("intake")
    User = Query()
    rows = table.search(User.user_id == user_id)

    total_cal = 0
    total_p = 0.0
    total_c = 0.0
    total_f = 0.0
    days: dict[str, dict[str, float]] = {}

    for row in rows:
        try:
            ts = dateparser.parse(row["timestamp"])  # type: ignore[index]
        except Exception:
            continue
        if ts.year == month_dt.year and ts.month == month_dt.month:
            day_key = ts.date().isoformat()
            total_cal += int(row.get("calories", 0))
            total_p += float(row.get("protein_g", 0))
            total_c += float(row.get("carbs_g", 0))
            total_f += float(row.get("fat_g", 0))
            bucket = days.setdefault(day_key, {"calories": 0.0, "protein_g": 0.0, "carbs_g": 0.0, "fat_g": 0.0})
            bucket["calories"] += float(row.get("calories", 0))
            bucket["protein_g"] += float(row.get("protein_g", 0))
            bucket["carbs_g"] += float(row.get("carbs_g", 0))
            bucket["fat_g"] += float(row.get("fat_g", 0))

    summary = {
        "month": month_dt.strftime("%Y-%m"),
        "totals": {
            "calories": total_cal,
            "protein_g": round(total_p, 2),
            "carbs_g": round(total_c, 2),
            "fat_g": round(total_f, 2),
        },
        "by_day": days,
    }

    return {"summary": summary}, 200


