{{ config(materialized='table') }}

WITH stg_jobs AS (
    SELECT * FROM {{ source("pubs", "jobs") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["j.job_id"]) }} as jobskey,
    j.job_id,
    j.job_desc,
    j.min_lvl,
    j.max_lvl
FROM stg_jobs j
