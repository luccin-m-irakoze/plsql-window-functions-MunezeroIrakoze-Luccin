--Customers table
CREATE TABLE customers(
customer_id NUMBER PRIMARY KEY ,
name VARCHAR2(100),
region VARCHAR2(50)
);

-- Products Table
CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    category VARCHAR2(50)
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    product_id NUMBER,
    sale_date DATE,
    amount NUMBER(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample data:
-- Customers
INSERT INTO customers VALUES (1001, 'John Doe', 'Kigali');
INSERT INTO customers VALUES (1002, 'Alice Uwase', 'Huye');
INSERT INTO customers VALUES (1003, 'Eric Nshimiyimana', 'Musanze');
INSERT INTO customers VALUES (1004, 'Diane Ingabire', 'Kigali');

-- Products
INSERT INTO products VALUES (2001, 'Coffee Beans', 'Beverages');
INSERT INTO products VALUES (2002, 'Passion Juice', 'Beverages');
INSERT INTO products VALUES (2003, 'Mineral Water', 'Beverages');
INSERT INTO products VALUES (2004, 'Soft Drink', 'Beverages');

-- Transactions
INSERT INTO transactions 
VALUES (3001, 1001, 2001, TO_DATE('2025-01-15', 'YYYY-MM-DD'), 25000);
INSERT INTO transactions 
VALUES (3002, 1002, 2002, TO_DATE('2025-02-10', 'YYYY-MM-DD'), 18000);
INSERT INTO transactions 
VALUES (3003, 1003, 2003, TO_DATE('2025-03-05', 'YYYY-MM-DD'), 12000);
INSERT INTO transactions 
VALUES (3004, 1001, 2004, TO_DATE('2025-03-20', 'YYYY-MM-DD'), 15000);
INSERT INTO transactions 
VALUES (3005, 1004, 2001, TO_DATE('2025-04-01', 'YYYY-MM-DD'), 22000);
INSERT INTO transactions 
VALUES (3006, 1002, 2003, TO_DATE('2025-04-15', 'YYYY-MM-DD'), 14000);
INSERT INTO transactions 
VALUES (3007, 1003, 2002, TO_DATE('2025-05-10', 'YYYY-MM-DD'), 16000);
INSERT INTO transactions 
VALUES (3008, 1004, 2004, TO_DATE('2025-06-01', 'YYYY-MM-DD'), 20000);
INSERT INTO transactions 
VALUES (3009, 1001, 2002, TO_DATE('2025-06-15', 'YYYY-MM-DD'), 17000);
INSERT INTO transactions 
VALUES (3010, 1002, 2001, TO_DATE('2025-07-05', 'YYYY-MM-DD'), 26000);

-- verifying if data was added properly
SELECT * FROM transactions; 

-- Rank customers by total revenue across all transactions
SELECT 
    customer_id,
    SUM(amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(amount) DESC) AS row_num,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) AS dense_rank_num,
    PERCENT_RANK() OVER (ORDER BY SUM(amount) DESC) AS percent_rank_num
FROM transactions
GROUP BY customer_id;

-- Monthly running total of sales using ROWS and RANGE
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

-- Compare each transaction to the previous one for growth analysis
SELECT 
    customer_id,
    sale_date,
    amount,
    LAG(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) AS previous_amount,
    LEAD(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) AS next_amount,
    ROUND((amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY sale_date)) / 
          LAG(amount) OVER (PARTITION BY customer_id ORDER BY sale_date) * 100, 2) AS growth_percent
FROM transactions;

-- Segment customers into quartiles based on total revenue
SELECT 
    customer_id,
    SUM(amount) AS total_revenue,
    NTILE(4) OVER (ORDER BY SUM(amount) DESC) AS revenue_quartile,
    CUME_DIST() OVER (ORDER BY SUM(amount) DESC) AS cumulative_distribution
FROM transactions
GROUP BY customer_id;