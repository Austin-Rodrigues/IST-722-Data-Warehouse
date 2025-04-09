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
    SELECT *,
    {{ dbt_utils.generate_surrogate_key(["discounttype"]) }} as discountkey
    FROM {{ source("pubs", 'discounts') }}
),

revenue_calc AS (
    SELECT 
        s.title_id,
        s.titlekey,
        d.discountkey, 
        s.qty,
        COALESCE(d.discount, 0) as discount_percentage,
        (t.price - (t.price * (COALESCE(d.discount, 0))/100)) * s.qty AS revenue_per_title,
        (t.price * (COALESCE(d.discount, 0)/100)) * s.qty AS total_discount_per_sale 
    FROM stg_sales s 
    LEFT JOIN stg_titles t ON s.title_id = t.title_id
    LEFT JOIN stg_discounts d ON s.stor_id = d.stor_id 
),
total_revenue AS (
    SELECT 
        rc.title_id,
        rc.titlekey,
        rc.discountkey,
        SUM(rc.qty) AS total_qty,
        ROUND(SUM(rc.total_discount_per_sale),2) AS total_discount,
        ROUND(SUM(rc.revenue_per_title),2) AS total_revenue_per_title
    FROM 
       revenue_calc rc
    GROUP BY rc.title_id,rc.titlekey,rc.discountkey
)
SELECT 
    tr.titlekey,
    tr.discountkey,
    tr.title_id,
    tr.total_qty,
    tr.total_discount,
    tr.total_revenue_per_title
FROM total_revenue tr
JOIN stg_titles t ON tr.title_id = t.title_id
     