create database PRP_DVA

use PRP_DVA

select * from Transactions
select * from Product
select * from Customer

--Q1. How many distinct customers are there who has returned the product at least once?

select * from Transactions
where sale_amount < 0

--Q2. Find the top customer who redeemed the most reward points. What is their rank in terms of sales amount?

select TOP 1 Customer_ID, Customer_value, Points_redeemed,
DENSE_RANK() over (order by Customer_value) Cus_Rank
from Customer  
order by Points_redeemed desc




