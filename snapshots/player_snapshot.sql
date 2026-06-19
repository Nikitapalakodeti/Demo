{% snapshot player_snapshot %}

{{
    config(
        target_database='SQL_PRACTICE',
        target_schema='SPORTS',
        unique_key='player_id',
        strategy='check',
        check_cols=['team_id', 'salary']
    )
}}

select
    player_id,
    player_name,
    team_id,
    position,
    age,
    salary
from {{ ref('stg_players') }}

{% endsnapshot %}