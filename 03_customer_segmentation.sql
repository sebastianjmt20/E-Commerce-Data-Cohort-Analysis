WITH EXTRA AS (
    SELECT
        -- customerkey, 
        PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY total_revenue) as Low,
        PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY total_revenue) as High
    FROM dayly_revenue
    -- GROUP BY customerkey
    -- WHERE orderdate BETWEEN '2022-01-01' AND '2023-12-31'
), RAW_VALUES as (
SELECT d.customerkey, sum(total_revenue) as revenue,
    CASE 
        WHEN (total_revenue) <= e.Low THEN 'Low Value'
        WHEN (total_revenue) > e.Low
            AND (total_revenue) <= e.High
        THEN 'Mid Value'
        WHEN (total_revenue) > e.High THEN 'High Value'
    END as value_group
FROM dayly_revenue d, EXTRA e
GROUP BY d.customerkey, value_group)
-- cume_dist (gives the running percentage)
SELECT value_group,count(*) as num_customers, --(count(*)/(SELECT count(*) from RAW_VALUES)*100) AS percent_of_total_customers,
ROUND(SUM(revenue)::NUMERIC,2) AS LTV,
ROUND((SUM(revenue)/(SELECT SUM(revenue) from RAW_VALUES)*100)::NUMERIC,2) AS percent_of_total_value,ROUND(AVG(revenue)::NUMERIC,2) as avg_LTV 
FROM RAW_VALUES
GROUP BY value_group
ORDER BY num_customers;
