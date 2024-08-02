# SQL Business Reports

**Introduction:**  
Welcome to the SQL Business Reports repository. This project aims to solve specific business problems by generating essential reports using SQL. These reports are crucial for tracking sales performance, managing customer relationships, and strategic decision-making.

**Project Objective:**  
Develop SQL queries and stored procedures to generate various business reports, enabling product owners and executives to gain insights into sales performance, customer behavior, and market trends.

## Business Problems and Solutions

### 1. Individual Product Sales Report for Amazon India Customers (FY 2021)
**Problem Statement:**  
As a product owner, I want to generate a report of individual product sales (aggregated on a monthly basis at the product level) for Amazon India customers for FY=2021 so that I can track individual product sales and run further product analytics on it in Excel.

**SQL Query:**
```sql
SELECT 
    YEAR(sale_date) AS Fiscal_Year,
    MONTH(sale_date) AS Month,
    product_id,
    SUM(sales_amount) AS Total_Sales
FROM 
    sales
WHERE 
    customer_id IN (SELECT customer_id FROM customers WHERE customer_name = 'Amazon India')
    AND YEAR(sale_date) = 2021
GROUP BY 
    YEAR(sale_date), MONTH(sale_date), product_id
ORDER BY 
    Fiscal_Year, Month, product_id;
```
### 2. Gross monthly total sales report for Croma
**Problem Statement:**
As a product owner, I need an aggregate monthly gross sales report for Croma India customer so that I can track how much sales this particular customer is generating for Atliq and manage our relationship accordingly.The report should have the foloowing fields:
1. Month
2. Total gross sales to Croma India in this month

**SQL Query:**
```sql
SELECT
  s.date,
  SUM(g.gross_price*s.sold_quantity) as total_gross_price
FROM
  fact_sales_monthly s
JOIN
  fact_gross_price g
ON
  s.product_code = g.product_code AND g.fiscal_year=get_fiscal_year(s.date)
WHERE
  customer_code = 90002002
GROUP BY
  s.date
ORDER BY
  date asc;
```
### 3. Get Market Badge
**Problem Statement:**
Design a stored procedure that assigns a ‘Gold’ or ‘Silver’ badge to a market based on its total sales quantity. If the total sales quantity (total_sold_qty) for a market exceeds 5 million, the market should be considered as ‘Gold’. Otherwise, it should be considered as ‘Silver’. The procedure should be able to handle any exceptions and provide appropriate error messages.

**SQL Query:**
```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_market_badge`(
	in in_market varchar(20),
    in in_fiscal_year year,
    out out_badge varchar(10)
)
BEGIN
	declare qty int default 0;
    if in_market="" then
		set in_market = "India";
	end if;
	select sum(s.sold_quantity) into qty from fact_sales_monthly s
    join dim_customer c using (customer_code)
    where c.market=in_market and get_fiscal_year(s.date)=in_fiscal_year
    group by c.market;
    
    if qty > 5000000 then
		set out_badge = "Gold";
	else
		set out_badge = "Silver";
	end if;
END
```
### 4. Get top 'n' products in each division based on the qunatity sold
**Problem Statement:**
Design a stored procedure that retrieves the top ‘n’ products in each division based on the quantity sold in a specified fiscal year. This procedure will help the company to identify the most popular products in each division, which can inform strategic decisions such as inventory management, marketing campaigns, and sales forecasts.

**SQL Query:**
```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_top_n_products_each_division_by_quantity_sold`(
	in_fiscal_year int,
    in_top_n int
)
BEGIN
	with cte as (select p.division,p.product,sum(s.sold_quantity) as total_qty from fact_sales_monthly s
	join dim_product p using (product_code)
	where s.fiscal_year=in_fiscal_year
	group by p.division,p.product),

	cte1 as (select *, dense_rank() over(partition by division order by total_qty desc) as drank from cte)
	select * from cte1 where drank <= in_top_n;
END
```
### 5. Get top market, product, and customer based on net sales
**Problem Statement:**
Develop a report that provides a comprehensive view of the company’s financial performance for a given financial year. The report should include the top market, product, and customer based on net sales. The net sales should be represented in millions. This report will help the company to have a holistic view of its financial performance and take appropriate actions to address any potential issues.

**SQL Query:**
```sql
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `gdb0041`.`net_sales` AS
    SELECT 
        `gdb0041`.`sales_post_invoice_discount`.`date` AS `date`,
        `gdb0041`.`sales_post_invoice_discount`.`fiscal_year` AS `fiscal_year`,
        `gdb0041`.`sales_post_invoice_discount`.`customer_code` AS `customer_code`,
        `gdb0041`.`sales_post_invoice_discount`.`market` AS `market`,
        `gdb0041`.`sales_post_invoice_discount`.`product_code` AS `product_code`,
        `gdb0041`.`sales_post_invoice_discount`.`product` AS `product`,
        `gdb0041`.`sales_post_invoice_discount`.`variant` AS `variant`,
        `gdb0041`.`sales_post_invoice_discount`.`sold_quantity` AS `sold_quantity`,
        `gdb0041`.`sales_post_invoice_discount`.`total_gross_price` AS `total_gross_price`,
        `gdb0041`.`sales_post_invoice_discount`.`pre_invoice_discount_pct` AS `pre_invoice_discount_pct`,
        `gdb0041`.`sales_post_invoice_discount`.`net_invoice_sales` AS `net_invoice_sales`,
        `gdb0041`.`sales_post_invoice_discount`.`post_invoice_deduction` AS `post_invoice_deduction`,
        ROUND(((1 - `gdb0041`.`sales_post_invoice_discount`.`post_invoice_deduction`) * `gdb0041`.`sales_post_invoice_discount`.`net_invoice_sales`),
                2) AS `net_sales`
    FROM
        `gdb0041`.`sales_post_invoice_discount`
```
