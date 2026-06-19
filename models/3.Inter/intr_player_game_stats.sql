select
    gs.game_id,
    gs.game_date,

    p.player_id,
    p.player_name,
    p.position,
    p.age,
    p.salary,

    t.team_id,
    t.team_name,
    t.city,
    t.conference,

    gs.points,
    gs.rebounds,
    gs.assists,
    gs.steals,
    gs.blocks,
    gs.minutes_played,
    gs.pra,
    gs.fantasy_score

from {{ ref('stg_game_stats') }} as gs
left join {{ ref('stg_players') }} as p
    on gs.player_id = p.player_id
left join {{ ref('stg_teams') }} as t
    on p.team_id = t.team_id