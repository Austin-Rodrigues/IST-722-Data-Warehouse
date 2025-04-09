with stg_discounts as (select * from {{ source("pubs", "discounts") }})
select
    {{ dbt_utils.generate_surrogate_key(["d.discounttype"]) }} as discountkey,
    d.discounttype,
    d.stor_id,
    d.lowqty,
    d.highqty,
    d.discount
from stg_discounts d