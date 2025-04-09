with stg_stores as (select * from {{ source("pubs", "stores") }})
select
    {{ dbt_utils.generate_surrogate_key(["s.stor_id"]) }} as storekey,
    s.stor_id,
    s.stor_name,
    s.stor_address,
    s.city,
    s.state,
    s.zip
from stg_stores s