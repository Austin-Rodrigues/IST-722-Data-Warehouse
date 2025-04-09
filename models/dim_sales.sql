{{ config(materialized='table') }}

WITH stg_sales AS (
    SELECT * FROM {{ source("pubs", "sales") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["s.stor_id", "s.ord_num", "s.title_id"]) }} as saleskey,
    s.stor_id,
    s.ord_num,
    s.ord_date,
    s.qty,
    s.payterms,
    s.title_id
FROM stg_sales s
