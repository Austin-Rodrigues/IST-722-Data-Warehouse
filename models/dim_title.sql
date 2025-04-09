with stg_titles as (select * from {{ source("pubs", "titles") }})
select
    {{ dbt_utils.generate_surrogate_key(["t.title_id"]) }} as titlekey,
    t.title_id,
    t.title,
    t.type,
    t.pub_id,
    t.price,
    t.advance,
    t.royalty,
    t.ytd_sales,
    t.notes,
    t.pubdate
from stg_titles t