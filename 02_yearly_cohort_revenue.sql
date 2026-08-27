WITH cte as(
    SELECT 
    customerkey,
    MIN(TO_CHAR(orderdate, 'yyyy-mm')) as cohort
    from public.dayly_revenue
    GROUP BY customerkey
)

SELECT coalesce(c.cohort,'total') as month,sum(total_revenue) as revenue,COALESCE(nullif(count(distinct s.customerkey),0),1) as num_customers, sum(total_revenue)/COALESCE(nullif(count(distinct s.customerkey),0),1) as avg_revenue
from public.dayly_revenue s
LEFT JOIN cte c ON c.customerkey = s.customerkey
GROUP BY c.cohort
ORDER BY c.cohort;
