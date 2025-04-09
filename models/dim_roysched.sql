{{ config(materialized='table') }}

WITH stg_roysched AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(["r.title_id", "r.lorange", "r.hirange", "r.royalty"]) }} as royschedkey,  -- Surrogate key based on title_id, lorange, hirange, and royalty
        r.title_id,
        r.lorange,
        r.hirange,
        r.royalty
    FROM {{ source("pubs", "roysched") }} r
)

SELECT
    royschedkey,
    title_id,
    lorange,
    hirange,
    royalty
FROM stg_roysched