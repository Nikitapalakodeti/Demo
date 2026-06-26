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
from {{ ref('stg_person') }}