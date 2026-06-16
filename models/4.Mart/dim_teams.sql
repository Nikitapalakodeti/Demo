select distinct
    team_id,
    team_name,
    conference,
    division
from {{ ref('intr_player_game_stats') }}