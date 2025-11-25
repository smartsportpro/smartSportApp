#!/usr/bin/env python3
"""
Generate enhanced college player dataset with estimated HS stats
Adds realistic high school statistics based on position and division
"""

import csv
import random
import uuid

def convert_height_to_inches(height_str):
    """Convert 6'5 format to inches"""
    feet, inches = height_str.replace('"', '').split("'")
    return int(feet) * 12 + int(inches)

def normalize_position(position):
    """Keep Guard/Forward/Big positions (as colleges list them)"""
    position_map = {
        'Guard': 'Guard',
        'Forward': 'Forward',
        'Big': 'Big',
        'Center': 'Big'  # Normalize Center to Big
    }
    return position_map.get(position, position)

def generate_hs_stats(position, division):
    """Generate realistic HS stats based on position and division"""
    # Base stats by division (D1 players had better HS stats)
    division_multipliers = {
        'D1': 1.2,
        'D2': 1.0,
        'D3': 0.85,
        'NAIA': 0.9
    }
    mult = division_multipliers.get(division, 1.0)

    # Position-specific stat templates
    if position == 'Guard':
        ppg = round(random.uniform(15, 25) * mult, 1)
        apg = round(random.uniform(4, 8) * mult, 1)
        rpg = round(random.uniform(3, 6) * mult, 1)
        fg_percent = round(random.uniform(40, 50), 1)
        three_p_percent = round(random.uniform(32, 42), 1)
    elif position == 'Forward':
        ppg = round(random.uniform(14, 22) * mult, 1)
        apg = round(random.uniform(2, 5) * mult, 1)
        rpg = round(random.uniform(6, 10) * mult, 1)
        fg_percent = round(random.uniform(42, 52), 1)
        three_p_percent = round(random.uniform(28, 38), 1)
    else:  # Big/Center
        ppg = round(random.uniform(12, 20) * mult, 1)
        apg = round(random.uniform(1, 3) * mult, 1)
        rpg = round(random.uniform(8, 14) * mult, 1)
        fg_percent = round(random.uniform(48, 58), 1)
        three_p_percent = round(random.uniform(0, 25), 1)

    return ppg, apg, rpg, fg_percent, three_p_percent

# Fake college names by division
colleges = {
    'D1': ['Duke', 'North Carolina', 'Kentucky', 'Kansas', 'Villanova', 'UCLA', 'Michigan', 'Virginia', 'Arizona', 'Texas'],
    'D2': ['Grand Valley State', 'Northwest Missouri', 'Augustana', 'Winona State', 'Ashland', 'Lincoln Memorial', 'West Texas A&M', 'Cal State San Bernardino', 'Queens', 'Flagler'],
    'D3': ['Williams', 'Amherst', 'MIT', 'Chicago', 'Johns Hopkins', 'Emory', 'Washington', 'St. Thomas', 'Hope', 'Calvin'],
    'NAIA': ['Southwestern', 'Georgetown (KY)', 'Columbia (MO)', 'William Carey', 'Indiana Wesleyan', 'Oklahoma City', 'Shawnee State', 'Freed-Hardeman', 'Morningside', 'Dordt']
}

# High school names
hs_names = [
    'Central High School', 'Lincoln Prep', 'St. Joseph Academy', 'Roosevelt High',
    'Madison Prep', 'Washington High', 'Oak Hill Academy', 'Montverde Academy',
    'IMG Academy', 'Sierra Canyon', 'Bishop Gorman', 'La Lumiere',
    'Findlay Prep', 'Brewster Academy', 'South Kent Prep', 'St. Benedict\'s'
]

# Read existing players
players = []
with open('players.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if not row['Name']:  # Skip empty rows
            continue

        player = {
            'id': str(uuid.uuid4()),
            'name': row['Name'],
            'college_name': random.choice(colleges.get(row['Level'], colleges['D2'])),
            'high_school_name': random.choice(hs_names),
            'division_level': row['Level'],
            'position': normalize_position(row['Position']),  # Keep Guard/Forward/Big
            'college_height_inches': convert_height_to_inches(row['Height']),
            'college_weight_lbs': int(row['Weight']),
        }

        # Generate HS stats (ALL ESTIMATED for existing players)
        ppg, apg, rpg, fg_percent, three_p = generate_hs_stats(player['position'], player['division_level'])
        player['hs_senior_ppg'] = ppg
        player['hs_senior_apg'] = apg
        player['hs_senior_rpg'] = rpg
        player['hs_senior_fg_percent'] = fg_percent
        player['hs_senior_3p_percent'] = three_p

        player['photo_url'] = None
        player['video_availability'] = random.choice(['individual', 'team', 'none'])
        player['data_source'] = 'real_player_estimated_stats'  # Mark clearly for replacement

        players.append(player)

# Generate completely fake D3 and NAIA players to fill dataset
fake_players = [
    # D3 Players (10 total)
    {'Name': '[FAKE] Michael Chen', 'Position': 'Guard', 'Level': 'D3', 'Weight': '175', 'Height': '6\'1'},
    {'Name': '[FAKE] David Martinez', 'Position': 'Guard', 'Level': 'D3', 'Weight': '180', 'Height': '5\'11'},
    {'Name': '[FAKE] James Wilson', 'Position': 'Forward', 'Level': 'D3', 'Weight': '200', 'Height': '6\'6'},
    {'Name': '[FAKE] Robert Taylor', 'Position': 'Forward', 'Level': 'D3', 'Weight': '210', 'Height': '6\'7'},
    {'Name': '[FAKE] Christopher Anderson', 'Position': 'Big', 'Level': 'D3', 'Weight': '220', 'Height': '6\'9'},
    {'Name': '[FAKE] Matthew Thomas', 'Position': 'Guard', 'Level': 'D3', 'Weight': '170', 'Height': '6\'0'},
    {'Name': '[FAKE] Daniel Jackson', 'Position': 'Forward', 'Level': 'D3', 'Weight': '195', 'Height': '6\'5'},
    {'Name': '[FAKE] Anthony White', 'Position': 'Guard', 'Level': 'D3', 'Weight': '185', 'Height': '6\'2'},
    {'Name': '[FAKE] Joshua Harris', 'Position': 'Big', 'Level': 'D3', 'Weight': '215', 'Height': '6\'10'},
    {'Name': '[FAKE] Andrew Martin', 'Position': 'Forward', 'Level': 'D3', 'Weight': '205', 'Height': '6\'6'},

    # NAIA Players (10 total)
    {'Name': '[FAKE] Tyler Thompson', 'Position': 'Guard', 'Level': 'NAIA', 'Weight': '175', 'Height': '6\'0'},
    {'Name': '[FAKE] Brandon Garcia', 'Position': 'Guard', 'Level': 'NAIA', 'Weight': '180', 'Height': '5\'10'},
    {'Name': '[FAKE] Kevin Martinez', 'Position': 'Forward', 'Level': 'NAIA', 'Weight': '200', 'Height': '6\'5'},
    {'Name': '[FAKE] Justin Rodriguez', 'Position': 'Forward', 'Level': 'NAIA', 'Weight': '210', 'Height': '6\'7'},
    {'Name': '[FAKE] Ryan Wilson', 'Position': 'Big', 'Level': 'NAIA', 'Weight': '225', 'Height': '6\'9'},
    {'Name': '[FAKE] Jason Moore', 'Position': 'Guard', 'Level': 'NAIA', 'Weight': '170', 'Height': '6\'1'},
    {'Name': '[FAKE] Eric Taylor', 'Position': 'Forward', 'Level': 'NAIA', 'Weight': '195', 'Height': '6\'6'},
    {'Name': '[FAKE] Steven Anderson', 'Position': 'Guard', 'Level': 'NAIA', 'Weight': '185', 'Height': '6\'2'},
    {'Name': '[FAKE] Brian Thomas', 'Position': 'Big', 'Level': 'NAIA', 'Weight': '220', 'Height': '6\'10'},
    {'Name': '[FAKE] Nicholas Jackson', 'Position': 'Forward', 'Level': 'NAIA', 'Weight': '205', 'Height': '6\'7'},
]

for row in fake_players:
    player = {
        'id': str(uuid.uuid4()),
        'name': row['Name'],  # Name has [FAKE] prefix
        'college_name': random.choice(colleges.get(row['Level'], colleges['D2'])),
        'high_school_name': random.choice(hs_names),
        'division_level': row['Level'],
        'position': normalize_position(row['Position']),
        'college_height_inches': convert_height_to_inches(row['Height']),
        'college_weight_lbs': int(row['Weight']),
    }

    # Generate HS stats
    ppg, apg, rpg, fg_percent, three_p = generate_hs_stats(player['position'], player['division_level'])
    player['hs_senior_ppg'] = ppg
    player['hs_senior_apg'] = apg
    player['hs_senior_rpg'] = rpg
    player['hs_senior_fg_percent'] = fg_percent
    player['hs_senior_3p_percent'] = three_p

    player['photo_url'] = None
    player['video_availability'] = 'none'  # Fake players have no video
    player['data_source'] = 'generated_fake'  # CLEARLY marked for easy removal

    players.append(player)

# Write to CSV
with open('college_players_complete.csv', 'w', newline='') as f:
    fieldnames = ['id', 'name', 'college_name', 'high_school_name', 'division_level', 'position',
                  'college_height_inches', 'college_weight_lbs', 'hs_senior_ppg', 'hs_senior_apg',
                  'hs_senior_rpg', 'hs_senior_fg_percent', 'hs_senior_3p_percent', 'photo_url',
                  'video_availability', 'data_source']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(players)

print(f"✅ Generated {len(players)} college players with HS stats")
print(f"\nBreakdown by division:")
for division in ['D1', 'D2', 'D3', 'NAIA']:
    count = sum(1 for p in players if p['division_level'] == division)
    real = sum(1 for p in players if p['division_level'] == division and p['data_source'] == 'real_player_estimated_stats')
    fake = sum(1 for p in players if p['division_level'] == division and p['data_source'] == 'generated_fake')
    print(f"   {division}: {count} players ({real} real w/ estimated stats, {fake} fake)")

print(f"\nData Sources:")
print(f"   real_player_estimated_stats: Real players with estimated HS stats (can be replaced)")
print(f"   generated_fake: Completely fake players (marked with [FAKE] prefix)")
print(f"\nPositions used: Guard, Forward, Big (matches college listings)")
print(f"\nOutput: college_players_complete.csv")
print(f"\nTo replace data later:")
print(f"   1. DELETE WHERE data_source = 'generated_fake' (removes all [FAKE] players)")
print(f"   2. UPDATE WHERE data_source = 'real_player_estimated_stats' (replace HS stats with real data)")
