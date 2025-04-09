{{ config(materialized='table') }}

WITH stg_sales AS (
    SELECT * FROM {{ source("pubs", "sales") }}
),
stg_titles AS (
    SELECT *, {{ dbt_utils.generate_surrogate_key(["title_id"]) }} AS titlekey
    FROM {{ source("pubs", "titles") }}
),
stg_stores AS (
    SELECT *, {{ dbt_utils.generate_surrogate_key(["stor_id"]) }} AS storekey
    FROM {{ source("pubs", "stores") }}
),
sales_enriched AS (
    SELECT
        s.stor_id,
        s.title_id,
        t.titlekey,
        s.ord_date,
        s.qty,
        t.price,
        s.qty * t.price AS revenue,
        st.storekey
    FROM stg_sales s
    JOIN stg_titles t ON s.title_id = t.title_id
    JOIN stg_stores st ON s.stor_id = st.stor_id
)

SELECT
    storekey,
    titlekey,
    ord_date,
    SUM(qty) AS total_units_sold,
    SUM(revenue) AS total_revenue
FROM sales_enriched
GROUP BY storekey, titlekey, ord_date
