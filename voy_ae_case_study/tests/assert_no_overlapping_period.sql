WITH activity_periods AS  (
    SELECT * FROM {{ref('int_customer_activity')}}
),

with_next_period AS (
    SELECT 
        customer_id, 
        activity_period_id, 
        activity_start_date, 
        activity_end_date, 
        LEAD(activity_start_date) OVER (
            PARTITION BY customer_id
            ORDER BY activity_start_date
        ) AS next_start_date
    FROM activity_periods
)

SELECT * FROM with_next_period
WHERE next_start_date IS NOT NULL 
    AND next_start_date <= activity_end_date