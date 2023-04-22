create database PRP_DVA

use PRP_DVA

select * from Transactions
select * from Product
select * from Customer

--Q1. How many distinct customers are there who has returned the product at least once?

select * from Transactions
where sale_amount < 0

--Q2. Find the top customer who redeemed the most reward points. What is their rank in terms of sales amount?

