{{ config(materialized='table') }}

WITH stg_employee AS (
    SELECT * FROM {{ source("pubs", "employee") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["e.emp_id"]) }} as employeekey,
    e.emp_id,
    e.fname,
    e.minit,
    e.lname,
    e.job_id,
    e.job_lvl,
    e.pub_id,
    e.hire_date
FROM stg_employee e
