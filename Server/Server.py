from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from supabase import create_client, Client
from typing import Optional, List
from uuid import UUID
from datetime import date
import os
from dotenv import load_dotenv
from sklearn.neighbors import NearestNeighbors
from sklearn.preprocessing import StandardScaler
import numpy as np

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

class MatchRequest(BaseModel):
    user_id: Optional[UUID] = None
    height_inches: Optional[int] = None
    weight_lbs: Optional[int] = None
    position: Optional[str] = None  # Guard/Forward/Big
    ppg: Optional[float] = None
    apg: Optional[float] = None
    rpg: Optional[float] = None
    fg_percent: Optional[float] = None
    target_division: Optional[str] = None  # D1/D2/D3/NAIA

class MatchResult(BaseModel):
    player_id: UUID
    name: str
    college: str
    division: str
    position: str
    similarity_score: float  # 0-100
    college_height_inches: int
    college_weight_lbs: int
    hs_ppg: Optional[float] = None
    hs_apg: Optional[float] = None
    hs_rpg: Optional[float] = None
    hs_fg_percent: Optional[float] = None
    hs_3p_percent: Optional[float] = None
    photo_url: Optional[str] = None

class DrillRecommendationRequest(BaseModel):
    """Request for personalized drill recommendations"""
    user_id: Optional[UUID] = None
    # Direct stats input (alternative to user_id lookup)
    position: Optional[str] = None
    ppg: Optional[float] = None
    apg: Optional[float] = None
    rpg: Optional[float] = None
    fg_percent: Optional[float] = None
    target_division: Optional[str] = None

class DrillRecommendation(BaseModel):
    """Individual drill with recommendation reason"""
    id: UUID
    name: str
    description: str
    category: str
    difficulty: Optional[str] = None
    position_focus: Optional[str] = None
    video_url: Optional[str] = None
    created_at: str
    why_recommended: str  # Explanation for why this drill was chosen

class DrillRecommendationResponse(BaseModel):
    """Response containing recommended drills"""
    drills: List[DrillRecommendation]
    total_count: int
    is_generic: bool = False  # True if user has no stats, recommendations are position-based only

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

@app.put("/api/profile/{user_id}")
def update_profile(user_id: str, profile: Profile):
    """Update user profile"""
    try:
        # Normalize UUID to lowercase
        user_id_lower = user_id.lower()

        # Get data from profile, excluding user_id (it's in the path)
        data = profile.dict(exclude={'user_id'})
        print(f"✅ Updating profile for {user_id_lower}: {data}")

        # Update the profile
        result = supabase.table("user_profiles") \
            .update(data) \
            .eq("user_id", user_id_lower) \
            .execute()

        if not result.data or len(result.data) == 0:
            raise HTTPException(status_code=404, detail="Profile not found")

        print(f"✅ Profile updated: {result.data}")
        return format_timestamps(result.data[0])
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error updating profile: {e}")
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

@app.get("/api/profile/{user_id}")
def get_profile(user_id: str):
    """Get user profile by user_id"""
    try:
        # Normalize UUID to lowercase for case-insensitive matching
        user_id_lower = user_id.lower()
        result = supabase.table("user_profiles") \
            .select("*") \
            .eq("user_id", user_id_lower) \
            .execute()

        if not result.data or len(result.data) == 0:
            raise HTTPException(status_code=404, detail="Profile not found")

        return format_timestamps(result.data[0])
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error getting profile: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/profile/{user_id}/measurables")
def get_measurables(user_id: str):
    """Get user measurables by user_id"""
    try:
        # Normalize UUID to lowercase for case-insensitive matching
        user_id_lower = user_id.lower()
        result = supabase.table("user_measurables") \
            .select("*") \
            .eq("user_id", user_id_lower) \
            .execute()

        if not result.data or len(result.data) == 0:
            raise HTTPException(status_code=404, detail="Measurables not found")

        return format_timestamps(result.data[0])
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error getting measurables: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/profile/{user_id}/stats")
def get_stats(user_id: str):
    """Get user stats by user_id"""
    try:
        # Normalize UUID to lowercase for case-insensitive matching
        user_id_lower = user_id.lower()
        result = supabase.table("user_stats") \
            .select("*") \
            .eq("user_id", user_id_lower) \
            .execute()

        if not result.data or len(result.data) == 0:
            raise HTTPException(status_code=404, detail="Stats not found")

        return format_timestamps(result.data[0])
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error getting stats: {e}")
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

# ==================== PLAYER MATCHING ====================

def encode_position(position: str) -> int:
    """Encode position for K-NN: Guard=1, Forward=2, Big=3"""
    position_map = {
        'Guard': 1,
        'Forward': 2,
        'Big': 3,
        'Center': 3  # Normalize Center to Big
    }
    return position_map.get(position, 2)  # Default to Forward

def encode_division(division: str) -> int:
    """Encode division for K-NN: D1=4, D2=3, D3=2, NAIA=1"""
    division_map = {
        'D1': 4,
        'D2': 3,
        'D3': 2,
        'NAIA': 1
    }
    return division_map.get(division, 2)  # Default to D3

@app.post("/api/match", response_model=List[MatchResult])
def find_matches(request: MatchRequest):
    """
    Find top 5 similar college players using K-NN algorithm with division weighting.

    Features used (8 total):
    - height_inches
    - weight_lbs
    - position (encoded: Guard=1, Forward=2, Big=3)
    - ppg (points per game)
    - apg (assists per game)
    - rpg (rebounds per game)
    - fg_percent (field goal percentage)
    - division (encoded: D1=4, D2=3, D3=2, NAIA=1)

    Division weighting: 8% boost for matches in target division
    """
    try:
        print(f"✅ Received match request: {request}")

        # Step 1: Fetch user data if user_id provided
        user_data = None
        if request.user_id:
            user_id_str = str(request.user_id).lower()

            # Fetch profile
            profile_result = supabase.table("user_profiles").select("*").eq("user_id", user_id_str).execute()
            profile = profile_result.data[0] if profile_result.data else None

            # Fetch measurables
            measurables_result = supabase.table("user_measurables").select("*").eq("user_id", user_id_str).execute()
            measurables = measurables_result.data[0] if measurables_result.data else None

            # Fetch stats
            stats_result = supabase.table("user_stats").select("*").eq("user_id", user_id_str).execute()
            stats = stats_result.data[0] if stats_result.data else None

            if profile and measurables and stats:
                user_data = {
                    'height_inches': measurables.get('height_inches'),
                    'weight_lbs': measurables.get('weight_lbs'),
                    'position': profile.get('position'),
                    'ppg': stats.get('ppg'),
                    'apg': stats.get('apg'),
                    'rpg': stats.get('rpg'),
                    'fg_percent': stats.get('fg_percent'),
                    'target_division': profile.get('target_division')
                }
                print(f"✅ Fetched user data: {user_data}")

        # Step 2: Use provided data or user data
        height = request.height_inches or (user_data['height_inches'] if user_data else None)
        weight = request.weight_lbs or (user_data['weight_lbs'] if user_data else None)
        position = request.position or (user_data['position'] if user_data else None)
        ppg = request.ppg or (user_data['ppg'] if user_data else None)
        apg = request.apg or (user_data['apg'] if user_data else None)
        rpg = request.rpg or (user_data['rpg'] if user_data else None)
        fg_percent = request.fg_percent or (user_data['fg_percent'] if user_data else None)
        target_division = request.target_division or (user_data['target_division'] if user_data else None)

        # Validate required fields
        if not all([height, weight, position, ppg is not None, apg is not None, rpg is not None, fg_percent is not None]):
            raise HTTPException(status_code=400, detail="Missing required fields for matching")

        print(f"✅ Using data: height={height}, weight={weight}, position={position}, ppg={ppg}, apg={apg}, rpg={rpg}, fg_percent={fg_percent}, target_division={target_division}")

        # Step 3: Fetch ALL college players from database
        college_players_result = supabase.table("college_players").select("*").execute()
        college_players = college_players_result.data

        if not college_players or len(college_players) < 5:
            raise HTTPException(status_code=404, detail="Insufficient college players in database for matching")

        print(f"✅ Fetched {len(college_players)} college players")

        # Step 4: Prepare feature matrix for K-NN
        # Features: [height, weight, position, ppg, apg, rpg, fg_percent, division]
        user_features = [
            height,
            weight,
            encode_position(position),
            ppg,
            apg,
            rpg,
            fg_percent,
            encode_division(target_division) if target_division else 2
        ]

        college_features = []
        valid_players = []

        for player in college_players:
            # Skip players with missing critical data
            # Note: CSV uses hs_senior_* and division_level field names
            if not all([
                player.get('college_height_inches'),
                player.get('college_weight_lbs'),
                player.get('position'),
                player.get('hs_senior_ppg') is not None,
                player.get('hs_senior_apg') is not None,
                player.get('hs_senior_rpg') is not None,
                player.get('hs_senior_fg_percent') is not None,
                player.get('division_level')
            ]):
                continue

            features = [
                player['college_height_inches'],
                player['college_weight_lbs'],
                encode_position(player['position']),
                player['hs_senior_ppg'],
                player['hs_senior_apg'],
                player['hs_senior_rpg'],
                player['hs_senior_fg_percent'],
                encode_division(player['division_level'])
            ]
            college_features.append(features)
            valid_players.append(player)

        if len(valid_players) < 5:
            raise HTTPException(status_code=404, detail="Insufficient valid college players for matching")

        print(f"✅ Prepared features for {len(valid_players)} valid players")

        # Step 5: Normalize features using StandardScaler
        scaler = StandardScaler()
        college_features_scaled = scaler.fit_transform(college_features)
        user_features_scaled = scaler.transform([user_features])

        # Step 6: Run K-NN to find top 10 candidates
        k = min(10, len(valid_players))
        knn = NearestNeighbors(n_neighbors=k, metric='euclidean')
        knn.fit(college_features_scaled)
        distances, indices = knn.kneighbors(user_features_scaled)

        print(f"✅ K-NN found {k} nearest neighbors")

        # Step 7: Apply division weighting and calculate similarity scores
        # Find max distance for normalization
        max_distance = np.max(distances[0]) if len(distances[0]) > 0 else 1.0

        candidates = []
        for i, (distance, index) in enumerate(zip(distances[0], indices[0])):
            player = valid_players[index]

            # Convert distance to similarity score (0-100)
            # Normalize: closest match = 100%, furthest in top 10 = lower score
            # Formula: 100 * (1 - distance / max_distance)
            if max_distance > 0:
                similarity = 100 * (1 - (distance / max_distance))
            else:
                similarity = 100.0

            # Apply 8% boost if player is in target division
            if target_division and player['division_level'] == target_division:
                similarity = min(100, similarity * 1.08)
                print(f"   Applied 8% boost to {player['name']} (target division: {target_division})")

            candidates.append({
                'player': player,
                'similarity': similarity,
                'distance': distance
            })

        # Step 8: Sort by similarity (descending) and return top 5
        candidates.sort(key=lambda x: x['similarity'], reverse=True)
        top_5 = candidates[:5]

        # Step 9: Format results
        results = []
        for candidate in top_5:
            player = candidate['player']
            results.append(MatchResult(
                player_id=UUID(player['id']),
                name=player['name'],
                college=player.get('college_name'),
                division=player['division_level'],
                position=player['position'],
                similarity_score=round(candidate['similarity'], 1),
                college_height_inches=player['college_height_inches'],
                college_weight_lbs=player['college_weight_lbs'],
                hs_ppg=player.get('hs_senior_ppg'),
                hs_apg=player.get('hs_senior_apg'),
                hs_rpg=player.get('hs_senior_rpg'),
                hs_fg_percent=player.get('hs_senior_fg_percent'),
                hs_3p_percent=player.get('hs_senior_3p_percent'),
                photo_url=player.get('photo_url')
            ))

        print(f"✅ Returning top 5 matches:")
        for i, result in enumerate(results, 1):
            print(f"   {i}. {result.name} ({result.division}) - {result.similarity_score}% match")

        return results

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error finding matches: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

# ============================================
# TRAINING DRILL RECOMMENDATION FUNCTIONS
# ============================================

def normalize_position(position: str) -> str:
    """
    Convert specific positions to college position groups.

    Args:
        position: User position (PG, SG, SF, PF, C, Guard, Forward, Big)

    Returns:
        Normalized position group: Guard, Forward, or Big
    """
    guard_positions = ['PG', 'SG', 'Guard']
    forward_positions = ['SF', 'PF', 'Forward']
    big_positions = ['C', 'Big', 'Center']

    if position in guard_positions:
        return 'Guard'
    elif position in forward_positions:
        return 'Forward'
    elif position in big_positions:
        return 'Big'
    else:
        return 'All'

def get_drills_by_category(
    category: str,
    position_focus: str,
    limit: int = 2
) -> List[dict]:
    """
    Fetch drills from database by category and position focus.
    Randomize to provide variety across requests.

    Args:
        category: Drill category (Shooting, Ball-Handling, Defense, Conditioning, Passing)
        position_focus: Position group (Guard, Forward, Big, All)
        limit: Number of drills to return

    Returns:
        List of drill dictionaries
    """
    try:
        # Query drills matching category
        query = supabase.table("training_drills").select("*").eq("category", category)

        # Filter by position focus (include 'All' position drills)
        if position_focus != 'All':
            query = query.or_(f"position_focus.eq.{position_focus},position_focus.eq.All")

        result = query.execute()
        drills = result.data

        if not drills:
            print(f"⚠️ No drills found for category={category}, position={position_focus}")
            return []

        # Randomize for variety
        import random
        random.shuffle(drills)

        return drills[:limit]

    except Exception as e:
        print(f"❌ Error fetching drills for category {category}: {e}")
        return []

def get_drill_recommendations(
    position: str,
    ppg: float,
    apg: float,
    rpg: float,
    fg_percent: float,
    target_division: Optional[str] = None,
    is_generic: bool = False
) -> tuple[List[DrillRecommendation], bool]:
    """
    Rule-based drill recommendation algorithm.

    Args:
        position: User position
        ppg: Points per game
        apg: Assists per game
        rpg: Rebounds per game
        fg_percent: Field goal percentage
        target_division: Target division (D1/D2/D3/NAIA)
        is_generic: If True, provide generic recommendations without stat-based logic

    Returns:
        Tuple of (list of recommended drills, is_generic flag)

    Rules:
        1. FG% < 40% → Add 2 Shooting drills
        2. Position in [PG, SG, Guard] AND APG < 3 → Add 2 Passing drills
        3. Position in [PG, SG, Guard] → Add 2 Ball-Handling drills
        4. Position in [SF, PF, Forward] → Add 1 Defense, 1 Shooting
        5. Position in [C, Big] → Add 1 Defense, 1 Conditioning
        6. ALWAYS add 1 Conditioning drill
    """
    recommendations = []
    reasons = []

    # Normalize position to college position groups
    position_group = normalize_position(position)

    if is_generic:
        # Generic recommendations based on position only
        print(f"✅ Generating generic recommendations for {position_group}")

        if position_group == 'Guard':
            # Guards: 2 Ball-Handling + 2 Shooting + 1 Passing + 1 Defense + 1 Conditioning
            ballhandling_drills = get_drills_by_category('Ball-Handling', 'Guard', limit=2)
            shooting_drills = get_drills_by_category('Shooting', 'Guard', limit=2)
            passing_drills = get_drills_by_category('Passing', 'Guard', limit=1)
            defense_drills = get_drills_by_category('Defense', 'All', limit=1)
            conditioning_drills = get_drills_by_category('Conditioning', 'All', limit=1)

            for drill in ballhandling_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Elite ball-handling is essential for guards at every college level.'})
            for drill in shooting_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Consistent shooting separates good guards from great ones.'})
            for drill in passing_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Playmaking ability makes guards valuable to college teams.'})
            for drill in defense_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Guards who can defend earn playing time.'})
            for drill in conditioning_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'College basketball demands elite conditioning.'})

            recommendations.extend(ballhandling_drills)
            recommendations.extend(shooting_drills)
            recommendations.extend(passing_drills)
            recommendations.extend(defense_drills)
            recommendations.extend(conditioning_drills)

        elif position_group == 'Forward':
            # Forwards: 2 Shooting + 1 Defense + 1 Ball-Handling + 1 Conditioning + 1 Passing
            shooting_drills = get_drills_by_category('Shooting', 'All', limit=2)
            defense_drills = get_drills_by_category('Defense', 'All', limit=1)
            ballhandling_drills = get_drills_by_category('Ball-Handling', 'Guard', limit=1)
            conditioning_drills = get_drills_by_category('Conditioning', 'All', limit=1)
            passing_drills = get_drills_by_category('Passing', 'All', limit=1)

            for drill in shooting_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Modern forwards need to stretch the floor with consistent shooting.'})
            for drill in defense_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Versatile forwards must be strong on both ends.'})
            for drill in ballhandling_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Ball-handling skills make forwards more versatile.'})
            for drill in conditioning_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'College basketball demands elite conditioning.'})
            for drill in passing_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Forwards who can pass create opportunities for teammates.'})

            recommendations.extend(shooting_drills)
            recommendations.extend(defense_drills)
            recommendations.extend(ballhandling_drills)
            recommendations.extend(conditioning_drills)
            recommendations.extend(passing_drills)

        elif position_group == 'Big':
            # Centers/Bigs: 2 Defense + 2 Conditioning + 1 Shooting + 1 Passing + 1 Ball-Handling
            defense_drills = get_drills_by_category('Defense', 'Forward', limit=2)
            conditioning_drills = get_drills_by_category('Conditioning', 'All', limit=2)
            shooting_drills = get_drills_by_category('Shooting', 'All', limit=1)
            passing_drills = get_drills_by_category('Passing', 'All', limit=1)
            ballhandling_drills = get_drills_by_category('Ball-Handling', 'Guard', limit=1)

            for drill in defense_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Interior defense and rebounding are your primary value.'})
            for drill in conditioning_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Bigs need elite conditioning to run the floor.'})
            for drill in shooting_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Developing a mid-range shot makes you harder to guard.'})
            for drill in passing_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Bigs who can pass create offensive opportunities.'})
            for drill in ballhandling_drills:
                reasons.append({'drill_id': drill['id'], 'reason': 'Basic ball-handling helps you avoid turnovers.'})

            recommendations.extend(defense_drills)
            recommendations.extend(conditioning_drills)
            recommendations.extend(shooting_drills)
            recommendations.extend(passing_drills)
            recommendations.extend(ballhandling_drills)

        is_generic = True

    else:
        # Personalized recommendations based on stats
        print(f"✅ Generating personalized recommendations for {position_group}: ppg={ppg}, apg={apg}, fg%={fg_percent}")

        # Rule 1: Shooting (if poor FG%)
        if fg_percent < 40:
            shooting_drills = get_drills_by_category('Shooting', position_group, limit=2)
            for drill in shooting_drills:
                reasons.append({
                    'drill_id': drill['id'],
                    'reason': f'Your FG% ({fg_percent:.1f}%) is below 40%. Improving shooting mechanics will boost scoring efficiency.'
                })
            recommendations.extend(shooting_drills)

        # Rule 2: Passing (for guards with low assists)
        if position_group == 'Guard' and apg < 3:
            passing_drills = get_drills_by_category('Passing', 'Guard', limit=2)
            for drill in passing_drills:
                reasons.append({
                    'drill_id': drill['id'],
                    'reason': f'As a guard averaging {apg:.1f} APG, improving playmaking will make you more valuable to college coaches.'
                })
            recommendations.extend(passing_drills)

        # Rule 3: Ball-Handling (all guards)
        if position_group == 'Guard':
            ballhandling_drills = get_drills_by_category('Ball-Handling', 'Guard', limit=2)
            for drill in ballhandling_drills:
                reasons.append({
                    'drill_id': drill['id'],
                    'reason': 'Elite ball-handling is essential for guards at every college level.'
                })
            recommendations.extend(ballhandling_drills)

        # Rule 4: Forwards - balanced approach
        if position_group == 'Forward':
            defense_drills = get_drills_by_category('Defense', 'All', limit=1)
            shooting_drills = get_drills_by_category('Shooting', 'All', limit=1)

            for drill in defense_drills:
                reasons.append({
                    'drill_id': drill['id'],
                    'reason': 'Versatile forwards must be strong on both ends. Defense wins playing time.'
                })

            for drill in shooting_drills:
                reasons.append({
                    'drill_id': drill['id'],
                    'reason': 'Modern forwards need to stretch the floor with consistent shooting.'
                })

            recommendations.extend(defense_drills)
            recommendations.extend(shooting_drills)

        # Rule 5: Centers/Bigs - interior focus
        if position_group == 'Big':
            defense_drills = get_drills_by_category('Defense', position_group, limit=1)
            for drill in defense_drills:
                reasons.append({
                    'drill_id': drill['id'],
                    'reason': 'Interior defense and rebounding are your primary value at the college level.'
                })
            recommendations.extend(defense_drills)

        # Rule 6: ALWAYS include conditioning
        conditioning_drills = get_drills_by_category('Conditioning', 'All', limit=1)
        for drill in conditioning_drills:
            reasons.append({
                'drill_id': drill['id'],
                'reason': 'College basketball demands elite conditioning. Players who can sustain intensity earn minutes.'
            })
        recommendations.extend(conditioning_drills)

        is_generic = False

    # Ensure we have 5-7 drills (fill gaps if needed)
    if len(recommendations) < 5:
        print(f"⚠️ Only {len(recommendations)} drills, adding fillers to reach minimum")
        # Add general drills to reach minimum
        filler_drills = get_drills_by_category('Defense', 'All', limit=5 - len(recommendations))
        for drill in filler_drills:
            reasons.append({
                'drill_id': drill['id'],
                'reason': 'Well-rounded players excel at multiple skills.'
            })
        recommendations.extend(filler_drills)

    # Limit to 7 drills max
    recommendations = recommendations[:7]

    # Match reasons to final drill list
    reason_map = {r['drill_id']: r['reason'] for r in reasons}

    # Format response
    formatted_drills = []
    for drill in recommendations:
        formatted_drills.append(DrillRecommendation(
            id=drill['id'],
            name=drill['name'],
            description=drill['description'],
            category=drill['category'],
            difficulty=drill.get('difficulty'),
            position_focus=drill.get('position_focus'),
            video_url=drill.get('video_url'),
            created_at=drill['created_at'],
            why_recommended=reason_map.get(drill['id'], 'Recommended for your development.')
        ))

    return formatted_drills, is_generic

# ============================================
# TRAINING DRILL RECOMMENDATION ENDPOINT
# ============================================

@app.post("/api/drills/recommend", response_model=DrillRecommendationResponse)
def recommend_drills(request: DrillRecommendationRequest):
    """
    POST /api/drills/recommend

    Get personalized drill recommendations based on user stats.

    Accepts either:
    - user_id: Fetch stats from database
    - Direct stats: position, ppg, apg, rpg, fg_percent

    Returns: 5-7 personalized drills with explanations
    """
    try:
        print(f"✅ Received drill recommendation request: {request}")

        # Step 1: Get user stats (either from DB or direct input)
        if request.user_id:
            user_id_str = str(request.user_id).lower()

            # Fetch user profile for position and target_division
            profile_result = supabase.table("user_profiles").select("*").eq("user_id", user_id_str).execute()
            if not profile_result.data:
                raise HTTPException(status_code=404, detail="User profile not found")
            profile = profile_result.data[0]

            position = profile.get('position')
            if not position:
                raise HTTPException(status_code=400, detail="User profile missing position field")

            target_division = profile.get('target_division')

            # Fetch user stats (if available)
            stats_result = supabase.table("user_stats").select("*").eq("user_id", user_id_str).execute()

            if not stats_result.data:
                # No stats - provide generic recommendations
                print(f"⚠️ User {user_id_str} has no stats. Providing generic recommendations.")
                ppg = 0
                apg = 0
                rpg = 0
                fg_percent = 0
                is_generic = True
            else:
                # Has stats - provide personalized recommendations
                stats = stats_result.data[0]
                ppg = stats.get('ppg', 0) or 0
                apg = stats.get('apg', 0) or 0
                rpg = stats.get('rpg', 0) or 0
                fg_percent = stats.get('fg_percent', 0) or 0
                is_generic = False

        else:
            # Use direct input
            position = request.position
            ppg = request.ppg or 0
            apg = request.apg or 0
            rpg = request.rpg or 0
            fg_percent = request.fg_percent or 0
            target_division = request.target_division
            is_generic = False

        # Validate required fields
        if not position:
            raise HTTPException(status_code=400, detail="Position is required for drill recommendations")

        print(f"✅ Generating recommendations for: position={position}, ppg={ppg}, apg={apg}, rpg={rpg}, fg%={fg_percent}, generic={is_generic}")

        # Step 2: Run recommendation algorithm
        recommended_drills, is_generic_flag = get_drill_recommendations(
            position=position,
            ppg=ppg,
            apg=apg,
            rpg=rpg,
            fg_percent=fg_percent,
            target_division=target_division,
            is_generic=is_generic
        )

        print(f"✅ Generated {len(recommended_drills)} drill recommendations (generic={is_generic_flag})")

        return DrillRecommendationResponse(
            drills=recommended_drills,
            total_count=len(recommended_drills),
            is_generic=is_generic_flag
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error recommending drills: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
