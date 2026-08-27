CREATE OR REPLACE VIEW public.dayly_revenue as
SELECT s.customerkey,min(orderdate) as min_date,max(orderdate) as max_date, min(orderkey) min_key,SUM(quantity*netprice/exchangerate) as total_revenue,
countryfull,age,concat(givenname,' ',surname) as name
FROM sales s
--left join order_1 o on o.customerkey = s.customerkey 
LEFT JOIN customer c on s.customerkey = c.customerkey
GROUP BY s.customerkey,countryfull,age,name --s.orderdate,o.customerkey,o.order_key,countryfull,age,givenname,surname,name;
