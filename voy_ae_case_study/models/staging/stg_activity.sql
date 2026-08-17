WITH activity AS (
    SELECT * FROM {{ref('activity')}}
), 

activity_typed AS (
    SELECT 
        CAST(customer_id AS bigint) AS customer_id, 
        CAST(subscription_id AS bigint) AS subscription_id, 
        CAST(from_date AS date) AS from_date, 
        CAST(to_date AS date) AS to_date
    FROM 
        activity
),

final AS (
    SELECT 
        DISTINCT * 
    FROM 
        activity_typed
)

SELECT * FROM final

