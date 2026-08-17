WITH customers AS (
    SELECT * FROM {{ref('dim_customers')}}
    WHERE is_ever_active
),

cohort_sizes AS (
    SELECT 
        cohort_month, 
        customer_country, 
        acquisition_taxonomy, 
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM 
        customers
    GROUP BY 
        cohort_month, 
        customer_country, 
        acquisition_taxonomy
),

activity AS (
    SELECT 
        customers.cohort_month, 
        customers.customer_country, 
        customers.acquisition_taxonomy,
        fct.months_since_acquisition,
        COUNT(DISTINCT fct.customer_id) AS active_customers
    FROM 
        {{ref('fct_customer_monthly_activity')}} as fct
    INNER JOIN 
        customers
        ON fct.customer_id = customers.customer_id
    WHERE fct.months_since_acquisition >= 0
    GROUP BY 
        customers.cohort_month, 
        customers.customer_country, 
        customers.acquisition_taxonomy,
        fct.months_since_acquisition
)

SELECT 
    activity.cohort_month, 
    activity.customer_country, 
    activity.acquisition_taxonomy, 
    activity.months_since_acquisition, 
    activity.active_customers, 
    cohort_sizes.cohort_size,
    activity.active_customers / cohort_sizes.cohort_size AS retention_rate
FROM 
    activity
INNER JOIN 
    cohort_sizes
    ON activity.cohort_month = cohort_sizes.cohort_month
    AND activity.customer_country = cohort_sizes.customer_country
    AND activity.acquisition_taxonomy = cohort_sizes.acquisition_taxonomy