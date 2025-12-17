# Nutrition Backend (Flask + TinyDB)

A minimal backend for daily calorie and macro targets, food recommendations, and monthly intake tracking.

## Features
- Set/get user daily goals (calories and macros)
- Generate simple food recommendations towards goals
- Log food intake entries
- Get monthly summaries (totals and per-day breakdown)
- NoSQL storage via TinyDB (JSON file)

## Requirements
- Python 3.11+

## Setup
```bash
python -m venv .venv
. .venv/Scripts/activate  # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Run
```bash
python app.py
# App on http://127.0.0.1:5000
```

## API
- Health: `GET /health`
- Create/Update goals: `POST /api/users/{user_id}/goals`
  - body:
    ```json
    {"daily_calories": 2200, "macros": {"protein_g": 150, "carbs_g": 220, "fat_g": 70}}
    ```
- Get goals: `GET /api/users/{user_id}/goals`
- Recommendations: `POST /api/users/{user_id}/recommendations`
  - optional body to override goals:
    ```json
    {"daily_calories": 2000, "macros": {"protein_g": 140, "carbs_g": 200, "fat_g": 60}}
    ```
- Log intake: `POST /api/users/{user_id}/intake`
  - body:
    ```json
    {"food_name":"Chicken breast (100g)","calories":165,"protein_g":31,"carbs_g":0,"fat_g":3.6}
    ```
- Monthly summary: `GET /api/users/{user_id}/summary/monthly?month=2025-10`

## Data Location
- TinyDB file at `data/db.json` (created automatically)

## Notes
- Recommendation engine is simple; replace with a richer dataset for production.
