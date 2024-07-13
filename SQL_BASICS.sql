-- SQL is case insensitive
-- Using WHERE clause to filter the rows
select * from movies where industry = "Bollywood";

-- Using COUNT for counting the number of rows
select count(*) from movies where industry = "hollywood";

-- Using DISTINCT to get distinct rows
select distinct studio from movies;

-- Using LIKE to get specified string
-- % is used to find any string before or after and _ is used to find any single character before/after
select * from movies where title like "%thor%";

-- To check null values only for numerical columns
select * from movies where studio="";

-- Logical operator
select * from movies where imdb_rating>=6 and imdb_rating<=9;

-- Using BETWEEN operatoget_gross_sales_monhtlyr to simplify the above query
select * from movies where imdb_rating between 6 and 9;

-- Using IN operator
select * from movies where release_year in (2018, 2019, 2020);

-- Using ORDER BY opertor default its ascending DESC
select * from movies where industry = "bollywood" order by imdb_rating;

-- Using LIMIT operator to limit the number of records
select * from movies where industry = "hollywood" order by imdb_rating limit 5;

-- Using OFFSET operator to get rows from specified index
select * from movies where industry = "hollywood" order by imdb_rating limit 1 offset 2;
select * from movies;

-- Using GROUP BY to group the rows having same value in specified columns
select industry, count(*) from movies group by industry;

-- Using HAVING operator
-- Print all the years where more than 2 movies were released
-- What ever column you have in HAVING, the column should be present in SELECT statement
-- FROM	--> WHERE --> GROUP BY --> HAVING --> ORDER BY
select release_year,count(release_year) as cnt from movies group by release_year having cnt>2;

-- Using YEAR() and CURDATE() to get present year
select *,year(curdate())-birth_year as age from actors;

-- Using IF statement to get conditional columns
select *,
	if(currency="USD", revenue*83, revenue) as revenue_inr from financials;

-- Using CASE statement to check multiple if statements
select *,
CASE
	when unit="Billions" then revenue*1000
    when unit="Thousands" then revenue/1000
    else revenue
END as revenue_mln from financials;

-- SQL join INNER(Common rows and default), LEFT and RIGHT
select movie_id,title,budget,revenue from movies
left join financials using(movie_id);

-- Using UNION and UNION ALL NOTE: THE NUMBER OF COLUMN AND COLUMN NAME SHOULD BE SAME
-- UNION is used to select distinct values
-- UNION ALL allows duplicate values as well
select m.movie_id,f.budget,f.revenue from movies m left join financials f using (movie_id)
union
select f.movie_id,f.budget, f.revenue from financials f left join movies m using (movie_id);

-- Using CROSS JOIN
select *,
concat(name, " - ", varient_name) as full_name,
(price+variant_price) as full_price from items
cross join variants;

-- Using GROUP_CONCAT() to group multiple rows into one having same movie_id and title
select m.movie_id,m.title,group_concat(a.name separator " | ") from movies m
join movie_actor ma using (movie_id)
join actors a using (actor_id)
group by m.movie_id;
select a.name, group_concat(m.title separator " | ") as movies, count(a.name) as cnt from actors a
join movie_actor ma using (actor_id)
join movies m using (movie_id)
group by a.name;

-- Using SUBQUERY to get maximum imdb rating. This subquery returns only single value
select * from movies
where imdb_rating = (select max(imdb_rating) from movies);

-- Using SUBQUERY to get max imdb rating. This subquery returns list of value
select * from movies
where imdb_rating in ((select max(imdb_rating) from movies), (select min(imdb_rating) from movies));

-- Using SUBQUERY to get actors who are between 70 and 85. This subquery returns a table or multiple rows
select * from (select name,year(curdate())-birth_year as age from actors) as actors_age
where age>70 and age<85;

-- Get actors who have acted in any of these movies (101,110,121)
select * from actors a
join movie_actor ma using (actor_id)
where ma.movie_id in (101,110,121);

-- Using ANY and without using join get actors who have acted in any of these movies (110,101,121)
select * from actors
where actor_id = ANY (select actor_id from movie_actor where movie_id in (101,110,121));

-- Select all movies whose rating is greater than any of the marvel movies rating
select * from movies 
where imdb_rating > ANY (select imdb_rating from movies where studio="Marvel studios ");

-- Select actor_id, actors and total number of movies they acted in
select a.actor_id,a.name,count(a.actor_id) as movies_count from actors a
where actor_id = ANY (select actor_id from movie_actor)
group by a.actor_id
order by movies_count desc;
-- The same problem statement can be achieved without using JOIN and GROUP BY
-- This is called corelated subquery and acts as for loop to calculate the movies_count
select actor_id, name, 
(select count(*) from movie_actor where actor_id = actors.actor_id) as movies_count from actors
order by movies_count desc;

-- Use EXPLAIN ANALYZE to analyze the performance of the query.

-- Using CTE
with actors_age as (select name,year(curdate())-birth_year as age from actors)
select * from actors_age
where age>70 and age<85;

-- movies that producd 500% profit and their rating was less than average rating for all movies
with
	x as (select *,round((revenue-budget)*100/budget,2) as pct_profit from financials),
    y as (select * from movies where imdb_rating < (select avg(imdb_rating) from movies))
select x.movie_id,y.title,x.pct_profit,y.imdb_rating from x
join y using(movie_id)
where pct_profit>=500;
-- select m.movie_id,m.title,f.pct_profit,m.imdb_rating 
-- from (select movie_id,round((revenue-budget)*100/budget,2) as pct_profit from financials) f
-- join (select movie_id,title,imdb_rating from movies where imdb_rating<(select avg(imdb_rating) from movies)) m
-- using (movie_id)
-- where pct_profit>=500;

# Benifits of SUBQUERY AND CTE
# Query Readability
# Query Reuseability (with CTE, because the result can be used anywhere / anytime within with scope)
# Visibility for creating data views

-- 1) select all the movies with minimum and maximum release_year. Note that there can be more than 
-- one movies in min and max year hence output rows can be more than 2
select * from movies where release_year in 
((select max(release_year) from movies),
(select min(release_year) from movies));
    
-- 2) select all the rows from movies table whose imdb_rating is higher than the average rating
select * from movies where imdb_rating > (select avg(imdb_rating) from movies);

-- select all hollowood movies released after year 2000 that made more than 500 millions $ profit 
-- or more profit. Note that all hollywood movies have millions as a unit hence you don't need to 
-- do unit converstion. Also you can write this query without CTE as well but you should try to 
-- write this using CTE only
with cte as (
	select m.movie_id,m.release_year,(f.revenue-f.budget) as profit_mln from financials f
    join movies m
    using (movie_id)
	where m.release_year>2000 and m.industry="Hollywood"
)
select * from cte where profit_mln >=500;

-- Normalization is a process of organizing database so that we can avoid duplication and increase data intigrity.
-- Data Intigirty is accuracy and consistency of data over its life cycle.
-- TINYINT-1 byte,SMALLINT-2,MEDIUMINT-3,INT-4,BIGINT-8
-- FLOAT-4,DOUBLE-8 can be used scientific calculations and DECIMAL(3,1) for business case
-- STRING-> CHAR(3)Fixed length, VARCHAR() variable length and ENUM("Units","Millions","Billions","Thousands")
-- DATE-> DATETIME(Its range is more flexible), TIMESTAMP(The boundry is real year boundary),YEAR,DATE,TIIME
-- Natural key - is a key which is created using original data set.
-- Surrogate Key - is a key which is created artificially.
-- Composite Key - combination of two or more column and it is natural key.
-- Foreign Key - is a reference of primary key of another table in this table.
-- STAR SCHEMA: Consists of dim and fact table, where dim table contains attributes which ammend in fact table.
-- SNOW FLAKE SCHEMA: where dim table is further sub divided into one more dim table.
-- Dimension Table: which doesn't get update often
-- Function are helpful to perform complex calculations and data manipulation with ease.
-- Deterministic is a keyword used in function so that output dosen't change with years.
-- STORE PROCEDURE is used so that code can be reused over and over again.get_gross_sales_monhtlyget_gross_sales_monhtly

-- Generate a report of individual product sales (aggregated on monthly basis at product code level)
-- for Chroma India customer for FY=21 so that i can track individual product sales and run further
-- analytics on it in excel.
-- 1. Month
-- 2. Product Name
-- 3. Variant
-- 4. Sold Quantity
-- 5. Gross Price per Item
-- 6. Gross price total

select s.date,s.product_code,p.product,p.variant,s.sold_quantity,
 g.gross_price, (g.gross_price*s.sold_quantity) as total_gross_price from fact_sales_monthly s
join dim_product p using(product_code)
join fact_gross_price g on p.product_code=g.product_code and g.fiscal_year=get_fiscal_year(s.date)
where s.customer_code = '90002002' and get_fiscal_year(s.date)=2021
order by date asc
limit 10000;

-- Get aggregated monthly gross sales report for Chroma India customer so that I can track how much
-- sales this particular customer is generating for Atliq and manage relationship accordingly.
-- 1. Month
-- 2. Total Gross Sales amount to Croma India in this month
select s.date,round(sum(g.gross_price*s.sold_quantity),2.5) as total_gross_price from fact_sales_monthly s
join fact_gross_price g on g.fiscal_year=get_fiscal_year(s.date) and g.product_code=s.product_code
where s.customer_code = '90002002'
group by s.date
order by s.date;

-- Generate a yearly report for Croma India where there are two columns
-- 1. Fiscal Year
-- 2. Total Gross Sales amount In that year from Croma
select get_fiscal_year(s.date) as fiscal_year, round(sum(s.sold_quantity*g.gross_price),2) from fact_sales_monthly s
join fact_gross_price g on g.product_code=s.product_code and g.fiscal_year=get_fiscal_year(s.date)
where customer_code = '90002002'
group by g.fiscal_year;

-- Create a store procedure for monthly gross sales report

-- Create a store procedure that can determine the market badge based on the following logic,
-- if total_sold_qty>5 million that market is considered Gold or silver.

-- Benefits of Stored Procedure
-- 1. Convenience
-- 2. Security (Give access to those who are authorized)
-- 3. Maintainability
-- 4. Performance
-- 5. Developer Productivity 

-- Duration Time: Is the time that query needs to execute.
-- Fetch Time: is the time to fetch the result.

-- Get a report of top market, product and customer by net sales for given financial year, so that I
-- can have holistic view of our financial performance and can take appropriate action to address
-- any potential issues.
-- 1. Market
-- 2. Sales in millions
explain analyze
select s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price as gross_price_per_item,
round(s.sold_quantity*g.gross_price,2) as total_gross_price,pre.pre_invoice_discount_pct from fact_sales_monthly s
join dim_product p on p.product_code = s.product_code
join dim_date dt on dt.calendar_date = s.date -- created dim_date to increase the performance
join fact_gross_price g on g.fiscal_year = dt.fiscal_year and g.product_code = s.product_code
join fact_pre_invoice_deductions pre on pre.fiscal_year = dt.fiscal_year and pre.customer_code = s.customer_code
where dt.fiscal_year=2021
group by s.date;

-- Added extra column "fiscal_year" in fact_sales_monthly 
select s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price as gross_price_per_item,
round(s.sold_quantity*g.gross_price,2) as total_gross_price,pre.pre_invoice_discount_pct from fact_sales_monthly s
join dim_product p on p.product_code = s.product_code
join fact_gross_price g on g.fiscal_year = s.fiscal_year and g.product_code = s.product_code
join fact_pre_invoice_deductions pre on pre.fiscal_year = s.fiscal_year and pre.customer_code = s.customer_code
where s.fiscal_year=2021
group by s.date;

-- Benefits of Views
-- 1. Simplify queries
-- 2. The central place for your logic = few errors
-- 3. User control access
select *,total_gross_price - (total_gross_price*pre_invoice_discount_pct) as net_invoice_sales
from sales_pre_invoice_discount; -- get new invoice sales
-- Create a view for sales_post_invoice_discounts and net_sales
select *,round((1-post_invoice_deduction)*net_invoice_sales,2) from sales_post_invoice_discount;

-- Report for top 5 by market and creating a stored procedure 
select market,round(sum(net_sales/1000000),2) as net_sales_mln from net_sales
where fiscal_year=2021
group by market
order by net_sales_mln desc
limit 5;

-- Get top 3 customers by net sales and create a stored procedure
select c.customer,round(sum(net_sales/1000000),2) as net_sales_mln from net_sales s
join dim_customer c using (customer_code)
where fiscal_year=2021
group by customer
order by net_sales_mln desc
limit 5;

-- Get top 5 produt by net sales and create a stored procedure
select product,round(sum(net_sales/1000000),2) as net_sales_mln from net_sales
where fiscal_year=2021
group by product
order by net_sales_mln desc
limit 5;

-- A WINDOW FUNCTION performs a calculation across a set of table rows that are somehow related
-- to the current row. No window function can be defined without an OVER clause (random_tables)
-- This query is calculated with respect to each row
select *, amount*100/sum(amount) over() as pct from expenses
order by category,date;

-- To get query based on each category we can use PARTITION BY in OVER() caluse
select *,amount*100/sum(amount) over(partition by category) as pct from expenses
order by category,date;

-- Cumulative sum increments the next value step by step with current value.
select *,sum(amount) over(partition by date) as total_bill_till_date 
from expenses;

-- Get a report for fiscal_year=2021 for top 10 market by net sales %
with cte1 as 
(select c.customer,round(sum(net_sales/1000000),2) as net_sales_mln from net_sales s
join dim_customer c using (customer_code)
where fiscal_year=2021
group by c.customer
order by net_sales_mln desc)

select *, net_sales_mln*100/sum(net_sales_mln) over() as pct from cte1;

-- Get the report region wise by net sales % and breakdown by customers in respective region
with cte1 as (
select c.customer,round(sum(net_sales/1000000),2) as net_sales_mln from net_sales s
join dim_customer c using (customer_code)
where fiscal_year=2021 and region = "EU"
group by c.customer
order by net_sales_mln desc)
select *,net_sales_mln*100/sum(net_sales_mln) over() as pct from cte1;

-- Create a store procedure to get top n products in each division by their quantity sold in a given fiscal year
with cte as (select p.division,p.product,sum(s.sold_quantity) as total_qty from fact_sales_monthly s
join dim_product p using (product_code)
where s.fiscal_year=2021
group by p.division,p.product),

-- ROW_NUMBER(): This function assigns a unique sequential number to each row within a window. It's 
			  -- like numbering the rows in order.

-- RANK(): The RANK() function handles tied values by assigning the same rank to them. However, it may 
		-- skip subsequent ranks, leaving gaps in the sequence.

-- DENSE_RANK(): Similar to RANK(), DENSE_RANK() also handles tied values by assigning the same rank. 
			  -- However, it does not skip ranks, resulting in no gaps in the sequence.
cte1 as (select *, dense_rank() over(partition by division order by total_qty desc) as drank from cte)
select * from cte1 where drank <= 3;


select *,
case
 when unit="Billions" then revenue*1000
 when unit="Thousands" then round(revenue/1000,2)
 else revenue
end as revenue_mln
 from financials;
 
select m.title,f.budget,f.revenue from movies m
inner join financials f
using (movie_id);