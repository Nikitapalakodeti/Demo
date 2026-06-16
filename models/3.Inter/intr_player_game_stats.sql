select
    gs.game_id,
    gs.game_date,

    p.player_id,
    p.player_name,
    p.position,

    t.team_id,
    t.team_name,
    t.conference,
    t.division,

    gs.points,
    gs.rebounds,
    gs.assists,
    gs.steals,
    gs.blocks,
    gs.turnovers,
    gs.minutes_played,
    gs.pra,
    gs.fantasy_score

from {{ ref('stg_game_stats') }} gs
left join {{ ref('stg_players') }} p
    on gs.player_id = p.player_id
left join {{ ref('stg_teams') }} t
    on gs.team_id = t.team_id