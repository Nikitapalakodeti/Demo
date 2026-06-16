select
    team_id,
    upper(trim(team_name)) as team_name,
    upper(trim(city)) as city,
    upper(trim(conference)) as conference,
    upper(trim(division)) as division
from {{ source('sports', 'teams') }}