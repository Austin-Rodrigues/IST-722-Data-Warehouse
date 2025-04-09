with stg_publishers as (select * from {{ source("pubs", "publishers") }})
select
    {{ dbt_utils.generate_surrogate_key(["p.pub_id"]) }} as publisherkey,
    p.pub_id,
    p.pub_name,
    p.city,
    p.state,
    p.country
from stg_publishers p