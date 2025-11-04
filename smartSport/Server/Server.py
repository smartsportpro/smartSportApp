from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from supabase import create_client, Client

app = FastAPI()

url = "https://twcwyfebqjtpxxrzsogt.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3Y3d5ZmVicWp0cHh4cnpzb2d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MjA0MjgsImV4cCI6MjA3NTM5NjQyOH0.tgs-3DCYexZ244Vf9r9PrXfKdrWSff8-08TuYWTo5PQ"
supabase: Client = create_client(url, key)

class Profile(BaseModel):
    name: str
    age: int
    email: str
    position: str | None = None
    skill_level: str | None = None

@app.post("/api/profile")
def save_profile(profile: Profile):
    try:
        data = profile.dict()
        result = supabase.table("user_profiles").insert(data).execute()
        return {"status": "ok", "data": result.data}
    except Exception as e:
        print("❌ Error:", e)
        raise HTTPException(status_code=500, detail=str(e))
