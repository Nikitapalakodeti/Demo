select distinct
    player_id,
    player_name,
    position,
    age,
    salary,
    team_id,
    team_name,
    city,
    conference
from {{ ref('intr_player_game_stats') }}