from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import TypedDict, Optional, Dict, Any


class Macros(TypedDict):
    protein_g: float
    carbs_g: float
    fat_g: float


class UserGoals(TypedDict):
    user_id: str
    daily_calories: int
    macros: Macros  # total grams per day target
    updated_at: str


class IntakeItem(TypedDict):
    user_id: str
    timestamp: str
    food_name: str
    calories: int
    protein_g: float
    carbs_g: float
    fat_g: float


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def validate_macros(macros: Dict[str, Any]) -> Macros:
    protein_g = float(macros.get("protein_g", 0))
    carbs_g = float(macros.get("carbs_g", 0))
    fat_g = float(macros.get("fat_g", 0))
    if protein_g < 0 or carbs_g < 0 or fat_g < 0:
        raise ValueError("Macro values must be non-negative")
    return {"protein_g": protein_g, "carbs_g": carbs_g, "fat_g": fat_g}


def new_goals(user_id: str, daily_calories: int, macros: Macros) -> UserGoals:
    if daily_calories <= 0:
        raise ValueError("daily_calories must be > 0")
    return {
        "user_id": user_id,
        "daily_calories": int(daily_calories),
        "macros": macros,
        "updated_at": utc_now_iso(),
    }


def new_intake(
    user_id: str,
    food_name: str,
    calories: int,
    protein_g: float,
    carbs_g: float,
    fat_g: float,
    timestamp: Optional[datetime] = None,
) -> IntakeItem:
    if calories < 0:
        raise ValueError("calories must be >= 0")
    ts = (timestamp or datetime.now(timezone.utc)).isoformat()
    return {
        "user_id": user_id,
        "timestamp": ts,
        "food_name": food_name,
        "calories": int(calories),
        "protein_g": float(protein_g),
        "carbs_g": float(carbs_g),
        "fat_g": float(fat_g),
    }


