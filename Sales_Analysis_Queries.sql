select * from df_orders12;
-- find top 10 highest revenue generating products
select product_id,sum(sale_price) as sales 
from df_orders12
group by product_id
order by sales desc limit 10;

-- find top 5 highest selling products in each region
with cte as (
select region,sum(sale_price) as sales,product_id
 from df_orders12 
 group by region ,product_id)
select * from
(select * ,
row_number() over(partition by region order by sales desc) as rn 
from cte ) a where rn<=5;

-- find month over month growth comparison for 2022 and 2023 sales 
-- eg : jan 2022 and jan 2023
with cte as(
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales from df_orders12 
group by year(order_date),month(order_date))
select order_month,sum(case 
when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end)as sales_2023
from cte
group by order_month order by order_month;

-- for each category which month had highest sales
with cte as (
select category,
date_format(order_date,'%Y %m') as order_year_month,
sum(sale_price) as sales
from df_orders12
group by category,date_format(order_date,'%Y %m') 
order by category,date_format(order_date,'%Y %m')
)
select * from
(select category,order_year_month,
rank() over(partition by category order by sales desc)as rn
 from cte) a 
 where rn=1;
 
-- which sub category had highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders12
group by sub_category,year(order_date)
),
cte2 as(
select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end)as sales_2023
from cte
group by sub_category
)
select * ,
round((sales_2023-sales_2022)*100/sales_2022, 2) as growth_percentage
from cte2
order by growth_percentage desc 
limit 1;
