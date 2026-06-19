select *
from {{ ref('stg_game_stats') }}
where points < 0