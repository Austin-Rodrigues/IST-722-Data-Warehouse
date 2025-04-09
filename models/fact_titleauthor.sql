{{ config(materialized='table') }}

WITH stg_titleauthor AS (
    SELECT * FROM {{ source("pubs", "titleauthor") }}
),
stg_titles AS (
    SELECT *, {{ dbt_utils.generate_surrogate_key(["title_id"]) }} AS titlekey
    FROM {{ source("pubs", "titles") }}
),
stg_authors AS (
    SELECT *, {{ dbt_utils.generate_surrogate_key(["au_id"]) }} AS authorkey
    FROM {{ source("pubs", "authors") }}
),
author_contributions AS (
    SELECT
        t.au_id,
        t.title_id,
        t.au_ord,
        t.royaltyper,
        a.authorkey,
        ti.titlekey
    FROM stg_titleauthor t
    JOIN stg_authors a ON t.au_id = a.au_id
    JOIN stg_titles ti ON t.title_id = ti.title_id
)

SELECT * FROM author_contributions
