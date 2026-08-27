-- ACTIVE/CHURNED customers per year
WITH RAW_VALUES AS(
    SELECT customerkey,min_date,max_date as last_purchase,
    CASE 
        WHEN max_date > (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue) THEN 'ACTIVE'
        ELSE 'CHURNED'
    END as status,
    total_revenue
    FROM dayly_revenue
    WHERE min_date <= (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue) and extract(YEAR from min_date) < 2024
), retention_yearly as(
SELECT extract(year from min_date) as year,
count(case when status = 'ACTIVE' then 1 end) as active,
count(case when status = 'CHURNED' then 1 end) as churned,
count(status) as total_customers,
ROUND(sum(total_revenue)::NUMERIC,2) as revenue
from RAW_VALUES
GROUP BY year)

SELECT *, round(((SUM(active) OVER(PARTITION BY year)/SUM(total_customers) OVER(PARTITION BY year))*100)::NUMERIC,2) as percent_active,
round(((SUM(churned) OVER(PARTITION BY year)/SUM(total_customers) OVER(PARTITION BY year))*100)::NUMERIC,2) as percent_churn FROM retention_yearly

-- ACTIVE/CHURNED final stats
WITH RAW_VALUES AS(
    SELECT customerkey,min_date,max_date as last_purchase,
    CASE 
        WHEN max_date > (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue) THEN 'ACTIVE'
        ELSE 'CHURNED'
    END as status,
    total_revenue
    FROM dayly_revenue
    WHERE min_date <= (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue) and extract(YEAR from min_date) < 2024
), retention_yearly as(
SELECT extract(year from min_date) as year,
count(case when status = 'ACTIVE' then 1 end) as active,
count(case when status = 'CHURNED' then 1 end) as churned,
count(status) as total_customers,
ROUND(sum(total_revenue)::NUMERIC,2) as revenue
from RAW_VALUES
GROUP BY year)

SELECT status, count(*),sum(count(*)) OVER() as total, round((count(*)/sum(count(*)) OVER() *100)::NUMERIC,2) as percent, ROUND(SUM(total_revenue)::NUMERIC,2) AS revenue
FROM RAW_VALUES
GROUP BY status