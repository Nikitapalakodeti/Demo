select
    game_id,
    player_id,
    cast(game_date as date) as game_date,

    coalesce(points, 0) as points,
    coalesce(rebounds, 0) as rebounds,
    coalesce(assists, 0) as assists,
    coalesce(steals, 0) as steals,
    coalesce(blocks, 0) as blocks,
    coalesce(minutes_played, 0) as minutes_played,

    coalesce(points, 0)
    + coalesce(rebounds, 0)
    + coalesce(assists, 0) as pra,

    {{ fantasy_score() }} as fantasy_score

from {{ source('sports', 'game_stats') }}