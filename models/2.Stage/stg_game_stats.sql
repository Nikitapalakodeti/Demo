select
    game_id,
    player_id,
    team_id,
    cast(game_date as date) as game_date,

    coalesce(points, 0) as points,
    coalesce(rebounds, 0) as rebounds,
    coalesce(assists, 0) as assists,
    coalesce(steals, 0) as steals,
    coalesce(blocks, 0) as blocks,
    coalesce(turnovers, 0) as turnovers,
    coalesce(minutes_played, 0) as minutes_played,

    points + rebounds + assists as pra,
    points + rebounds + assists + steals + blocks as fantasy_score

from {{ source('sports', 'game_stats') }}