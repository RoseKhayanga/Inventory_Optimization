create database supply_chain_db;

use supply_chain_db;

create table weekly_stock_tracker2 (
    id int auto_increment primary key,
    key_id int,
    product_id varchar(50),
    product_name  varchar(255),
    unit_price decimal(10,2),
	stock_level int,
    reorder_level int,
    lead_time_days int,
    weekly_usage decimal(10,2),
    date date,
    stockweeks decimal(10,4),
    leadtime_weeks decimal(10,4),
    status varchar(50)
    ); 
    
insert into weekly_stock_tracker2 (
  key_id,
  product_id, 
  product_name,
  unit_price, 
  stock_level, 
  reorder_level, 
  lead_time_days, 
  weekly_usage, 
  date,
  stockweeks, 
  leadtime_weeks, 
  status
) 
select
p.key_id,
p.Product_ID,
P.ProductName,
p.Unit_Price,
p.Stock_Level,
p.Reorder_Level,
p.Lead_Time_Days,
p.weekly_usage,
current_date() as date,
((p.Stock_Level-p.Reorder_Level)/(p.weekly_usage)) as stock_weeks,
(p.Lead_Time_Days/7) as leadtime_weeks,
case 
   when ((p.Stock_Level-p.Reorder_Level)/(p.weekly_usage)) <(p.Lead_Time_Days/7)
   then 'Trigger' 
   else 'No Trigger' 
end as status
from products2 as p;

select * from weekly_stock_tracker2;


-- Write SQL queries for:
-- Checking stock levels and flagging items below reorder levels
create view stock_level_view as
select 
Product_ID,
ProductName,
Unit_Price,
Stock_Level,
Reorder_Level
from products2 p
where Stock_Level <Reorder_Level;


-- Finding the top suppliers with the shortest lead times
create view Top5SuppliersShortestLeadtime as
select
distinct s.supplier_id,
s.company,
p.lead_time_days
from suppliers2 s
join products2 p on s.key_id =p.key_id
order by lead_time_days asc
limit 5;

-- Analyzing total order quantities over time
create view TotalOrderQuantitiesOvertime as
select 
    p.date AS Order_Date,
    SUM(o.Quantity_Ordered) AS Total_Quantity_Ordered
FROM orders2 o
JOIN products2 p ON o.key_id = p.key_id
GROUP BY p.date
ORDER BY p.date ASC;


-- Predicting when to reorder based on lead time and stock trends
-- Things to consider 
-- - 1)stock_weeks -number of weeks your current inventory can sustain sales at the current rate. 

--   2)lead_time_weeks - the time from when an order is placed to when the finished product is
-- delivered to the customer, including all stages like raw material procurement, manufacturing, and shipping. 

-- IMPORTANCE 
-- 1) Optimizes inventory levels: Helps avoid stockouts and overstocking. 
-- 2) Improves cash flow: Reduces the amount of capital tied up in excess inventory. 
-- 3) Enhances customer satisfaction: Ensures products are available when customers need them. 
-- 4) Facilitates better planning: Allows businesses to plan for future demand and restock effectively. 

create view PredictingReorderLevel as
select
key_id,
product_id,
product_name,
unit_price,
lead_time_days,
stock_level,
reorder_level,
weekly_usage,
((stock_level-reorder_level)/(weekly_usage)) as stock_weeks,
(lead_time_days/7) as leadtime_weeks,
case 
   when ((stock_level-reorder_level)/(weekly_usage)) <(lead_time_days/7)
   then 'Trigger' 
   else 'No Trigger' 
end as status
from weekly_stock_tracker2;



