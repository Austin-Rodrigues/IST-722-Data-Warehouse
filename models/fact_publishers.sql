WITH stg_titles AS (
    SELECT 
        *, 
        {{ dbt_utils.generate_surrogate_key(["title_id"]) }} as titlekey
    FROM {{ source("pubs", 'titles') }}
),

stg_publishers AS (
    SELECT 
        *, 
        {{ dbt_utils.generate_surrogate_key(["pub_id"]) }} as publisherkey
    FROM {{ source("pubs", 'publishers')}}
),



title_count_per_publisher AS (
    SELECT 
        t.pub_id,
        p.publisherkey,
        t.titlekey,
        t.pubdate,
        COUNT(t.title_id) AS number_of_titles
    FROM stg_titles t
    JOIN stg_publishers p ON t.pub_id = p.pub_id
    GROUP BY t.pub_id, p.publisherkey, t.titlekey, t.pubdate
)

SELECT 
    tcp.pub_id,
    tcp.publisherkey,
    tcp.titlekey,
    tcp.pubdate,
    tcp.number_of_titles
FROM title_count_per_publisher tcp
ORDER BY tcp.pub_id, tcp.number_of_titles DESC