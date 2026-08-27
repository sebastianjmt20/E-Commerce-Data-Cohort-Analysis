
WITH EXTRA AS (
    SELECT
        -- customerkey, 
        PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY s.quantity*s.exchangerate*s.netprice) as Low,
        PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY s.quantity*s.exchangerate*s.netprice) as High
    FROM SALES s
    -- GROUP BY customerkey
    -- WHERE orderdate BETWEEN '2022-01-01' AND '2023-12-31'
), RAW_VALUES as (
SELECT s.customerkey, sum(netprice*quantity/exchangerate) as revenue,
    CASE 
        WHEN (netprice*quantity/exchangerate) <= e.Low THEN 'Low Value'
        WHEN (netprice*quantity/exchangerate) > e.Low
            AND (netprice*quantity/exchangerate) <= e.High
        THEN 'Mid Value'
        WHEN (netprice*quantity/exchangerate) > e.High THEN 'High Value'
    END as value_group
FROM sales s, EXTRA e
GROUP BY s.customerkey, value_group)
-- cume_dist (gives the running percentage)
SELECT value_group,count(*) as num_customers, ROUND(((count(*))/(SELECT count(*) from RAW_VALUES)*100)::NUMERIC,2) AS percent_of_total_customers,
ROUND(SUM(revenue)::NUMERIC,2) AS LTV,
ROUND((SUM(revenue)/(SELECT SUM(revenue) from RAW_VALUES)*100)::NUMERIC,2) AS percent_of_total_value,ROUND(AVG(revenue)::NUMERIC,2) as avg_LTV 
FROM RAW_VALUES
GROUP BY value_group
ORDER BY num_customers;