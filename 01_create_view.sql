CREATE OR REPLACE VIEW public.dayly_revenue as
SELECT o.customerkey,s.orderdate, o.order_key,SUM(quantity*netprice/exchangerate) as total_revenue,
countryfull,age,givenname,surname, concat(givenname,' ',surname) as name
FROM sales s
left join order_1 o on o.order_key = s.orderkey 
LEFT JOIN customer c on o.customerkey = c.customerkey
GROUP BY s.orderdate,o.customerkey,o.order_key,countryfull,age,givenname,surname,name;
