select
    game_id,
    game_date,
    team_id,
    team_name,
    city,
    conference,

    sum(points) as team_points,
    sum(rebounds) as team_rebounds,
    sum(assists) as team_assists,
    sum(steals) as team_steals,
    sum(blocks) as team_blocks,
    sum(minutes_played) as team_minutes_played,
    sum(fantasy_score) as team_fantasy_score

from {{ ref('intr_player_game_stats') }}

group by
    game_id,
    game_date,
    team_id,
    team_name,
    city,
    conference