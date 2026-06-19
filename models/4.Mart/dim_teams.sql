select
    t.team_id,
    t.team_name,
    t.city,
    t.conference,
    c.region

from {{ ref('stg_teams') }} as t

left join {{ ref('conference_lookup') }} as c
    on t.conference = c.conference