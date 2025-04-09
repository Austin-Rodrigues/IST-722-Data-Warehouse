{{ config(materialized='table') }}

WITH stg_authors AS (
    SELECT * FROM {{ source("pubs", "authors") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["a.au_id"]) }} as authorskey,
    a.au_id,
    a.au_lname,
    a.au_fname,
    a.phone,
    a.address,
    a.city,
    a.state,
    a.zip,
    a.contract
FROM stg_authors a
