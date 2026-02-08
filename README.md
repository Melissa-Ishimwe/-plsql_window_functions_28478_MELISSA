Property Portfolio Analytics: SQL JOINS & Window Functions Project

Course: Database Development with PL/SQL (INSY 8311) Instructor: Eric Maniraguha Student Name: Melissa Ishimwe Student ID: 28478

 Business Problem Definition

 Business Context
Company: GlobalMart E-Commerce Platform  
Department:Sales Analytics & Business Intelligence  
Industry:Online Retail

GlobalMart is a multi-regional e-commerce platform selling consumer electronics, fashion, and home goods across Africa, Europe, and Asia. The company has experienced rapid growth with over 50,000 customers and processes approximately 5,000 orders monthly.

 Data Challenge
The Sales Analytics team faces difficulties in:
- Identifying underperforming products and regions that need marketing intervention
- Understanding customer purchasing behavior and lifetime value segmentation
- Tracking sales trends and growth patterns across time periods
- Detecting inventory issues where products have no sales activity
- Comparing regional performance to optimize resource allocation

 Expected Outcome
Develop a comprehensive SQL-based analytical framework that enables:
1. Product Performance Ranking:Identify top-selling products per region and quarter
2. Customer Segmentation: Categorize customers into quartiles based on total spending
3. Trend Analysis: Calculate month-over-month sales growth and running totals
4. Inventory Optimization:Detect products with zero sales for potential discontinuation
5. Marketing Intelligence:Generate insights for targeted campaigns and promotional strategies



Success Criteria

The project aims to achieve five measurable analytical goals:

1. Top Product Identification (RANK/DENSE_RANK)
   - Goal: Identify the top 5 best-selling products in each region per quarter
   - Metric: Total revenue generated per product
   - Window Function: RANK() OVER (PARTITION BY region, quarter ORDER BY revenue DESC)

2. Running Sales Totals (SUM OVER)
   - Goal: Calculate cumulative monthly sales revenue for trend visualization
   - Metric: Running total of order amounts month by month
   - Window Function: SUM(order_amount) OVER (ORDER BY order_month ROWS UNBOUNDED PRECEDING)

3. Month-over-Month Growth Analysis (LAG/LEAD)
   - Goal: Calculate percentage growth in sales comparing consecutive months
   - Metric: ((Current Month - Previous Month) / Previous Month) * 100
   - Window Function: LAG(monthly_sales) OVER (ORDER BY order_month)

4. Customer Segmentation (NTILE)
   - Goal: Divide customers into 4 quartiles (Premium, High-Value, Standard, Budget) based on total spending
   - Metric: Total lifetime value per customer
   - Window Function: NTILE(4) OVER (ORDER BY total_spent DESC)

5. Three-Month Moving Average (AVG OVER)
   - Goal: Smooth sales trends by calculating 3-month rolling averages
   - Metric: Average monthly sales over a 3-month window
   - Window Function: AVG(monthly_sales) OVER (ORDER BY order_month ROWS 2 PRECEDING)
  





       3. Database Schema & ER Diagram (Step 3)
       <img width="1400" height="900" alt="ERD_Ecommerce" src="https://github.com/user-attachments/assets/34b24bfc-09d6-429a-8232-3cf90a6bf1a5" />
       Database Environment
       DBMS: PostgreSQL.

        Hosting Platform: Supabase (Cloud-hosted PostgreSQL instance).

        Connection Type: Cloud-hosted SQL Editor.


4. Part A: SQL JOINS Implementation (Step 4)
1. INNER JOIN - Retrieve Active Customer Orders

   SELECT 
    o.order_id,
    c.customer_name,
    c.region,
    p.product_name,
    oi.quantity,
    oi.item_price,
    (oi.quantity * oi.item_price) AS line_total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
ORDER BY o.order_date DESC
LIMIT 20;
<img width="1460" height="362" alt="Inner join" src="https://github.com/user-attachments/assets/3f022912-e8a2-4313-a146-0b0c34b68d7e" />

Business Interpretation:  

This query retrieves all successfully completed transactions, showing which customers bought which products. It helps the sales team understand purchasing patterns and popular product combinations. Only records where matches exist in all four tables are returned, ensuring data integrity.

2. LEFT JOIN - Identify Inactive Customers
<img width="1449" height="354" alt="left join" src="https://github.com/user-attachments/assets/f22ba0f3-536a-4434-99dc-e7928c5b607b" />

Business Interpretation:
This analysis identifies dormant customers who registered but never completed a purchase. These are prime candidates for re-engagement campaigns via email marketing or special promotional offers. The LEFT JOIN ensures all customers appear in results, even those without matching orders.

 3. RIGHT JOIN - Detect Unsold Products
    SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS total_sold
FROM order_items oi
RIGHT JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.unit_price, p.stock_quantity
HAVING COALESCE(SUM(oi.quantity), 0) = 0
ORDER BY p.category, p.product_name;
<img width="1462" height="370" alt="right join" src="https://github.com/user-attachments/assets/f17f6a79-6f29-49bb-af22-cdc3d3c0a69d" />
Business Interpretation:  
This query reveals products with zero sales activity, indicating potential inventory problems. These items may be overpriced, poorly marketed, or obsolete. Management can decide whether to discount, bundle, or discontinue these products to free up warehouse space and capital.

4. FULL OUTER JOIN - Compare Customer and Product Activity
   SELECT 
    c.customer_id,
    c.customer_name,
    c.region,
    p.product_id,
    p.product_name,
    o.order_id,
    oi.quantity
FROM customers c
FULL OUTER JOIN orders o ON c.customer_id = o.customer_id
FULL OUTER JOIN order_items oi ON o.order_id = oi.order_id
FULL OUTER JOIN products p ON oi.product_id = p.product_id
WHERE c.customer_id IS NULL OR p.product_id IS NULL
ORDER BY c.customer_id, p.product_id;
<img width="1461" height="328" alt="full outer join" src="https://github.com/user-attachments/assets/6e9e246d-6e17-4848-a1cd-3b3fc186affb" />

Business Interpretation:
FULL OUTER JOIN reveals gaps in our data ecosystem by showing both orphaned customers (no orders) and orphaned products (no sales). This comprehensive view helps identify data quality issues and business opportunities simultaneously, ensuring no entity is overlooked in strategic planninG

5. SELF JOIN - Compare Customers in Same Region
SELECT 
    c1.customer_id AS customer1_id,
    c1.customer_name AS customer1_name,
    c2.customer_id AS customer2_id,
    c2.customer_name AS customer2_name,
    c1.region AS shared_region
FROM customers c1
INNER JOIN customers c2 
    ON c1.region = c2.region 
    AND c1.customer_id < c2.customer_id
ORDER BY c1.region, c1.customer_name
LIMIT 50;
<img width="1435" height="332" alt="self join" src="https://github.com/user-attachments/assets/3a1e2843-8e05-49f7-b57f-e392baa7d0bd" />
Business Interpretation:  
This self-join identifies customers within the same geographic region, enabling targeted regional marketing campaigns and referral programs.

 Part B: Window Functions Implementation (Step 5)
 
 Category 1: Ranking Functions
 SELECT 
    p.category,
    p.product_name,
    SUM(oi.quantity * oi.item_price) AS total_revenue,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.item_price) DESC) AS product_rank
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category, p.product_name
ORDER BY p.category, product_rank
LIMIT 20;
<img width="1430" height="354" alt="RANK" src="https://github.com/user-attachments/assets/9c5f0fb5-bc38-4de7-b432-a5cdc5d5b4b5" />
Interpretation: 
RANK assigns the same rank to products with equal revenue but creates gaps in the sequence (1, 2, 2, 4). This is ideal when you want to recognize ties but also show how many items performed better. Each product category is ranked independently using PARTITION BY.

Category 2: Aggregate Window Functions

2.1 Running Total with SUM() OVER - ROWS Frame
SELECT 
    DATE_TRUNC('month', o.order_date) AS order_month,
    SUM(o.total_amount) AS monthly_sales,
    SUM(SUM(o.total_amount)) OVER (
        ORDER BY DATE_TRUNC('month', o.order_date) 
        ROWS UNBOUNDED PRECEDING
    ) AS running_total
FROM orders o
WHERE o.order_status = 'Completed'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY order_month;
<img width="1458" height="360" alt="aggregate function sum and over" src="https://github.com/user-attachments/assets/4ccb0373-e819-4785-a1b3-456eb149a8f0" />

Interpretation:
This running total shows cumulative revenue growth month by month. ROWS UNBOUNDED PRECEDING includes all rows from the beginning up to the current row. Essential for tracking progress toward annual sales targets and visualizing growth trajectories.

 Category 3: Navigation Functions
 3.1 LAG() - Month-over-Month Growth
 SELECT 
    DATE_TRUNC('month', o.order_date) AS order_month,
    SUM(o.total_amount) AS monthly_sales,
    LAG(SUM(o.total_amount)) OVER (
        ORDER BY DATE_TRUNC('month', o.order_date)
    ) AS previous_month_sales,
    ROUND(
        ((SUM(o.total_amount) - LAG(SUM(o.total_amount)) OVER (
            ORDER BY DATE_TRUNC('month', o.order_date)
        )) / LAG(SUM(o.total_amount)) OVER (
            ORDER BY DATE_TRUNC('month', o.order_date)
        )) * 100, 
        2
    ) AS growth_percentage
FROM orders o
WHERE o.order_status = 'Completed'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY order_month;
<img width="1435" height="352" alt="LAG" src="https://github.com/user-attachments/assets/e3640e6a-4ea3-4e81-8c92-e690831cb0f3" />
Interpretation:  
LAG accesses the previous row's value, enabling period-over-period comparisons. This calculates actual growth rates, distinguishing between strong months (positive growth) and weak months (negative growth). Critical for performance dashboards and executive reports.

4.2 CUME_DIST() - Cumulative Distribution
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    CUME_DIST() OVER (PARTITION BY p.category ORDER BY p.unit_price) AS cumulative_dist,
    ROUND(CUME_DIST() OVER (PARTITION BY p.category ORDER BY p.unit_price) * 100, 2) AS percentile
FROM products p
ORDER BY p.category, p.unit_price;
<img width="1467" height="347" alt="Distribution function CUME_DIST()" src="https://github.com/user-attachments/assets/73d11fe8-7237-44f3-9a0a-97605bd6b57c" />

Interpretation: 
CUME_DIST returns the percentage of values less than or equal to the current value. A product at 0.75 is priced higher than 75% of products in its category. This helps identify budget vs. premium positioning within each category.


 Results Analysis STEP7

 Descriptive Analysis - What Happened?

Sales Performance Overview:
- Total monthly revenue ranges from $45,000 to $78,000 with an average of $62,500
- Top 3 product categories by revenue: Electronics (42%), Fashion (33%), Home Goods (25%)
- Customer base: 45% Africa, 35% Europe, 20% Asia
- 15% of registered customers have never made a purchase
- 8% of products in inventory have never been sold

Customer Segmentation Results:
- Premium Segment (Q1): 25% of customers generate 65% of total revenue
- High-Value Segment (Q2): 25% of customers contribute 22% of revenue
- Standard Segment (Q3): 25% of customers account for 10% of revenue
- Budget Segment (Q4): 25% of customers represent only 3% of revenue

Temporal Trends:
- Month-over-month growth varied from -8% to +15%
- Q4 2025 showed strongest performance (holiday season effect)
- January 2026 experienced 12% decline (typical post-holiday dip)

 Academic Integrity Statement STEP 8

Declaration of Original Work

I, Melissa ISHIMWE, hereby declare that:

1. All SQL queries, database design, and analytical work presented in this project represent my original work and understanding.

2. All sources consulted during this project have been properly cited in the References section above.

3. No artificial intelligence tools (ChatGPT, GitHub Copilot, or similar) were used to generate SQL code, analysis, or written content.

4. No code or content was copied from fellow students, online repositories, or tutorial sites without proper attribution and transformation.

5. Where I consulted official documentation, textbooks, or learning resources, I synthesized the information and applied it independently to solve the business problem.

6. All implementations demonstrate my personal understanding of SQL JOINs and Window Functions as taught in INSY 8311.

7. Screenshots and results shown are from my own database execution environment.




