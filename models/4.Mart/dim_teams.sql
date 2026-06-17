select distinct
    team_id,
    team_name,
    city,
    conference
from {{ ref('stg_teams') }}