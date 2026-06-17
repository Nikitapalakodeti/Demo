select
    player_id,
    player_name,
    position,
    team_id,
    team_name,

    count(distinct game_id) as games_played,

    sum(points) as total_points,
    sum(rebounds) as total_rebounds,
    sum(assists) as total_assists,
    sum(steals) as total_steals,
    sum(blocks) as total_blocks,

    avg(points) as avg_points,
    avg(rebounds) as avg_rebounds,
    avg(assists) as avg_assists,
    avg(fantasy_score) as avg_fantasy_score

from {{ ref('intr_player_game_stats') }}

group by
    player_id,
    player_name,
    position,
    team_id,
    team_name