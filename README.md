# PL/SQL Window Functions – Simba Supermarket Analysis

## Business Problem

### Business Context

Simba Supermarket Ltd, founded in 2007 by Mr. Teklay Teame, is one of Rwanda’s most prominent retail chains, offering a wide range of products including groceries, beverages, cosmetics, and household items. With multiple branches across Kigali and beyond, Simba serves both individual consumers and institutional clients such as NGOs and government ministries.

### Data Challenge

The beverages department at Simba Supermarket experiences seasonal fluctuations and regional purchasing differences. Management wants to analyze customer buying patterns to identify top-selling products, monitor monthly sales trends, and segment customers based on spending behavior.

### Expected Outcome

Generate actionable insights to:
- Identify top 5 beverage products per region and quarter.
- Track monthly sales performance and growth.
- Segment customers into quartiles for targeted promotions and loyalty programs.
  
---

## Database Schema

The analysis is based on three related tables:

| Table Name     | Description              | Key Columns                                           |
|----------------|--------------------------|--------------------------------------------------------|
| `customers`    | Customer information     | `customer_id (PK)`, `name`, `region`                  |
| `products`     | Beverage catalog         | `product_id (PK)`, `name`, `category`                 |
| `transactions` | Sales records            | `transaction_id (PK)`, `customer_id (FK)`, `product_id (FK)`, `sale_date`, `amount` |

<img width="575" height="425" alt="image" src="https://github.com/user-attachments/assets/15f4d738-f134-46f4-b553-a93a3d312e95" />


**Entity Relationship Diagram**  
<img width="601" height="561" alt="plsql_ERD" src="https://github.com/user-attachments/assets/59e3cd24-3228-42f1-ad56-8d187ba0d806" />

Note: Sample data were created and used.

<img width="519" height="595" alt="image" src="https://github.com/user-attachments/assets/8f4558f8-18c3-4e23-af49-dec9f0c8f12f" />

---

## Window Function Queries

### 1. Ranking Functions – Top Customers by Revenue

```sql
SELECT 
    customer_id,
    SUM(amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(amount) DESC) AS row_num,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) AS dense_rank_num,
    PERCENT_RANK() OVER (ORDER BY SUM(amount) DESC) AS percent_rank_num
FROM transactions
GROUP BY customer_id;
```

<img width="650" height="176" alt="image" src="https://github.com/user-attachments/assets/b89e0bc7-235d-43f4-8f4a-9b95dbd43c39" />


**Insight**:  
This query ranks customers based on total spending. It helps identify top spenders and understand how customers compare in terms of revenue.

---

### 2. Aggregate Functions – Running Totals & Trends

```sql
SELECT 
    customer_id,
    sale_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id 
        ORDER BY sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_rows,
    SUM(amount) OVER (
        PARTITION BY customer_id 
        ORDER BY sale_date 
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_range
FROM transactions;
```

<img width="560" height="276" alt="image" src="https://github.com/user-attachments/assets/2a898903-5a73-4fce-a7fd-d72c71ff2f56" />


**Insight**:  
This query shows how customer spending accumulates over time. Comparing ROWS vs RANGE reveals subtle differences in how totals are calculated.

---

### 3. Navigation Functions – Month-over-Month Growth

```sql
SELECT 
    customer_id,
    sale_date,
    amount,
    LAG(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) AS previous_amount,
    LEAD(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) AS next_amount,
    ROUND((amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY sale_date)) / 
          LAG(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) * 100, 2) AS growth_percent
FROM transactions;
```

<img width="600" height="279" alt="image" src="https://github.com/user-attachments/assets/719c5560-9460-464b-9749-7bd05f2f9691" />


**Insight**:  
This query compares each transaction to the previous one to calculate growth. It helps detect seasonal spikes and evaluate promotional impact.

---

### 4. Distribution Functions – Customer Segmentation

```sql
SELECT 
    customer_id,
    SUM(amount) AS total_revenue,
    NTILE(4) OVER (ORDER BY SUM(amount) DESC) AS revenue_quartile,
    CUME_DIST() OVER (ORDER BY SUM(amount) DESC) AS cumulative_distribution
FROM transactions
GROUP BY customer_id;
```

<img width="524" height="155" alt="image" src="https://github.com/user-attachments/assets/67229d09-d66a-4c6a-9dd3-fcbfd37c8609" />

**Insight**:  
This query segments customers into quartiles and shows their percentile rank. It supports targeted marketing and loyalty program design.

---

## Results Analysis

### 1. Descriptive – What Happened?
- Coffee Beans and Passion Juice were top sellers in Kigali and Huye.
- Customer spending peaked in Q2, especially in Kigali.

### 2. Diagnostic – Why?
- Promotions and regional preferences influenced product performance.
- Kigali customers showed consistent monthly growth, while Huye had seasonal spikes.

### 3. Prescriptive – What Next?
- Increase stock of top beverages in Kigali.
- Launch targeted campaigns for Huye during peak months.
- Reward top quartile customers with loyalty incentives.

---

## References

1. [Oracle PL/SQL Window Functions Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/Analytic-Functions.html) – Official guide to analytic and window functions in Oracle 23c.
3. [Simba Supermarket Online Shopping – About Us](https://www.simbaonlineshopping.com/AboutUs.aspx) – Company profile and product categories.
4. [Oracle SQL Developer User Guide](https://docs.oracle.com/en/database/oracle/sql-developer/23.1/index.html) – Reference for using SQL Developer effectively.
6. [SQL Window Function | How to write SQL Query using RANK, DENSE RANK, LEAD/LAG | SQL Queries Tutorial](https://www.youtube.com/watch?v=Ww71knvhQ-s&pp=ygUYcGwvc3FsIHdpbmRvd3MgZnVuY3Rpb25z0gcJCesJAYcqIYzv) – Beginner-friendly overview.
7. [SQL Window Functions | Advanced SQL](https://mode.com/sql-tutorial/sql-window-functions)

All sources were properly cited. Implementations and analysis represent original work. No AI-generated content was copied without attribution or adaptation.
