{{ config(materialized='table') }}

WITH stg_pub_info AS (
    SELECT * FROM {{ source("pubs", "pub_info") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["p.pub_id"]) }} as pub_infokey,
    p.pub_id,
    p.pr_info
FROM stg_pub_info p
