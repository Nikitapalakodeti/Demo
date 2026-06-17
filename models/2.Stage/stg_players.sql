select
    player_id,
    trim(player_name) as player_name,
    team_id,
    trim(position) as position,
    age,
    salary
from {{ source('sports', 'players') }}