-- Bonus Questions

-- 1.Join All The Things

select s.customer_id,s.order_date,m.product_name,m.price,
case when s.order_date < n.join_date then 'N' 
     when n.join_date is null then 'N'
else 'Y' end as member
from sales s join menu m
on s.product_id=m.product_id 
left join members n 
on s.customer_id=n.customer_id
order by customer_id asc,order_date asc,product_name asc,price desc;

-- 2. Rank All The Things
with final as
(select s.customer_id,s.order_date,m.product_name,m.price,
case when s.order_date < n.join_date then 'N' 
     when n.join_date is null then 'N'
else 'Y' end as member
from sales s join menu m
on s.product_id=m.product_id 
left join members n 
on s.customer_id=n.customer_id
order by customer_id asc,order_date asc,product_name asc,price desc)
select * , case when member='N' then null
else rank() over (partition by s.customer_id,member order by order_date ) end as ranking
from final




