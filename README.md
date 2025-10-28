# SmartSport

## Project Overview

SmartSport is a mobile application that helps high school basketball players identify which college players they should model their game after based on physical attributes and playing statistics. The app provides personalized training recommendations, film study resources, and performance tracking to help athletes achieve their recruitment goals.

### Target Users
- High school basketball players (ages 14-18)
- Athletes seeking college recruitment at various levels (D1, D2, D3, NAIA)
- Players without access to elite training resources

### Core Value Proposition
Unlike other basketball training apps that compare users to NBA superstars, SmartSport matches users with realistic role models - college players who had similar physical attributes and high school statistics. This provides achievable benchmarks and actionable pathways to college basketball.

---

## Product Vision

**Problem**: Most youth athletes don't have access to elite training resources or realistic benchmarks for their development. Comparing themselves to NBA players is unrealistic and unhelpful.

**Solution**: Match high school players with college athletes who had similar measurables and high school stats, showing them:
1. What level of play they can realistically achieve (D1, D2, D3, NAIA)
2. What high school performance is needed to get recruited at that level
3. Film study of actual players at their target level
4. Personalized training plans based on their stats and goals

**Key Insight**: A 6'1" guard averaging 14 PPG in high school needs to see college guards who had the same profile, not NBA All-Stars who were 6'6" averaging 25 PPG.

---

## Technology Stack

### Frontend
- **Framework**: SwiftUI (iOS native)
- **Language**: Swift
- **State Management**: Native SwiftUI state
- **Navigation**: SwiftUI NavigationStack
- **Minimum iOS**: iOS 16+

### Backend
- **Framework**: Python Flask or FastAPI
- **Language**: Python 3.9+
- **ML Library**: scikit-learn (K-Nearest Neighbors algorithm)
- **API Style**: RESTful JSON APIs

### Database
- **Primary Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth with JWT
- **Storage**: Supabase Storage (for images if needed)

### External APIs
- **YouTube Data API v3**: Video search and recommendations
- **Future**: MaxPreps API, 247Sports (for production data)

### Development Tools
- **Version Control**: Git/GitHub
- **Project Management**: Jira

---

## Architecture

### System Architecture (3-Tier)

```
┌─────────────────────────────────────┐
│     Mobile App (SwiftUI)            │
│  - User Interface                   │
│  - State Management                 │
│  - API Client                       │
└──────────────┬──────────────────────┘
               │ HTTPS/JSON
               │
┌──────────────▼──────────────────────┐
│     Backend Server (Python)         │
│  - REST API Endpoints               │
│  - K-NN Matching Algorithm          │
│  - Business Logic                   │
│  - YouTube API Integration          │
└──────────────┬──────────────────────┘
               │ SQL
               │
┌──────────────▼──────────────────────┐
│     Database (Supabase/PostgreSQL)  │
│  - User Profiles                    │
│  - College Players Dataset          │
│  - Game Statistics                  │
│  - Training Drills                  │
└─────────────────────────────────────┘
```

### Key Components

**Frontend Components**:
- Authentication screens (Login, Signup, Forgot Password)
- Profile creation flow (Basic Info, Measurables, Stats)
- Home screen with "Find My Match" CTA
- Match results display (card-based list)
- Player detail view (comparison, stats, videos)
- Stats tracking (add games, view history)
- Training plan display (recommended drills)
- Tab-based navigation

**Backend Services**:
- User authentication & authorization
- Player matching algorithm (K-NN)
- Video search & recommendation
- Training plan generation
- Stats calculation & aggregation

**Database Schema**:
- `users` - Authentication (managed by Supabase Auth)
- `user_profiles` - Basic user info
- `user_measurables` - Physical attributes
- `user_stats` - Current season statistics
- `user_game_stats` - Individual game records
- `college_players` - College player dataset
- `training_drills` - Curated drill library
- `curated_videos` - Manually selected videos (optional)

---

## Core Features

### 1. Player Matching Algorithm

**How It Works**:
- User inputs: height, weight, position, high school stats (PPG, RPG, APG, FG%)
- User selects target division level (D1, D2, D3, NAIA)
- K-Nearest Neighbors algorithm finds 5 most similar college players
- Similarity based on: physical measurables + high school performance
- Returns: college players with their freshman measurables + HS senior year stats

**Matching Features**:
- Height (inches)
- Weight (lbs)
- Position (PG, SG, SF, PF, C)
- High School PPG (Points Per Game)
- High School APG (Assists Per Game)
- High School RPG (Rebounds Per Game)
- High School FG% (Field Goal Percentage)

**Algorithm Details**:
- Library: scikit-learn KNeighborsClassifier/KNeighborsRegressor
- Features are normalized using StandardScaler
- Position encoded numerically (PG=1, SG=2, SF=3, PF=4, C=5)
- k=5 (return top 5 matches)
- Distance metric: Euclidean
- Feature weights: Position + measurables weighted slightly higher than stats

**Filters**:
- Division level (only show players from user's target division)
- Position (exact match or adjacent positions)

### 2. Film Study Integration

**Multi-Tier Video Search Strategy**:

Videos are searched in priority order:
1. **Individual player highlights** (best) - "[Player Name] [High School] basketball highlights"
2. **College highlights** - "[Player Name] [College Name] basketball"
3. **High school team games** - "[High School Name] basketball game"
4. **College team games** - "[College Name] basketball full game"
5. **Position drills** (fallback) - "[Position] basketball training drills"

**Video Display**:
- Show 3-5 videos per matched player
- Display: thumbnail, title, video type badge
- Context indicators: "Individual highlights", "Team footage - watch #12", "Training drill"
- Tap to open in YouTube app or web view

**API**: YouTube Data API v3
- Search quota: 10,000 units/day
- Cache results to minimize API calls
- Fallback to curated videos for demo players

### 3. Personalized Training Plans

**Rule-Based Recommendation System**:

Training drills are recommended based on:
- User's current stats vs target benchmarks
- Position-specific needs
- Identified weaknesses

**Recommendation Logic**:
```
IF FG% < 40% → Shooting drills (8 options)
IF APG < 3 (for guards) → Passing drills (5 options)
IF Position = Guard → Ball-handling drills (7 options)
IF Position = Forward/Center → Post moves, rebounding drills
IF Steals < 1 → Defense drills (6 options)
ALWAYS include → Conditioning drills (4 options)
```

**Drill Categories**:
- Shooting (8 drills)
- Ball-Handling (7 drills)
- Defense (6 drills)
- Conditioning (4 drills)
- Passing (5 drills)

**Total**: 25-30 curated drills with descriptions

**Output**: 5-7 personalized drill recommendations

### 4. Stats Tracking

**Game Stats Input**:
- Date, opponent name (optional)
- Minutes played
- Points, rebounds, assists, steals, blocks
- Field goal %, 3-point %

**Season Analytics**:
- Calculate season averages: PPG, RPG, APG, FG%, 3P%
- Show game-by-game history
- Track trends over season
- Update profile stats automatically

---

## Database Schema

### Users & Authentication (Managed by Supabase Auth)
```sql
-- Handled by Supabase Auth
auth.users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  encrypted_password TEXT,
  created_at TIMESTAMP
)
```

### User Profiles
```sql
user_profiles (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  age INTEGER,
  position TEXT, -- PG, SG, SF, PF, C
  target_division TEXT, -- D1, D2, D3, NAIA
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### User Measurables
```sql
user_measurables (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  height_inches INTEGER NOT NULL, -- Total inches (e.g., 73 = 6'1")
  weight_lbs INTEGER NOT NULL,
  wingspan_inches INTEGER, -- Optional
  vertical_jump_inches INTEGER, -- Optional
  updated_at TIMESTAMP
)
```

### User Current Stats
```sql
user_stats (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  ppg DECIMAL, -- Points per game
  rpg DECIMAL, -- Rebounds per game
  apg DECIMAL, -- Assists per game
  fg_percent DECIMAL, -- Field goal %
  three_p_percent DECIMAL, -- 3-point %
  updated_at TIMESTAMP
)
```

### Game Statistics
```sql
user_game_stats (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  game_date DATE NOT NULL,
  opponent_name TEXT,
  minutes_played INTEGER,
  points INTEGER,
  rebounds INTEGER,
  assists INTEGER,
  steals INTEGER,
  blocks INTEGER,
  fg_percent DECIMAL,
  three_p_percent DECIMAL,
  created_at TIMESTAMP
)

CREATE INDEX idx_user_game_stats_user_date ON user_game_stats(user_id, game_date DESC);
```

### College Players Dataset
```sql
college_players (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  college_name TEXT NOT NULL,
  division_level TEXT NOT NULL, -- D1, D2, D3, NAIA
  position TEXT NOT NULL, -- PG, SG, SF, PF, C
  college_height_inches INTEGER NOT NULL,
  college_weight_lbs INTEGER NOT NULL,
  high_school_name TEXT,
  hs_senior_ppg DECIMAL,
  hs_senior_rpg DECIMAL,
  hs_senior_apg DECIMAL,
  hs_senior_fg_percent DECIMAL,
  hs_senior_3p_percent DECIMAL,
  photo_url TEXT, -- Player headshot
  video_availability TEXT, -- individual, team, none
  youtube_search_hint TEXT, -- Best search query
  data_source TEXT, -- verified, estimated
  notes TEXT,
  created_at TIMESTAMP
)

CREATE INDEX idx_college_players_position ON college_players(position);
CREATE INDEX idx_college_players_division ON college_players(division_level);
CREATE INDEX idx_college_players_height ON college_players(college_height_inches);
CREATE INDEX idx_college_players_weight ON college_players(college_weight_lbs);
```

### Training Drills
```sql
training_drills (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL, -- Shooting, Ball-Handling, Defense, Conditioning, Passing
  difficulty TEXT, -- Beginner, Intermediate, Advanced
  position_focus TEXT, -- Guard, Forward, Center, All
  video_url TEXT, -- YouTube demo video
  created_at TIMESTAMP
)

CREATE INDEX idx_training_drills_category ON training_drills(category);
CREATE INDEX idx_training_drills_position ON training_drills(position_focus);
```

### Curated Videos (Optional)
```sql
curated_videos (
  id UUID PRIMARY KEY,
  player_id UUID REFERENCES college_players(id),
  video_url TEXT NOT NULL,
  video_title TEXT,
  video_type TEXT, -- individual, team, drill
  display_order INTEGER,
  created_at TIMESTAMP
)
```

---

## API Endpoints

### Authentication
```
POST /api/auth/signup
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/forgot-password
```

### User Profile
```
POST /api/profile - Create user profile
GET /api/profile/{user_id} - Get user profile
PUT /api/profile/{user_id} - Update user profile
```

### Player Matching
```
POST /api/match
Body: {
  user_id: UUID (optional, will query profile)
  OR direct inputs:
  height_inches: Integer,
  weight_lbs: Integer,
  position: String,
  ppg: Decimal,
  apg: Decimal,
  rpg: Decimal,
  fg_percent: Decimal,
  target_division: String
}
Response: {
  matches: [
    {
      player_id: UUID,
      name: String,
      college: String,
      division: String,
      position: String,
      similarity_score: Float (0-100),
      college_height_inches: Integer,
      college_weight_lbs: Integer,
      hs_ppg: Decimal,
      hs_apg: Decimal,
      hs_rpg: Decimal,
      hs_fg_percent: Decimal,
      photo_url: String
    }
  ]
}
```

### Video Search
```
POST /api/videos/search
Body: {
  player_name: String,
  high_school: String,
  college_name: String,
  division_level: String,
  position: String
}
Response: {
  videos: [
    {
      video_id: String,
      title: String,
      thumbnail_url: String,
      url: String,
      video_type: String (individual/team/drill)
    }
  ]
}
```

### Training Plans
```
POST /api/drills/recommend
Body: {
  user_id: UUID (optional, will query stats)
  OR direct inputs:
  position: String,
  ppg: Decimal,
  apg: Decimal,
  rpg: Decimal,
  fg_percent: Decimal,
  target_division: String
}
Response: {
  drills: [
    {
      drill_id: UUID,
      name: String,
      description: String,
      category: String,
      difficulty: String,
      video_url: String
    }
  ]
}
```

### Game Statistics
```
POST /api/stats - Add game stats
GET /api/stats/{user_id} - Get all games + season averages
DELETE /api/stats/{game_id} - Delete a game
```

---

## Data Requirements

### College Player Dataset (Hand Built Sample Set for Project)

**Size**: 40-50 players

**Distribution**:
- D1: 15 players (30%)
- D2: 15 players (30%)
- D3: 15 players (30%)
- NAIA: 5 players (10%)

**Data Points Per Player**:
1. **Basic Info**: Name, current college, year, division level
2. **Position**: PG, SG, SF, PF, C
3. **College Measurables** (Freshman year): Height (inches), Weight (lbs)
4. **High School Info**: High school name, grad year
5. **High School Stats** (Senior year): PPG, RPG, APG, FG%, 3P%
6. **Optional**: Photo URL, video search hints

**Data Sources**:
- College rosters (for measurables)
- MaxPreps (for HS stats)
- 247Sports recruiting profiles
- College roster player bios
- Manual research for gaps

**Data Quality**:
- Mark each player as "verified" or "estimated"
- Prioritize players with verifiable data
- Use realistic estimates for gaps based on patterns

---

## User Flows

### 1. New User Onboarding
```
1. User opens app
2. Shown: Login/Signup screen
3. Taps "Sign Up"
4. Enters email and password
5. Creates profile:
   a. Basic info (name, age, position)
   b. Measurables (height, weight)
   c. Current stats (PPG, APG, RPG, FG%)
   d. Target division (D1, D2, D3, NAIA)
6. Navigates to home screen
7. Taps "Find My Match"
8. Shown: Match results (5 similar players)
```

### 2. Finding Matches
```
1. User taps "Find My Match" on home screen
2. Loading: "Finding your matches..."
3. Algorithm runs (filters by division, calculates similarity)
4. Results display: List of 5 matched players
5. Each card shows: Photo, name, college, similarity %, key stats
6. User taps player card
7. Player detail screen shows:
   - Full stats comparison
   - "You vs [Player]" side-by-side
   - Film study section (3-5 videos)
8. User watches videos or goes back
```

### 3. Adding Game Stats
```
1. User navigates to Stats tab
2. Taps "Add Game" button
3. Fills out game form:
   - Date picker
   - Opponent name (optional)
   - Stats: minutes, points, rebounds, assists, etc.
4. Taps "Save Game"
5. API calculates new season averages
6. Success message: "Game saved! Your averages have been updated"
7. Stats history screen shows:
   - Season averages at top
   - List of games below
```

### 4. Getting Training Plan
```
1. User navigates to Training tab
2. Taps "Generate Plan" (or auto-generates on load)
3. Loading: "Creating your personalized plan..."
4. Algorithm analyzes stats and identifies weaknesses
5. Recommendations display:
   - 5-7 drill cards
   - Each shows: name, category, difficulty, description
6. User taps drill to expand for full details
7. Optional: Tap video to watch demonstration
8. User can tap "Refresh Plan" for new recommendations
```

---

## UI/UX Guidelines

### Design Principles
- **Clean and Professional**: Target audience is serious athletes
- **Data-Driven**: Emphasize stats, metrics, comparisons
- **Actionable**: Every screen should have clear next steps
- **Encouraging**: Positive, motivating language

### Color Scheme
- Primary: Basketball orange (#FF6B35 or similar)
- Secondary: Dark blue/navy (#1F3A5F)
- Accent: Bright green for success states (#4CAF50)
- Background: White or light gray (#F5F5F5)
- Text: Dark gray (#333333)

### Typography
- Headers: Bold, clear, 18-24pt
- Body: Regular, readable, 14-16pt
- Stats/Numbers: Bold, emphasized
- Use SF Pro (iOS system font) for consistency

### Component Patterns
- **Cards**: Used for player matches, game history, drills
- **Progress Bars**: For similarity scores, profile completion
- **Badges**: For division level, position, video type
- **Icons**: SF Symbols (iOS native icons)

### Navigation
- **Tab Bar** (bottom): Home, Match, Stats, Training, Profile
- **Navigation Bar** (top): Back buttons, titles, action buttons
- **Modals**: For forms (add game, edit profile)

### Loading States
- Spinner with context-specific messages
- Skeleton loaders for list items
- Pull-to-refresh for data lists

### Empty States
- Friendly, encouraging messages
- Clear call-to-action buttons
- Example: "No games yet - Add your first game to start tracking your progress!"

### Error States
- Clear error messages
- Retry buttons
- Suggestions for resolution

---

## Development Workflow

### Branch Strategy
```
main (protected)
├── develop (integration branch)
│   ├── feature/authentication
│   ├── feature/profile-creation
│   ├── feature/player-matching
│   ├── feature/video-integration
│   ├── feature/stats-tracking
│   └── feature/training-plans
```

### Commit Message Format
```
<type>(<scope>): <subject>

Examples:
feat(auth): add login screen
fix(matching): correct similarity calculation
docs(readme): update API documentation
test(stats): add game stats calculation tests
```

### Code Style
**Swift**:
- Follow Swift API Design Guidelines
- Use meaningful variable names
- Comment complex logic

**Python**:
- Follow PEP 8
- Use type hints
- Docstrings for all functions
- Keep functions focused and small

### Testing Strategy
- **Manual Testing**: Complete user flows on physical device
- **Unit Tests**: Critical business logic (matching algorithm, stats calculations)
- **API Testing**: Use Postman or similar
- **Edge Cases**: Empty states, error conditions, boundary values

---

## Class Project Scope & Timeline

### Key Constraints
- Limited to class semester timeline
- Team members have other classes/responsibilities
- Must demonstrate concept, not build production-scale app
- Sample dataset acceptable (40-50 players vs. thousands)

### Class Project Deliverables
1. **Working Mobile App**: iOS app with core features
2. **Backend API**: Functional endpoints for matching, videos, training
3. **Sample Database**: 40-50 college players with realistic data
4. **Live Demo**: 5-7 minute presentation with live app demo
5. **Documentation**: README, API docs, architecture diagram

### Post-Class Vision
- Build real college player database (thousands of players)
- Web scraping for automated data collection
- Partnership with MaxPreps/247Sports for real-time data
- Expand to other sports (football, soccer, etc.)
- Coach/team features
- Community features (athlete profiles, recruiting network)

---

## Known Limitations (Class Project)

### Data Limitations
- **Sample dataset only**: 40-50 players vs. production needs thousands
- **Mixed data quality**: Some verified, some estimated
- **Manual data collection**: No automated scraping yet
- **Limited historical data**: Only current season or recent seasons

### Feature Limitations
- **iOS only**: Not building Android version for class
- **Basic video search**: No advanced content filtering or caching
- **Rule-based training plans**: Not using advanced ML, just simple logic
- **No social features**: No user profiles, following, messaging, etc.
- **No coach features**: Built for individual athletes only

### Technical Limitations
- **No offline mode**: Requires internet connection
- **Basic error handling**: Production would need more robust error recovery
- **No analytics**: Not tracking user behavior or engagement
- **No push notifications**: No real-time updates or reminders

### Acceptable Trade-offs for Class
- Using sample data with clear documentation of production approach
- Simplified features that demonstrate core concept
- Focus on one sport (basketball) to prove scalability
- Manual processes that would be automated in production

---

## Future Enhancements (Post-Class)

### Phase 1: Data & Scale
- Build real college player database (10,000+ players)
- Automated web scraping pipeline
- Partner with sports data providers
- Historical data (multiple years of recruits)

### Phase 2: Advanced Features
- Advanced ML for training recommendations
- Video analysis (computer vision)
- Progress tracking with trend analysis
- Social features (profiles, following, messaging)
- Comparison with peers (anonymous aggregated data)

### Phase 3: Platform Expansion
- Android app
- Web platform
- Coach/team management features
- Recruiting network features

### Phase 4: Sport Expansion
- Football
- Soccer
- Baseball
- Volleyball
- Other sports

### Phase 5: Monetization
- Freemium model
- Basic features free (player matching, limited video)
- Premium features:
  - Unlimited video access
  - Advanced analytics
  - Season trend analysis
  - Personalized coaching content
  - Priority support

---

## Getting Started

### Prerequisites
- **Xcode** 15+ (for iOS development)
- **Python** 3.9+
- **Supabase Account** (free tier)
- **YouTube Data API Key**
- **Git/GitHub** access

### Initial Setup

1. **Clone Repository**
```bash
git clone https://github.com/your-team/smartsport.git
cd smartsport
```

2. **Backend Setup**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. **Create `.env` file**
```
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
YOUTUBE_API_KEY=your_youtube_api_key
```

4. **Database Setup**
- Run SQL scripts in `/database` folder
- Create tables in Supabase dashboard
- Import sample player data CSV

5. **iOS App Setup**
```bash
cd ../ios
# Open SmartSport.xcodeproj in Xcode
# Update Supabase configuration in Config.swift
```

6. **Run Backend**
```bash
cd backend
python app.py
# Server runs on http://localhost:5000
```

7. **Run iOS App**
- Open Xcode
- Select simulator or physical device
- Press Run (⌘R)

---

## Success Metrics

### Definition of Done
- Feature works on physical device
- Code reviewed by at least one team member
- Basic error handling implemented
- Documented (comments in complex code)
- Tested with realistic data
- Merged to develop branch

### Class Project Success
- ✅ Working app demonstrating core concept
- ✅ Live demo runs smoothly
- ✅ Matching algorithm produces sensible results
- ✅ 40-50 player dataset with quality data
- ✅ Professional presentation
- ✅ Clear roadmap for production version

### Feature Completeness (Class Project)
- 🔴 **Must Have**: Auth, Profile, Matching Algorithm, Match Display, Training Plans
- 🟡 **Should Have**: Stats Tracking, Video Integration
- 🟢 **Nice to Have**: Polish features, animations, accessibility

---

## License

This project is for educational purposes as part of Syracuse University coursework.