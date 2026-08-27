WITH cte as(
    SELECT 
    customerkey,
    MIN(TO_CHAR(min_date, 'yyyy-mm')) as cohort
    from public.dayly_revenue
    GROUP BY customerkey
)

SELECT c.cohort as month,ROUND((sum(total_revenue))::NUMERIC,2) as revenue,count(distinct s.customerkey) as num_customers,
ROUND((sum(total_revenue)/count(distinct s.customerkey))::NUMERIC,2) as avg_revenue
from public.dayly_revenue s
LEFT JOIN cte c ON c.customerkey = s.customerkey
GROUP BY c.cohort
ORDER BY c.cohort;
