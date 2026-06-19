select
    player_id,
    team_id,
    age,
    salary,
    trim(player_name) as player_name,
    trim(position) as position
from {{ source('sports', 'players') }}