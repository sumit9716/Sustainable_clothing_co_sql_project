
# 1. How many Transactions are done during each Marketing Campaigns?

select c.campaign_name, count(t.transaction_id) as No_of_Transactions
from marketing_campaigns c join transactions t on t.purchase_date 
between c.start_date and c.end_date and c.product_id = t.product_id
group by c.campaign_name;

# 2. Which product has the highest sales quantity.

with cte as 
( select t.product_id,product_name,sum(quantity) as Total_quantity_sold
from transactions t
 join sustainable_clothing s on t.product_id = s.product_id
 group by 1,2
 order by Total_quantity_sold desc)
 select * from cte where Total_quantity_sold in (select max(Total_quantity_sold) from cte);

#  3. What is the total revenue generated from each marketing campaign?

select c.campaign_name, round(sum(t.quantity*price),2) as Total_Revenue
from transactions t join sustainable_clothing s on t.product_id = s.product_id
join marketing_campaigns c on  t.purchase_date between c.start_date and c.end_date and  c.product_id = s.product_id 
group by c.campaign_name;

# 4. What is the top-selling product category based on the total revenue generated?

with cte as (select s.category, round(sum(t.quantity * price),2) as Total_Revenue
from transactions t join 
sustainable_clothing s on t.product_id = s.product_id 
 group by 1 order by Total_revenue desc)
select * from cte where Total_Revenue in (select max(Total_Revenue) from cte);		

# 5. Which products had a higher quantity sold compared to the average quantity sold?

select t.product_id, product_name,quantity
 from transactions t 
join sustainable_clothing s on t.product_id = s.product_id
where quantity > ( select avg(quantity) from transactions);

# 6. What is the average revenue generated per day during the marketing campaigns?

select purchase_date, round(avg(quantity*price),2) as Avg_revenue
from transactions t
join sustainable_clothing s on t.product_id = s.product_id
join marketing_campaigns c on  t.purchase_date between c.start_date and c.end_date and s.product_id = c.product_id
group by purchase_date;

# 7. What is the percentage contribution of each product to the total revenue?

with cte as (select round(sum(quantity*price),2) as Total_revenue
from transactions t
join sustainable_clothing s on t.product_id = s.product_id),

cte2 as 
(select product_name,round(sum(quantity*price),2) as Total_prod_revenue
from transactions t
join sustainable_clothing s on t.product_id = s.product_id
group by product_name)
select product_name,concat(round((Total_prod_revenue*100)/Total_revenue,2),"%") as pct_contri
from cte,cte2;

#  8. Compare the average quantity sold during marketing campaigns to outside the marketing campaigns.

with cte as 
(select avg(quantity) as Avg_qty_during_campaign
from transactions t
join sustainable_clothing s on t.product_id = s.product_id
join marketing_campaigns c on  t.purchase_date between c.start_date and c.end_date and  s.product_id = c.product_id),

cte2 as
(select avg(t.quantity) as Total_avg_qty
from transactions t
join sustainable_clothing s on t.product_id = s.product_id)

select Total_avg_qty,Avg_qty_during_campaign,
(Total_avg_qty - Avg_qty_during_campaign) as Avg_qty_outside_campaign
from cte,cte2;

#  9. Compare the revenue generated by products inside the marketing campaigns to outside the campaigns

with cte as
( select round(sum(quantity*price),2) as Total_rev_during_campaign
from transactions t
join sustainable_clothing s on t.product_id = s.product_id
join marketing_campaigns c on  t.purchase_date between c.start_date and c.end_date and  t.product_id = c.product_id),

cte2 as 
(select round(sum(quantity*price),2) as Total_revenue
from transactions t
join sustainable_clothing s on t.product_id = s.product_id)

select Total_revenue,Total_rev_during_campaign,
	Total_revenue - Total_rev_during_campaign as Total_rev_outside_campaign
    from cte,cte2;

#  10. Rank the products by their average daily quantity sold.

with cte as 
(select s.product_name,avg(quantity) as Avg_sold_qty
from transactions t
join sustainable_clothing s on t.product_id = s.product_id group by 1)
select product_name,Avg_sold_qty,
dense_rank() over (order by Avg_sold_qty desc) as Rank_avg from cte;
