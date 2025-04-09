{{ config(materialized='table') }}

WITH stg_roysched AS (
    SELECT * FROM {{ source("pubs", "roysched") }}
),
stg_titles AS (
    SELECT *, {{ dbt_utils.generate_surrogate_key(["title_id"]) }} AS titlekey
    FROM {{ source("pubs", "titles") }}
),
royalty_summary AS (
    SELECT
        r.title_id,
        t.titlekey,
        MIN(r.lorange) AS min_range,
        MAX(r.hirange) AS max_range,
        AVG(r.royalty) AS avg_royalty
    FROM stg_roysched r
    JOIN stg_titles t ON r.title_id = t.title_id
    GROUP BY r.title_id, t.titlekey
)

SELECT * FROM royalty_summary
