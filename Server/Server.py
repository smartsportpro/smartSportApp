from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from supabase import create_client, Client
from typing import Optional
from uuid import UUID
from datetime import date
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = FastAPI()

# Get Supabase credentials from environment variables
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not url or not key:
    raise ValueError("❌ SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env file")

print(f"✅ Loaded Supabase URL: {url}")
print(f"✅ Loaded service_role key: {key[:20]}...")

# Using service_role key to bypass RLS policies in backend
supabase: Client = create_client(url, key)

def format_timestamps(data):
    """Add 'Z' to timestamp fields for ISO8601 compatibility"""
    if isinstance(data, dict):
        for key in ['created_at', 'updated_at']:
            if key in data and isinstance(data[key], str) and not data[key].endswith('Z'):
                data[key] = data[key] + 'Z'
    return data

class Profile(BaseModel):
    user_id: UUID
    name: str
    age: Optional[int] = None
    position: Optional[str] = None
    target_division: Optional[str] = None

class Measurables(BaseModel):
    user_id: UUID
    height_inches: int
    weight_lbs: int
    wingspan_inches: Optional[int] = None
    vertical_jump_inches: Optional[int] = None

class Stats(BaseModel):
    user_id: UUID
    ppg: Optional[float] = None
    rpg: Optional[float] = None
    apg: Optional[float] = None
    fg_percent: Optional[float] = None
    three_p_percent: Optional[float] = None

class GameStats(BaseModel):
    user_id: UUID
    date: date
    opponent: Optional[str] = None
    minutes: Optional[int] = None
    points: Optional[int] = None
    rebounds: Optional[int] = None
    assists: Optional[int] = None
    steals: Optional[int] = None
    blocks: Optional[int] = None
    fg_percent: Optional[float] = None
    three_p_percent: Optional[float] = None

@app.post("/api/profile")
def save_profile(profile: Profile):
    try:
        data = profile.dict()
        # Convert UUID to string for Supabase
        data['user_id'] = str(data['user_id'])
        print(f"✅ Received profile data: {data}")
        result = supabase.table("user_profiles").insert(data).execute()
        print(f"✅ Profile saved successfully: {result.data}")
        # Return first item from array with formatted timestamps
        response = result.data[0] if result.data else {}
        return format_timestamps(response)
    except Exception as e:
        print(f"❌ Error saving profile: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/profile/{user_id}/measurables")
def update_measurables(user_id: str, measurables: Measurables):
    """
    Upsert user measurables (height, weight, wingspan, vertical)
    """
    try:
        data = measurables.dict(exclude={'user_id'})
        data['user_id'] = user_id

        print(f"✅ Received measurables data: {data}")

        # Check if measurables exist for this user
        existing = supabase.table("user_measurables") \
            .select("*") \
            .eq("user_id", user_id) \
            .execute()

        if existing.data and len(existing.data) > 0:
            # Update existing
            result = supabase.table("user_measurables") \
                .update(data) \
                .eq("user_id", user_id) \
                .execute()
            print(f"✅ Measurables updated: {result.data}")
        else:
            # Insert new
            result = supabase.table("user_measurables").insert(data).execute()
            print(f"✅ Measurables created: {result.data}")

        # Return first item from array with formatted timestamps
        response = result.data[0] if result.data else {}
        return format_timestamps(response)
    except Exception as e:
        print(f"❌ Error updating measurables: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/api/profile/{user_id}/stats")
def update_stats(user_id: str, stats: Stats):
    """
    Upsert user stats (ppg, rpg, apg, fg%, 3p%)
    """
    try:
        data = stats.dict(exclude={'user_id'})
        data['user_id'] = user_id

        print(f"✅ Received stats data: {data}")

        # Check if stats exist for this user
        existing = supabase.table("user_stats") \
            .select("*") \
            .eq("user_id", user_id) \
            .execute()

        if existing.data and len(existing.data) > 0:
            # Update existing
            result = supabase.table("user_stats") \
                .update(data) \
                .eq("user_id", user_id) \
                .execute()
            print(f"✅ Stats updated: {result.data}")
        else:
            # Insert new
            result = supabase.table("user_stats").insert(data).execute()
            print(f"✅ Stats created: {result.data}")

        # Return first item from array with formatted timestamps
        response = result.data[0] if result.data else {}
        return format_timestamps(response)
    except Exception as e:
        print(f"❌ Error updating stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/stats/{user_id}")
def get_user_stats(user_id: str):
    """
    Get all games and season averages for a user
    """
    try:
        # Get all games for the user, sorted by date DESC
        games_result = supabase.table("game_stats") \
            .select("*") \
            .eq("user_id", user_id) \
            .order("date", desc=True) \
            .execute()

        games = games_result.data

        # Calculate season averages if there are games
        if games and len(games) > 0:
            total_games = len(games)

            # Calculate averages
            ppg = round(sum(g.get('points', 0) or 0 for g in games) / total_games, 1)
            rpg = round(sum(g.get('rebounds', 0) or 0 for g in games) / total_games, 1)
            apg = round(sum(g.get('assists', 0) or 0 for g in games) / total_games, 1)

            # Calculate average shooting percentages
            fg_percents = [g.get('fg_percent', 0) or 0 for g in games if g.get('fg_percent') is not None]
            fg_percent = round(sum(fg_percents) / len(fg_percents), 1) if fg_percents else 0.0

            three_p_percents = [g.get('three_p_percent', 0) or 0 for g in games if g.get('three_p_percent') is not None]
            three_p_percent = round(sum(three_p_percents) / len(three_p_percents), 1) if three_p_percents else 0.0

            season_averages = {
                "ppg": ppg,
                "rpg": rpg,
                "apg": apg,
                "fg_percent": fg_percent,
                "three_p_percent": three_p_percent
            }
        else:
            season_averages = {
                "ppg": 0.0,
                "rpg": 0.0,
                "apg": 0.0,
                "fg_percent": 0.0,
                "three_p_percent": 0.0
            }

        return {
            "season_averages": season_averages,
            "games": games
        }

    except Exception as e:
        print(f"❌ Error getting user stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/stats")
def add_game_stats(game_stats: GameStats):
    """
    Add a new game stat record and automatically update user's season averages
    """
    try:
        # Convert Pydantic model to dict, excluding None values
        data = game_stats.dict(exclude_none=True)

        # Convert UUID to string for Supabase
        user_id = str(data['user_id'])
        data['user_id'] = user_id
        # Convert date to string
        data['date'] = str(data['date'])

        # Insert into game_stats table
        result = supabase.table("game_stats").insert(data).execute()

        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to create game record")

        # Automatically update season averages in user_stats table
        # Get all games for this user
        all_games = supabase.table("game_stats") \
            .select("*") \
            .eq("user_id", user_id) \
            .execute()

        games = all_games.data

        if games and len(games) > 0:
            total_games = len(games)

            # Calculate season averages
            ppg = round(sum(g.get('points', 0) or 0 for g in games) / total_games, 1)
            rpg = round(sum(g.get('rebounds', 0) or 0 for g in games) / total_games, 1)
            apg = round(sum(g.get('assists', 0) or 0 for g in games) / total_games, 1)

            fg_percents = [g.get('fg_percent', 0) or 0 for g in games if g.get('fg_percent') is not None]
            fg_percent = round(sum(fg_percents) / len(fg_percents), 1) if fg_percents else 0.0

            three_p_percents = [g.get('three_p_percent', 0) or 0 for g in games if g.get('three_p_percent') is not None]
            three_p_percent = round(sum(three_p_percents) / len(three_p_percents), 1) if three_p_percents else 0.0

            stats_data = {
                "user_id": user_id,
                "ppg": ppg,
                "rpg": rpg,
                "apg": apg,
                "fg_percent": fg_percent,
                "three_p_percent": three_p_percent
            }

            # Check if user_stats exists
            existing_stats = supabase.table("user_stats") \
                .select("*") \
                .eq("user_id", user_id) \
                .execute()

            if existing_stats.data and len(existing_stats.data) > 0:
                # Update existing stats
                supabase.table("user_stats") \
                    .update(stats_data) \
                    .eq("user_id", user_id) \
                    .execute()
                print(f"✅ Updated season averages for user {user_id}")
            else:
                # Insert new stats
                supabase.table("user_stats").insert(stats_data).execute()
                print(f"✅ Created season averages for user {user_id}")

        return {
            "status": "created",
            "data": result.data[0]
        }

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error adding game stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/stats/{game_id}")
def delete_game_stats(game_id: str):
    """
    Delete a game record and automatically update user's season averages
    """
    try:
        # First, get the game to know which user to update
        game_to_delete = supabase.table("game_stats") \
            .select("user_id") \
            .eq("id", game_id) \
            .execute()

        if not game_to_delete.data:
            raise HTTPException(status_code=404, detail="Game record not found")

        user_id = game_to_delete.data[0]['user_id']

        # Delete from game_stats
        result = supabase.table("game_stats") \
            .delete() \
            .eq("id", game_id) \
            .execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Game record not found")

        # Recalculate season averages after deletion
        # Get remaining games for this user
        remaining_games = supabase.table("game_stats") \
            .select("*") \
            .eq("user_id", user_id) \
            .execute()

        games = remaining_games.data

        if games and len(games) > 0:
            total_games = len(games)

            # Calculate new season averages
            ppg = round(sum(g.get('points', 0) or 0 for g in games) / total_games, 1)
            rpg = round(sum(g.get('rebounds', 0) or 0 for g in games) / total_games, 1)
            apg = round(sum(g.get('assists', 0) or 0 for g in games) / total_games, 1)

            fg_percents = [g.get('fg_percent', 0) or 0 for g in games if g.get('fg_percent') is not None]
            fg_percent = round(sum(fg_percents) / len(fg_percents), 1) if fg_percents else 0.0

            three_p_percents = [g.get('three_p_percent', 0) or 0 for g in games if g.get('three_p_percent') is not None]
            three_p_percent = round(sum(three_p_percents) / len(three_p_percents), 1) if three_p_percents else 0.0

            stats_data = {
                "ppg": ppg,
                "rpg": rpg,
                "apg": apg,
                "fg_percent": fg_percent,
                "three_p_percent": three_p_percent
            }

            # Update user_stats
            supabase.table("user_stats") \
                .update(stats_data) \
                .eq("user_id", user_id) \
                .execute()
            print(f"✅ Recalculated season averages after deletion for user {user_id}")
        else:
            # No games left, reset stats to zero
            stats_data = {
                "ppg": 0.0,
                "rpg": 0.0,
                "apg": 0.0,
                "fg_percent": 0.0,
                "three_p_percent": 0.0
            }
            supabase.table("user_stats") \
                .update(stats_data) \
                .eq("user_id", user_id) \
                .execute()
            print(f"✅ Reset season averages to zero for user {user_id}")

        return {"status": "deleted"}

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error deleting game stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))
