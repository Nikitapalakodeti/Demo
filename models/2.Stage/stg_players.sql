select
    player_id,
    team_id,
    age,
    salary,
    last_updated,
    trim(player_name) as player_name,
    trim(position) as position
from {{ source('sports', 'players') }}