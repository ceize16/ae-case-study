WITH acq_orders AS (
    SELECT * FROM {{ref('acq_orders')}}
), 

final AS (
    SELECT 
        CAST(customer_id AS  bigint)  AS customer_id, 
        NULLIF(TRIM(taxonomy_business_category_group), '') AS acquisition_taxonomy
    FROM 
        acq_orders
)

SELECT * FROM final