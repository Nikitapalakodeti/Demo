{% snapshot player_timestamp_snapshot %}

{{
    config(
        target_database='SQL_PRACTICE',
        target_schema='SPORTS',
        unique_key='player_id',
        strategy='timestamp',
        updated_at='last_updated'
    )
}}

select
    player_id,
    player_name,
    team_id,
    position,
    age,
    salary,
    last_updated
from {{ ref('stg_players') }}

{% endsnapshot %}