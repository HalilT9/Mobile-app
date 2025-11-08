from __future__ import annotations

from typing import TypedDict, List


class Food(TypedDict):
    name: str
    calories: int
    protein_g: float
    carbs_g: float
    fat_g: float


# Minimal example food database; in real-world, fetch from a proper dataset
FOODS: list[Food] = [
    {"name": "Chicken breast (100g)", "calories": 165, "protein_g": 31, "carbs_g": 0, "fat_g": 3.6},
    {"name": "Greek yogurt (170g)", "calories": 100, "protein_g": 17, "carbs_g": 6, "fat_g": 0.7},
    {"name": "Brown rice (1 cup)", "calories": 216, "protein_g": 5, "carbs_g": 45, "fat_g": 1.8},
    {"name": "Oats (1/2 cup)", "calories": 150, "protein_g": 5, "carbs_g": 27, "fat_g": 3},
    {"name": "Almonds (28g)", "calories": 164, "protein_g": 6, "carbs_g": 6, "fat_g": 14},
    {"name": "Eggs (2 large)", "calories": 156, "protein_g": 12, "carbs_g": 2, "fat_g": 10},
    {"name": "Salmon (100g)", "calories": 208, "protein_g": 20, "carbs_g": 0, "fat_g": 13},
    {"name": "Apple (1 medium)", "calories": 95, "protein_g": 0.5, "carbs_g": 25, "fat_g": 0.3},
    {"name": "Banana (1 medium)", "calories": 105, "protein_g": 1.3, "carbs_g": 27, "fat_g": 0.4},
    {"name": "Olive oil (1 tbsp)", "calories": 119, "protein_g": 0, "carbs_g": 0, "fat_g": 14},
]


def recommend_meals(target_calories: int, target_protein: float, target_carbs: float, target_fat: float) -> list[Food]:
    """
    Very simple heuristic: pick 3-5 items that roughly match macro ratios and calories.
    This is a naive greedy approach — good enough for a baseline.
    """
    remaining_cal = float(target_calories)
    remaining_p = float(target_protein)
    remaining_c = float(target_carbs)
    remaining_f = float(target_fat)

    plan: list[Food] = []

    # Greedy pass: high protein when protein remains; high carbs when carbs remains; high fat when fat remains
    for _ in range(5):
        if remaining_cal <= 0:
            break

        # Score foods by how much they help reduce remaining macros without overshooting too much
        best = None
        best_score = float("inf")
        for food in FOODS:
            # Skip if adding this food would exceed calories by too much (>20%)
            if food["calories"] > remaining_cal * 1.2 and remaining_cal > 200:
                continue

            p_gap = max(0.0, remaining_p - food["protein_g"])
            c_gap = max(0.0, remaining_c - food["carbs_g"])
            f_gap = max(0.0, remaining_f - food["fat_g"])
            cal_gap = max(0.0, remaining_cal - food["calories"])

            score = p_gap * 1.5 + c_gap * 1.0 + f_gap * 1.2 + cal_gap * 0.3

            if score < best_score:
                best_score = score
                best = food

        if best is None:
            break

        plan.append(best)
        remaining_cal -= best["calories"]
        remaining_p -= best["protein_g"]
        remaining_c -= best["carbs_g"]
        remaining_f -= best["fat_g"]

    return plan


