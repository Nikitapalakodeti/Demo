{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

select
    game_id,
    player_id,
    game_date,
    points,
    rebounds,
    assists
from {{ ref('stg_game_stats') }}

{% if is_incremental() %}
where game_date > (
    select max(game_date)
    from {{ this }}
)
{% endif %}