{{ config(
    materialized = 'incremental',
    unique_key = 'unique_id',
    incremental_strategy = 'merge',
    pre_hook = "
        {% if is_incremental() %}
        update {{ this }} tgt
        set
            active_status_flag = 0,
            date_inactive = current_date(),
            row_modified_date = current_timestamp()
        from {{ ref('stg_person') }} src
        where tgt.source_person_key = src.source_person_key
          and tgt.active_status_flag = 1
          and (
                coalesce(tgt.memberid, '') <> coalesce(src.memberid, '')
             or coalesce(tgt.memberidshort, '') <> coalesce(src.memberidshort, '')
             or coalesce(tgt.employer_id, '') <> coalesce(src.employer_id, '')
             or coalesce(tgt.clientid, '') <> coalesce(src.clientid, '')
             or coalesce(tgt.family_id, '') <> coalesce(src.family_id, '')
             or coalesce(tgt.plan_id, '') <> coalesce(src.plan_id, '')
             or coalesce(tgt.memberrelationshipcode_id, '') <> coalesce(src.memberrelationshipcode_id, '')
             or coalesce(tgt.cardId, '') <> coalesce(src.cardId, '')
             or coalesce(tgt.altmemberid, '') <> coalesce(src.altmemberid, '')
             or coalesce(tgt.altgroupid, '') <> coalesce(src.altgroupid, '')
             or coalesce(tgt.networkprefix, '') <> coalesce(src.networkprefix, '')
          );
        {% endif %}
    "
) }}

---1. pre_hook runs first- makes inactive, sets inactive_date as curr date
--2. src prepares latest source data
--3. active_tgt prepares current active target data
--4. classified compares source vs target
--5. final select sends rows to merge
with src as (

    select *
    from {{ ref('stg_person') }}

),

active_tgt as (

    {% if is_incremental() %}
        select *
        from {{ this }}
        where active_status_flag = 1
    {% else %}
        select
            cast(null as number) as unique_id,
            cast(null as varchar) as source_person_key,
            cast(null as varchar) as memberid,
            cast(null as varchar) as memberidshort,
            cast(null as varchar) as employer_id,
            cast(null as varchar) as clientid,
            cast(null as varchar) as family_id,
            cast(null as varchar) as plan_id,
            cast(null as varchar) as memberrelationshipcode_id,
            cast(null as varchar) as cardId,
            cast(null as varchar) as altmemberid,
            cast(null as varchar) as altgroupid,
            cast(null as varchar) as networkprefix,
            cast(null as varchar) as first_name,
            cast(null as varchar) as last_name,
            cast(null as varchar) as email_address,
            cast(null as varchar) as phone_number,
            cast(null as number) as active_status_flag,
            cast(null as date) as date_inactive,
            cast(null as timestamp) as row_created_date,
            cast(null as timestamp) as row_modified_date
        where 1 = 0
    {% endif %}

),

classified as (

    select
        src.*,
        tgt.unique_id as existing_unique_id,
        tgt.row_created_date as existing_row_created_date,

        case
            when tgt.source_person_key is null then 'NEW'

            when
                   coalesce(tgt.memberid, '') <> coalesce(src.memberid, '')
                or coalesce(tgt.memberidshort, '') <> coalesce(src.memberidshort, '')
                or coalesce(tgt.employer_id, '') <> coalesce(src.employer_id, '')
                or coalesce(tgt.clientid, '') <> coalesce(src.clientid, '')
                or coalesce(tgt.family_id, '') <> coalesce(src.family_id, '')
                or coalesce(tgt.plan_id, '') <> coalesce(src.plan_id, '')
                or coalesce(tgt.memberrelationshipcode_id, '') <> coalesce(src.memberrelationshipcode_id, '')
                or coalesce(tgt.cardId, '') <> coalesce(src.cardId, '')
                or coalesce(tgt.altmemberid, '') <> coalesce(src.altmemberid, '')
                or coalesce(tgt.altgroupid, '') <> coalesce(src.altgroupid, '')
                or coalesce(tgt.networkprefix, '') <> coalesce(src.networkprefix, '')
                then 'SCD2'

            when
                   coalesce(tgt.first_name, '') <> coalesce(src.first_name, '')
                or coalesce(tgt.last_name, '') <> coalesce(src.last_name, '')
                or coalesce(tgt.email_address, '') <> coalesce(src.email_address, '')
                or coalesce(tgt.phone_number, '') <> coalesce(src.phone_number, '')
                then 'SCD1'

            else 'NO_CHANGE'
        end as change_type

    from src
    left join active_tgt tgt
        on src.source_person_key = tgt.source_person_key

)

select
    case
        when change_type = 'SCD1'
            then existing_unique_id
        else SQL_PRACTICE.SPORTS.PERSON_SEQ.nextval
    end as unique_id,

    source_person_key,

    memberid,
    memberidshort,
    employer_id,
    clientid,
    family_id,
    plan_id,
    memberrelationshipcode_id,
    cardId,
    altmemberid,
    altgroupid,
    networkprefix,

    first_name,
    last_name,
    email_address,
    phone_number,

    1 as active_status_flag,
    cast(null as date) as date_inactive,

    case
        when change_type = 'SCD1'
            then existing_row_created_date
        else current_timestamp()
    end as row_created_date,

    current_timestamp() as row_modified_date

from classified
where change_type in ('NEW', 'SCD1', 'SCD2')