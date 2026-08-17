WITH customer_activity AS (
    SELECT * FROM {{ref('int_customer_activity')}}
), 
month_spine AS (
    SELECT date_month FROM {{ref('int_month_spine')}}
),

activity_periods_monthly AS (
    SELECT 
        customer_id, 
        DATE_TRUNC('month', activity_start_date) AS start_month, 
        DATE_TRUNC('month', activity_end_date) AS end_month
    FROM 
        customer_activity
),


activity_monnthly_exploded AS (
    SELECT 
        apm.customer_id, 
        spine.date_month AS activity_month
    FROM 
        activity_periods_monthly AS apm
    INNER JOIN 
        month_spine AS spine
        ON spine.date_month BETWEEN apm.start_month AND apm.end_month
)

SELECT DISTINCT 
    customer_id, 
    activity_month
FROM 
    activity_monnthly_exploded

