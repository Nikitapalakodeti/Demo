{{ config(
    materialized = 'incremental',
    unique_key = 'unique_id',
    incremental_strategy = 'merge'
) }}

with src as (

    select
        source_person_key,
        memberid,
        memberidshort,
        employer_id,
        clientid,
        family_id,
        plan_id,
        memberrelationshipcode_id,
        cardid,
        altmemberid,
        altgroupid,
        networkprefix,
        first_name,
        last_name,
        email_address,
        phone_number
    from {{ ref('intr_person_scd') }}

),

active_tgt as (

    {% if is_incremental() %}

        select
            unique_id,
            source_person_key,
            memberid,
            memberidshort,
            employer_id,
            clientid,
            family_id,
            plan_id,
            memberrelationshipcode_id,
            cardid,
            altmemberid,
            altgroupid,
            networkprefix,
            first_name,
            last_name,
            email_address,
            phone_number,
            active_status_flag,
            date_inactive,
            row_created_date,
            row_modified_date
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
            cast(null as varchar) as cardid,
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
        src.source_person_key,
        src.memberid,
        src.memberidshort,
        src.employer_id,
        src.clientid,
        src.family_id,
        src.plan_id,
        src.memberrelationshipcode_id,
        src.cardid,
        src.altmemberid,
        src.altgroupid,
        src.networkprefix,
        src.first_name,
        src.last_name,
        src.email_address,
        src.phone_number,

        tgt.unique_id as existing_unique_id,
        tgt.row_created_date as existing_row_created_date,

        tgt.memberid as tgt_memberid,
        tgt.memberidshort as tgt_memberidshort,
        tgt.employer_id as tgt_employer_id,
        tgt.clientid as tgt_clientid,
        tgt.family_id as tgt_family_id,
        tgt.plan_id as tgt_plan_id,
        tgt.memberrelationshipcode_id as tgt_memberrelationshipcode_id,
        tgt.cardid as tgt_cardid,
        tgt.altmemberid as tgt_altmemberid,
        tgt.altgroupid as tgt_altgroupid,
        tgt.networkprefix as tgt_networkprefix,
        tgt.first_name as tgt_first_name,
        tgt.last_name as tgt_last_name,
        tgt.email_address as tgt_email_address,
        tgt.phone_number as tgt_phone_number,

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
                or coalesce(tgt.cardid, '') <> coalesce(src.cardid, '')
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
    left join active_tgt as tgt
        on src.source_person_key = tgt.source_person_key

),

new_records as (

    select
        {{ source('sports', 'PERSON_SEQ') }}.nextval as unique_id,
        c.source_person_key,
        c.memberid,
        c.memberidshort,
        c.employer_id,
        c.clientid,
        c.family_id,
        c.plan_id,
        c.memberrelationshipcode_id,
        c.cardid,
        c.altmemberid,
        c.altgroupid,
        c.networkprefix,
        c.first_name,
        c.last_name,
        c.email_address,
        c.phone_number,
        1 as active_status_flag,
        cast(null as date) as date_inactive,
        current_timestamp() as row_created_date,
        current_timestamp() as row_modified_date
    from classified as c
    where c.change_type in ('NEW', 'SCD2')

),

scd1_updates as (

    select
        c.existing_unique_id as unique_id,
        c.source_person_key,
        c.memberid,
        c.memberidshort,
        c.employer_id,
        c.clientid,
        c.family_id,
        c.plan_id,
        c.memberrelationshipcode_id,
        c.cardid,
        c.altmemberid,
        c.altgroupid,
        c.networkprefix,
        c.first_name,
        c.last_name,
        c.email_address,
        c.phone_number,
        1 as active_status_flag,
        cast(null as date) as date_inactive,
        c.existing_row_created_date as row_created_date,
        current_timestamp() as row_modified_date
    from classified as c
    where c.change_type = 'SCD1'

),

scd2_expired_records as (

    select 
        c.existing_unique_id as unique_id,
        c.source_person_key,
        c.tgt_memberid as memberid,
        c.tgt_memberidshort as memberidshort,
        c.tgt_employer_id as employer_id,
        c.tgt_clientid as clientid,
        c.tgt_family_id as family_id,
        c.tgt_plan_id as plan_id,
        c.tgt_memberrelationshipcode_id as memberrelationshipcode_id,
        c.tgt_cardid as cardid,
        c.tgt_altmemberid as altmemberid,
        c.tgt_altgroupid as altgroupid,
        c.tgt_networkprefix as networkprefix,
        c.tgt_first_name as first_name,
        c.tgt_last_name as last_name,
        c.tgt_email_address as email_address,
        c.tgt_phone_number as phone_number,
        0 as active_status_flag,
        current_date() as date_inactive,
        c.existing_row_created_date as row_created_date,
        current_timestamp() as row_modified_date
    from classified as c
    where c.change_type = 'SCD2'

)

select * from new_records

union all

select * from scd1_updates

union all

select * from scd2_expired_records