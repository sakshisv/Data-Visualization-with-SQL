create database PRP_DVA

use PRP_DVA

select * from Transactions
select * from Product
select * from Customer

--Q1. How many distinct customers are there who has returned the product at least once?

select distinct USER_ID from Transactions
where sale_amount < 0

--Q2. Find the top customer who redeemed the most reward points. What is their rank in terms of sales amount?

select TOP 1 Customer_ID, Customer_value, Points_redeemed,
DENSE_RANK() over (order by Customer_value) Cus_Rank
from Customer  
order by Points_redeemed desc

----

With Q2 as(
select b.Customer_ID, sum(a.sale_amount) as Sales, b.Points_redeemed
from Transactions a
left join Customer b
on a.USER_ID = b.Customer_ID
group by b.Customer_ID, b.Points_redeemed)

select top 1 *, DENSE_RANK() over (order by Sales) Cus_Rank from Q2
order by Points_redeemed desc

--Q3. What is the average transaction value by top 10 customers in terms of sales?

With Q3 as(
select TOP 10 b.Customer_ID, sum(a.sale_amount) as Sales
from Transactions a
left join Customer b
on a.USER_ID = b.Customer_ID
group by b.Customer_ID
order by sum(sale_amount) desc) 

select round(AVG(Sales),2) Average_Txn_Value from Q3

----

select round(sum(Sales)/sum(No_of_Sales),2) as Average_Txn_Value from (
select TOP 10 b.Customer_ID, sum(a.sale_amount) as Sales, count(a.sale_number) as No_of_Sales
from Transactions a
left join Customer b
on a.USER_ID = b.Customer_ID
group by b.Customer_ID
order by sum(a.sale_amount) desc) x

--Q4. Calculate the profit margin for top 10 product categories (Based on sales)?

select TOP 10 b.Category_level2_name_eng, round(sum(a.sale_amount),2) as Sales, round((sum(b.cost_price) - sum(a.sale_price)),2) as Profit_Margin
from Transactions a
left join Product b
on a.product_id = b.PRODUCT_ID
group by b.Category_level2_name_eng
order by sum(a.sale_amount) desc





