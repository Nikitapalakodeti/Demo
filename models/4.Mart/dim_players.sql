select distinct
    player_id,
    player_name,
    position,
    team_id,
    team_name,
    conference,
    division
from {{ ref('intr_player_game_stats') }}