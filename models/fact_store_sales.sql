WITH stg_sales AS (
    SELECT
        title_id,
        {{ dbt_utils.generate_surrogate_key(["title_id"]) }} as titlekey,
        stor_id,
        {{ dbt_utils.generate_surrogate_key(["stor_id"]) }} as storekey,
        qty,
        ord_num,
        ord_date,
        payterms
    FROM {{ source("pubs", 'sales') }}
),

stg_titles AS (
    SELECT * FROM {{ source("pubs", 'titles') }}
),
stg_discounts AS (
    SELECT * FROM {{ source("pubs", 'discounts') }}
),



revenue_stor AS (
    SELECT 
        s.stor_id,
        s.storekey,
        s.titlekey, 
        s.ord_date,
        s.qty, 
        COALESCE(d.discount, 0) as discount_percentage,
        (t.price - (t.price * (COALESCE(d.discount, 0))/100)) * s.qty AS revenue_per_store,
        (t.price * (COALESCE(d.discount, 0)/100)) * s.qty AS total_discount_per_sale
    FROM stg_sales s 
    LEFT JOIN stg_titles t ON s.title_id = t.title_id
    LEFT JOIN stg_discounts d ON s.stor_id = d.stor_id 
),

daily_store_revenue AS (
    SELECT 
        rs.stor_id,
        rs.storekey,
        rs.titlekey,
        DATE(rs.ord_date) AS revenue_date,
        SUM(rs.qty) AS total_qty_per_store,
        ROUND(SUM(rs.total_discount_per_sale),2) AS total_discount_per_store,
        ROUND(SUM(rs.revenue_per_store),2) AS total_revenue_per_store
    FROM 
       revenue_stor rs
    GROUP BY rs.stor_id, rs.storekey, rs.titlekey, DATE(rs.ord_date)
)

SELECT 
    dsr.stor_id,
    dsr.storekey,
    dsr.titlekey,
    dsr.revenue_date,
    dsr.total_qty_per_store,
    dsr.total_discount_per_store,
    dsr.total_revenue_per_store
FROM daily_store_revenue dsr
ORDER BY dsr.revenue_date, dsr.stor_id