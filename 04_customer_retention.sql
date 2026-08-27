WITH RAW_VALUES AS(
    SELECT customerkey,max_date as last_purchase,
    CASE 
        WHEN max_date > (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue)  THEN  'ACTIVE'
        ELSE 'CHURNED'
    END as status
    FROM dayly_revenue
    WHERE min_date < (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue)
)

SELECT extract(YEAR FROM max_date) as year,
CASE WHEN max_date > (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue GROUP BY extract(YEAR FROM max_date))  THEN  count(*) END AS ACTIVE,
CASE WHEN max_date < (SELECT (max(max_date) - INTERVAL'6 MONTH')::date FROM dayly_revenue GROUP BY extract(YEAR FROM max_date))  THEN  count(*) END AS CHURNED
FROM dayly_revenue
WHERE min_date < (SELECT (max(max_date) - INTERVAL'6 MONTH' GROUP BY extract(YEAR FROM max_date))::date FROM dayly_revenue)
GROUP BY year

-- SELECT * from RAW_VALUES
-- SELECT status, count(*)--, (count(*)/(SELECT count(*) from RAW_VALUES)*100) 
-- FROM RAW_VALUES
-- GROUP BY status




