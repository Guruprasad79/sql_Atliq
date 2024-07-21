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

### 2. Gross monthly total sales report for Croma
**Problem Statement:**  
As a product owner, I need an aggregate monthly gross sales report for Croma India custoer so that I can track how much sales this particular customer is generating for Atliq and manage our relationship accordingly.
The report should have the following fields:
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
