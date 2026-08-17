WITH customers AS (
    SELECT * FROM {{ref('customers')}}
), 

final AS (
    SELECT 
        CAST(customer_id AS bigint) AS customer_id, 
        NULLIF(TRIM(customer_country), '') AS customer_country
    FROM 
        customers
)

SELECT * FROM final