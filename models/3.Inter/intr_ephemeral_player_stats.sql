{{ config(materialized='ephemeral') }}

select
    player_id,
    avg(points) as avg_points,
    sum(points) as total_points
from {{ ref('stg_game_stats') }}
group by player_id