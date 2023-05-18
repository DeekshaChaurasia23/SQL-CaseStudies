-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as total_amount
from sales s join menu m 
on s.product_id=m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as no_of_days
from sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
with final as
(select s.customer_id, m.product_name ,
rank() over (partition by customer_id order by order_date ) as ranking
from sales s join menu m 
on s.product_id = m.product_id)
select * from final where ranking=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(*) as no_of_times_purchased
from sales s join menu m 
on s.product_id=m.product_id
group by m.product_name
order by no_of_times_purchased desc limit 1;

-- 5. Which item was the most popular for each customer?

With final as
(
Select s.customer_id ,m.product_name, Count(s.product_id) as count,
Dense_rank()  Over (Partition by s.customer_id order by count(s.product_id) desc ) as ranking
From menu m
join sales s
On m.product_id = s.product_id
group by s.customer_id,s.product_id,m.product_name
)
select customer_id,product_name,count
From final
where ranking = 1;

-- 6. Which item was purchased first by the customer after they became a member?

with final as(
select s.customer_id,m.product_name,s.order_date,
dense_rank() over (partition by s.customer_id order by s.order_date) as ranking
from sales s join menu m
on s.product_id=m.product_id
join members n
on s.customer_id=n.customer_id
where s.order_date>=n.join_date)
select customer_id,product_name,order_date from final where ranking=1;

-- 7. Which item was purchased just before the customer became a member?
with final as(
select s.customer_id,m.product_name,s.order_date,
dense_rank() over (partition by s.customer_id order by s.order_date) as ranking
from sales s join menu m
on s.product_id=m.product_id
join members n
on s.customer_id=n.customer_id
where s.order_date<n.join_date)
select customer_id,product_name,order_date from final where ranking=1;

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id,count(s.product_id) as total_price,sum(m.price)as total_amount
from sales s join menu m
on s.product_id=m.product_id
join members n
on s.customer_id=n.customer_id
where s.order_date < n.join_date
group by s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as(select s.customer_id,
case when m.product_name = 'sushi' then 2*m.price 
else m.price
end as new_price
from sales s join menu m on
s.product_id=m.product_id)
select customer_id, sum(new_price)*10 as total_points from points
group by customer_id;

-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi — how many points do customer A and B have at the end of January?

with finalpoints as(select s.customer_id,
case when m.product_name = 'sushi' then 2*m.price 
when s.order_date between n.join_date and (n.join_date + interval 6 day) then 2*m.price
else m.price
end as new_price
from sales s join menu m on
s.product_id=m.product_id 
join members n on
s.customer_id=n.customer_id
where month(s.order_date)=1
)
select customer_id, sum(new_price)*10 as total_points from finalpoints
group by customer_id




