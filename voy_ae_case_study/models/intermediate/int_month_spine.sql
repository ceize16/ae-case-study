{{
    dbt_utils.date_spine(
        datepart= 'month', 
        start_date="(SELECT DATE_TRUNC('month', MIN(from_date)) FROM " ~ ref('stg_activity') ~ ")",
        end_date = "(SELECT DATE_TRUNC('month', MAX(to_date)) + INTERVAL 1 MONTH FROM " ~ ref('stg_activity') ~ ")"
    )
}}