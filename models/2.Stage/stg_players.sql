select
    player_id,
    team_id,
    initcap(trim(player_name)) as player_name,
    upper(trim(position)) as position,
    jersey_number,
    coalesce(height, 0) as height,
    coalesce(weight, 0) as weight
from {{ source('sports', 'players') }}