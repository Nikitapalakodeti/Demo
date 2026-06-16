select
    player_id,
    player_name,
    team_id,
    team_name,

    count(distinct game_id) as games_played,

    sum(points) as total_points,
    sum(rebounds) as total_rebounds,
    sum(assists) as total_assists,

    avg(points) as avg_points,
    avg(rebounds) as avg_rebounds,
    avg(assists) as avg_assists,

    sum(pra) as total_pra,
    avg(pra) as avg_pra,
    sum(fantasy_score) as total_fantasy_score,
    avg(fantasy_score) as avg_fantasy_score

from {{ ref('intr_player_game_stats') }}

group by
    player_id,
    player_name,
    team_id,
    team_name