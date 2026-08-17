WITH monthly_activity AS (
    SELECT * FROM {{ref('int_customer_monthly_activity')}}
), 

customers AS (
    SELECT 
        customer_id, 
        cohort_month
    FROM 
        {{ref('dim_customers')}}
),

final AS (
    SELECT 
        monthly_activity.customer_id, 
        monthly_activity.activity_month, 
        TRUE AS is_active,
        DATE_DIFF('month', customers.cohort_month, monthly_activity.activity_month) AS months_since_acquisition
    FROM 
        monthly_activity
    LEFT JOIN 
        customers
        ON monthly_activity.customer_id = customers.customer_id
)

SELECT * FROM final