WITH customers AS (
    SELECT 
        customer_id,
        cohort_month
    FROM
        {{ref('dim_customers')}}
    WHERE
        is_ever_active
),

spine AS (
    SELECT date_month FROM {{ref('int_month_spine')}}
),

customer_months AS (
    SELECT 
        customers.customer_id, 
        customers.cohort_month,
        spine.date_month AS calendar_month
    FROM 
        customers
    INNER JOIN 
        spine
        ON spine.date_month >= customers.cohort_month
),

activity AS (
    SELECT 
        customer_id, 
        activity_month
    FROM 
        {{ref('int_customer_monthly_activity')}}
),

monthly_activity_flag AS (
    SELECT 
        customer_months.customer_id, 
        customer_months.cohort_month, 
        customer_months.calendar_month, 
        (activity.customer_id IS NOT NULL) AS is_active_this_month
    FROM 
        customer_months
    LEFT JOIN 
        activity
        ON customer_months.customer_id = activity.customer_id
        AND customer_months.calendar_month = activity.activity_month
),

prior_monthly_activity AS (
    SELECT 
        customer_id, 
        cohort_month, 
        calendar_month, 
        is_active_this_month, 
        LAG(is_active_this_month) OVER (
            PARTITION BY customer_id
            ORDER BY calendar_month
        ) AS was_active_last_month, 
        MAX(CASE 
                WHEN is_active_this_month THEN 1 
                ELSE 0 
                END
            ) OVER (
                PARTITION BY customer_id
                ORDER BY calendar_month
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ) AS was_ever_active_before
    FROM 
        monthly_activity_flag
),

final AS (
    SELECT 
        customer_id, 
        calendar_month, 
        is_active_this_month,
        CASE 
            WHEN calendar_month = cohort_month THEN 'New'
            WHEN is_active_this_month AND was_active_last_month THEN 'Retained'
            WHEN is_active_this_month AND NOT was_active_last_month
                AND COALESCE(was_ever_active_before, 0) = 1 THEN 'Reactivated'
            WHEN NOT is_active_this_month AND was_active_last_month THEN 'churned'
            ELSE 'inactive'
        END AS customer_status
    FROM 
        prior_monthly_activity
)

SELECT * FROM final