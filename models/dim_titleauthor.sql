{{ config(materialized='table') }}

WITH stg_titleauthor AS (
    SELECT * FROM {{ source("pubs", "titleauthor") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["t.au_id", "t.title_id"]) }} as titleauthorkey,
    t.au_id,
    t.title_id,
    t.au_ord,
    t.royaltyper
FROM stg_titleauthor t
