------- DVA Case Study---------

create database PRP_DVA

use PRP_DVA

select * from Transactions
select * from Product
select * from Customer

--Q1. How many distinct customers are there who has returned the product at least once?

select distinct USER_ID from Transactions
where sale_amount < 0

--Q2. Find the top customer who redeemed the most reward points. What is their rank in terms of sales amount?

-- Using only Customer table

select TOP 1 Customer_ID, Customer_value, Points_redeemed,
DENSE_RANK() over (order by Customer_value) Cus_Rank
from Customer  
order by Points_redeemed desc

----

-- Using tables Customer and Transactions 

With Q2 as(
select b.Customer_ID, sum(a.sale_amount) as Sales, b.Points_redeemed
from Transactions a
left join Customer b
on a.USER_ID = b.Customer_ID
group by b.Customer_ID, b.Points_redeemed)

select top 1 *, DENSE_RANK() over (order by Sales) Cus_Rank from Q2
order by Points_redeemed desc

--Q3. What is the average transaction value by top 10 customers in terms of sales?

-- Using only Customer table

select round(avg(Sales),2) as Avg_Txn_Value from (
select TOP 10 Customer_ID, sum(Customer_value) as Sales from Customer
group by Customer_ID
order by 2 desc) x

----

-- Using tables Customer and Transactions 

With Q3 as(
select TOP 10 b.Customer_ID, sum(a.sale_amount) as Sales
from Transactions a
left join Customer b
on a.USER_ID = b.Customer_ID
group by b.Customer_ID
order by sum(sale_amount) desc) 

select round(AVG(Sales),2) Average_Txn_Value from Q3

----

-- Using Average Transaction Value formula on tables Customer and Transactions
-- Average Trasaction Value = Total Sales/ No. of Transactions

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

--Q5. Find the top 10 product categories by sales and what is their contribution out of overall sales in pecrentage?

select Product_Categories, Sales, 
round((Sales/(select sum(sale_amount) as Overall_Sales from Transactions))*100,2) as Sales_Contribution_Pct from (
select TOP 10 b.Category_level2_name_eng as Product_Categories, round(sum(a.sale_amount),2) as Sales 
--(a.sale_amount/(select sum(sale_amount) as Overall_Sales from Transactions))*100 as Total_Sales
from Transactions a
left join Product b
on a.product_id = b.PRODUCT_ID
group by b.Category_level2_name_eng
order by sum(a.sale_amount) desc) x

--Q6. Find the top 5 product categories with highest Margins?

select TOP 5 b.Category_level2_name_eng, round(sum(a.sale_amount),2) as Sales, round((sum(b.cost_price) - sum(a.sale_price)),2) as Profit_Margin
from Transactions a
left join Product b
on a.product_id = b.PRODUCT_ID
group by b.Category_level2_name_eng
order by 3 desc

--Q7. Find the top 5 product categories with highest margin and what is the percentage of contribution out of overall margins.

With def as(
select b.Category_level2_name_eng, round(sum(a.sale_amount),2) as Sales, round((sum(b.cost_price) - sum(a.sale_price)),2) as Profit_Margin
from Transactions a
left join Product b
on a.product_id = b.PRODUCT_ID
group by b.Category_level2_name_eng)

select TOP 5 *, round((Profit_Margin/(select sum(Profit_Margin) from def)*100),2) as Pct_Contribution from def
order by Sales desc

--Q8. What are top 10 product categories in terms of average sales and what is the standard deviation?

select TOP 10 b.Category_level2_name_eng as Product_Categories, round(avg(a.sale_amount),2) as Avg_Sales,
round(STDEV(a.sale_amount),2) as Standard_Deviation
from Transactions a
left join Product b
on a.product_id = b.PRODUCT_ID
group by b.Category_level2_name_eng
order by avg(a.sale_amount) desc

--Q9. What is correlation between number of transactions per month and customer value?
--Hint : Use corrleation coefficient formula after calculating sales and number of transactions by each month.

-- Creating View first to gather all the required columns to use it further to find correlation coefficient.

create view Table1 as 
select MONTH(a.order_time) as Months, count(a.sale_number) as No_of_Txns, round(sum(b.Customer_value),2) as Customer_Value
from Transactions a
left join Customer b
on a.USER_ID = b.Customer_ID
group by MONTH(a.order_time)

select * from Table1 order by Months

-- Using "Table1" View in With Clauses. Further finding Mean, Variance, Standard Deviation and Covariance to find Correlation 
-- between No. of Transactions and Customer Value.

WITH Mean AS (
	select Months, No_of_Txns, Customer_Value,
	AVG(No_of_Txns) OVER() as Mean_x1,
	AVG(Customer_Value) OVER() as Mean_x2
	from Table1
),
Variance as (
	select AVG(cast(POWER(No_of_Txns - Mean_x1, 2) as bigint)) as Var_x1,
	AVG(cast(POWER(Customer_Value - Mean_x2, 2) as bigint)) as Var_x2
	from Mean
),
StdDev as (
	select POWER(Var_x1, 0.5) as Std_x1,
	POWER(Var_x2, 0.5) as Std_x2
	from Variance
),
Covariance as (
	select AVG((No_of_Txns - Mean_x1) * (Customer_Value - Mean_x2)) as Cov_x1_x2
	from Mean
)

select Cov_x1_x2 / (Std_x1 * Std_x2) as Corr_x1_x2
from Covariance, StdDev

--Q10. Find the Month over Month (MOM) growth of profit margin in percentage (from 1st month to last month).

select *, round(coalesce(((Profit_Margin - Previous_Profit_Margin)/ Previous_Profit_Margin)*100, 0), 2) as MoM from (
select *, LAG(Profit_Margin) OVER (order by Months) as Previous_Profit_Margin from 
(select MONTH(a.order_time) as Months, round((sum(b.cost_price) - sum(a.sale_price)),2) as Profit_Margin
from Transactions a
left join Product b
on a.product_id = b.PRODUCT_ID
group by MONTH(a.order_time)) x) y
order by 1

------------------------------------------------------------------------------------------------------------------------------
