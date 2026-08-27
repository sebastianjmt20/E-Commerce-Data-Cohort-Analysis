WITH RAW_VALUES AS(
    SELECT customerkey,min_date,max_date as last_purchase,
    CASE 
        WHEN max_date > (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue) THEN 'ACTIVE'
        ELSE 'CHURNED'
    END as status,
    total_revenue
    FROM dayly_revenue
    WHERE min_date <= (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue) and extract(YEAR from min_date) < 2024
)

SELECT extract(year from min_date) as year,
count(case when status = 'ACTIVE' then 1 end) as active,
count(case when status = 'CHURNED' then 1 end) as churned,
count(status) as total_customers,
--count(case when status = 'ACTIVE' then 1 end)/count(case when status = 'ACTIVE' then 1 end)+count(case when status = 'CHURNED' then 1 end) as percent_active,
--count(case when status = 'CHURNED' then 1 end)/count(case when status = 'ACTIVE' then 1 end)+count(case when status = 'CHURNED' then 1 end) as percent_churned,
ROUND(sum(total_revenue)::NUMERIC,2) as revenue
from RAW_VALUES
GROUP BY year
ORDER BY year


SELECT status, count(*),sum(count(*)) OVER() as total, round((count(*)/sum(count(*)) OVER() *100)::NUMERIC,2) as percent, ROUND(SUM(total_revenue)::NUMERIC,2) AS revenue
FROM RAW_VALUES
GROUP BY status

/*
SELECT extract(YEAR FROM min_date) as year,
count(CASE WHEN max_date > (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE and min_date < (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE THEN 'ACTIVE' END) AS ACTIVE,
count(CASE WHEN max_date <= (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE or min_date > (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE THEN  'CHURNED'END) AS CHURNED,
count(*) year_total,
ROUND((count(CASE WHEN max_date > (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE and min_date < (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE THEN 'ACTIVE' END)::INTEGER 
/SUM(count(*)) OVER(PARTITION BY extract(YEAR FROM min_date)) * 100)::NUMERIC,2) AS percert_active,
ROUND(((count(CASE WHEN max_date < (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE or min_date > (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')::DATE THEN  'CHURNED'END)::INTEGER 
/SUM(count(*)) OVER(PARTITION BY extract(YEAR FROM min_date))) * 100)::NUMERIC,2) AS percert_churn,
ROUND(SUM(total_revenue)::NUMERIC,2) AS revenue
FROM dayly_revenue
WHERE extract(YEAR FROM min_date) < 2024
GROUP BY year 
ORDER BY YEAR*/

-- SELECT count(*) from dayly_revenue
-- WHERE extract(YEAR from min_date) = 2015
-- SELECT * from RAW_VALUES

--SELECT extract(YEAR FROM min_date) as year,
--    count(CASE 
--        WHEN (max_date > (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')) 
--        and (min_date < (('31-12-' || extract(YEAR FROM max_date))::date - INTERVAL '6 month')) 
--        THEN 'ACTIVE' END) AS ACTIVE_CUSTOMERS
--from dayly_revenue
--WHERE extract(YEAR FROM min_date) < 2024
--GROUP BY year