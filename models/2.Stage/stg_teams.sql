select
    team_id,
    trim(team_name) as team_name,
    trim(city) as city,
    trim(conference) as conference
from {{ source('sports', 'teams') }}