WITH all_customers_ids AS (
    SELECT customer_id FROM {{ref('stg_customers')}}
    UNION 
    SELECT customer_id FROM {{ref('stg_acq_orders')}}
    UNION 
    SELECT customer_id FROM {{ref('stg_activity')}}
), 


customers AS (
    SELECT * FROM {{ref('stg_customers')}}
), 

acquisition AS (
    SELECT * FROM {{ref('stg_acq_orders')}}
),

first_activity AS (
    SELECT 
        customer_id, 
        MIN(activity_month) AS cohort_month
    FROM
        {{ref('int_customer_monthly_activity')}}
    GROUP BY 
        customer_id
),

final AS (
    SELECT 
        all_customers_ids.customer_id, 
        COALESCE(customers.customer_country, 'Unknown') AS customer_country,
        COALESCE(acquisition.acquisition_taxonomy, 'Unknown') AS acquisition_taxonomy, 
        activity.cohort_month, 
        (activity.cohort_month IS NOT NULL) AS is_ever_active
    FROM 
        all_customers_ids
    LEFT JOIN 
        customers
        ON all_customers_ids.customer_id = customers.customer_id
    LEFT JOIN 
        acquisition
        ON customers.customer_id = acquisition.customer_id
    LEFT JOIN 
        first_activity AS activity
        ON customers.customer_id = activity.customer_id
)

SELECT * FROM final