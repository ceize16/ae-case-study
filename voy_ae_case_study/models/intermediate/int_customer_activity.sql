WITH activity AS (
    SELECT DISTINCT 
        customer_id,
        from_date, 
        to_date
    FROM {{ref('stg_activity')}}
), 

activity_ordered AS (
    SELECT 
        customer_id,
        from_date, 
        to_date, 
        MAX(to_date) OVER (
            PARTITION BY  customer_id
            ORDER BY from_date, to_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_max_to_date
    FROM activity
),

activity_flagged AS (
    SELECT 
        customer_id,
        from_date, 
        to_date, 
        previous_max_to_date, 
        CASE
            WHEN previous_max_to_date IS NULL THEN 1
            WHEN from_date > previous_max_to_date + INTERVAL 1 DAY THEN 1
            ELSE 0 
        END AS is_new_activity_period
    FROM activity_ordered
), 

activity_periods AS (
    SELECT 
        customer_id, 
        from_date, 
        to_date, 
        previous_max_to_date, 
        is_new_activity_period,
        SUM(is_new_activity_period) OVER (
            PARTITION BY customer_id
            ORDER BY from_date, to_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS activity_period_id
    FROM activity_flagged
)

SELECT 
    customer_id,
    activity_period_id, 
    MIN(from_date) AS activity_start_date, 
    MAX(to_date) AS activity_end_date
FROM 
    activity_periods
GROUP BY 
    customer_id, activity_period_id