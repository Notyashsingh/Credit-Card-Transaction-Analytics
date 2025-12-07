-- Table creation scripts for Credit Card Transactions Analysis

-- 1. Categories table
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100)
);

-- 2. Customers table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name VARCHAR(150),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    street VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    zipcode VARCHAR(20),
    latitude NUMERIC,
    longitude NUMERIC,
    city_population INTEGER,
    job VARCHAR(100),
    dob DATE,
    age INTEGER
);

-- 3. Date table
CREATE TABLE date_table (
    date_id DATE PRIMARY KEY,
    year INTEGER,
    quarter VARCHAR(5),
    month_number INTEGER,
    month_name VARCHAR(20),
    week_number INTEGER,
    day_of_week VARCHAR(20),
    is_weekend BOOLEAN
);

-- 4. Merchants table
CREATE TABLE merchants (
    merchant_id INTEGER PRIMARY KEY,
    merchant_name VARCHAR(150),
    category_id INTEGER,
    merchant_lat NUMERIC,
    merchant_long NUMERIC,
    merchant_zipcode VARCHAR(20)
);

-- 5. Transactions table
CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    merchant_id BIGINT,
    category_id BIGINT,
    transaction_date DATE,
    transaction_time TIME WITHOUT TIME ZONE,
    amount NUMERIC,
    is_fraud BOOLEAN
);


-- Indexes for performance optimization
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX idx_transactions_merchant_id ON transactions(merchant_id);
CREATE INDEX idx_transactions_category_id ON transactions(category_id);
CREATE INDEX idx_transactions_transaction_date ON transactions(transaction_date);

-- Foreign key constraints
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_customer
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_merchant
FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_category
FOREIGN KEY (category_id) REFERENCES categories(category_id);

ALTER TABLE merchants
ADD CONSTRAINT fk_merchants_category
FOREIGN KEY (category_id) REFERENCES categories(category_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_date
FOREIGN KEY (transaction_date) REFERENCES date_table(date_id);

-- Queries to verify table creation
-- 1. List all tables   
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- 2. Describe table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'transactions';

--Qeueries for Data Analysis

-- SECTION A — DATA QUALITY & SANITY CHECKS

--1) Row counts for each table

SELECT 'customers' AS table_name, COUNT(*) AS cnt FROM customers
UNION ALL SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'date_table', COUNT(*) FROM date_table
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;

-- Why: Quick inventory of table sizes.

--2 ) Null value count per column (transactions)

SELECT
  SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS txnid_null,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customerid_null,
  SUM(CASE WHEN merchant_id IS NULL THEN 1 ELSE 0 END) AS merchantid_null,
  SUM(CASE WHEN category_id IS NULL THEN 1 ELSE 0 END) AS categoryid_null,
  SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS amount_null,
  SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS date_null
FROM transactions;

-- Why: Find missing keys/measures.

--3) Count distinct customers, merchants, categories

SELECT 
  (SELECT COUNT(DISTINCT transaction_id) FROM transactions) AS distinct_transactions,
  (SELECT COUNT(DISTINCT customer_id) FROM transactions) AS distinct_customers,
  (SELECT COUNT(DISTINCT merchant_id) FROM transactions) AS distinct_merchants,
  (SELECT COUNT(DISTINCT category_id) FROM transactions) AS distinct_categories;


-- Why: Measure breadth of entities in transactions.

--4) Duplicate check for transaction_id

SELECT transaction_id, COUNT(*) AS cnt
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- Why: Ensure primary key uniqueness.

--5) Date range of transactions

SELECT MIN(transaction_date) AS min_date, MAX(transaction_date) AS max_date FROM transactions;


-- Why: Understand temporal coverage for trend windows.

--6) Count of fraudulent vs legitimate transactions

SELECT is_fraud, COUNT(*) AS cnt, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),2) AS pct
FROM transactions
GROUP BY is_fraud;


-- Why: Baseline fraud prevalence.

--7) Min, max, avg transaction amount

SELECT MIN(amount) AS min_amt, MAX(amount) AS max_amt, ROUND(AVG(amount)::numeric,2) AS avg_amt
FROM transactions;


-- Why: Understand distribution and outliers.

-- SECTION B — CORE BUSINESS METRICS (ESSENTIAL KPIs)

--1) Total revenue

SELECT SUM(amount) AS total_revenue FROM transactions;


-- Why: Primary top-line.

--2) Total number of transactions

SELECT COUNT(*) AS total_transactions FROM transactions;

-- Why: Volume metric.

--3)Average order value (AOV)

SELECT ROUND(SUM(amount)/NULLIF(COUNT(*),0),2) AS avg_order_value FROM transactions;


-- Why: Average spend per transaction.

--4) Revenue by month

SELECT DATE_TRUNC('month', transaction_date)::date AS month, SUM(amount) AS revenue
FROM transactions
GROUP BY 1 ORDER BY 1;


-- Why: Time series for trend analysis.

--5) Transactions by month

SELECT DATE_TRUNC('month', transaction_date)::date AS month, COUNT(*) AS txn_count
FROM transactions
GROUP BY 1 ORDER BY 1;


-- Why: Volume trend.

--6) Weekend vs weekday revenue

SELECT CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
       SUM(t.amount) AS revenue, COUNT(*) AS txn_count
FROM transactions t
JOIN date_table d ON t.transaction_date = d.date_id
GROUP BY 1;


--Why: Channel/time behavior.

--7) Peak transaction hour of the day

SELECT EXTRACT(HOUR FROM transaction_time)::int AS hour, COUNT(*) AS txn_count, SUM(amount) AS revenue
FROM transactions
GROUP BY 1 ORDER BY txn_count DESC LIMIT 10;


-- Why: Operational staffing and timing.

--8) Revenue by state / city

SELECT city, state, SUM(amount) AS revenue, COUNT(*) AS txn_count
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY city, state ORDER BY revenue DESC LIMIT 50;


-- Why: Geography-based prioritization.

-- SECTION C — CUSTOMER ANALYTICS

-- 1) Total customers vs active customers (last 90 days)

SELECT
  (SELECT COUNT(DISTINCT customer_id) FROM customers) AS total_customers,
  (
    SELECT COUNT(DISTINCT customer_id)
    FROM transactions
    WHERE transaction_date >= (
        SELECT MAX(transaction_date) FROM transactions
    ) - INTERVAL '90 days'
  ) AS active_90d;

-- Why: Engagement.
--Insight : 983 Total Customer vs 983 Active Customers (last 90 days of Data)

-- 2) Average revenue per customer

SELECT ROUND(AVG(customer_spend)::numeric,2) AS avg_rev_per_customer
FROM (
  SELECT customer_id, SUM(amount) AS customer_spend
  FROM transactions GROUP BY customer_id
) s;

-- Why: Monetization per user is 9800.032

-- 3) Top 10 customers by total spend

SELECT c.customer_id, c.full_name, SUM(t.amount) AS total_spend, COUNT(t.transaction_id) AS txn_count
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spend DESC LIMIT 10;

-- Why: Identify VIP customers.

/* "customer_id","full_name","total_spend","txn_count"
77,"Frank Foster","496961.98","6648"
39,"Gina Morrison","496233.99","6657"
45,"Christopher Luna","492917.44","6620"
34,"Jenna Brooks","490349.43","6601"
28,"Scott Martin","490257.57","6736"
12,"Theresa Blackwell","489057.10","6741"
10,"Melissa Aguilar","488096.89","6702"
76,"Mario Johns","487679.10","6695"
80,"Joseph Spencer","486648.80","6583"
29,"Brian Simpson","486073.14","6711"
*/


--4) Customer frequency (transactions per customer)

SELECT t.customer_id,
c.full_name, 
COUNT(*) AS frequency 
FROM transactions t
JOIN customers c 
ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.full_name
ORDER BY frequency DESC 
LIMIT 10;

-- Why: Repeat purchase behavior.
/*
"customer_id","full_name","frequency"
"70","Frank Anderson","6790"
"46","Carlos Chung","6759"
"44","Mary Juarez","6755"
"66","Susan Shah","6742"
"12","Theresa Blackwell","6741"
"28","Scott Martin","6736"
"98","Dylan Bonilla","6734"
"18","Nathan Thomas","6728"
"4","Jeremy White","6721"
"29","Brian Simpson","6711"
*/

--5) Customer recency (days since last transaction)

WITH maxdate AS (
  SELECT MAX(transaction_date) AS dt
  FROM transactions
)
SELECT 
  customer_id,
  EXTRACT(
    DAY FROM ((maxdate.dt + INTERVAL '1 day') - MAX(transaction_date))
  )::int AS recency_days
FROM transactions
CROSS JOIN maxdate
GROUP BY customer_id, maxdate.dt
ORDER BY recency_days;

--  Why: Recency

-- Count of customers by recency days

WITH maxdate AS (
  SELECT MAX(transaction_date) AS dt
  FROM transactions
),
recency AS (
  SELECT 
    customer_id,
    EXTRACT(
      DAY FROM ((maxdate.dt + INTERVAL '1 day') - MAX(transaction_date))
    )::int AS recency_days
  FROM transactions
  CROSS JOIN maxdate
  GROUP BY customer_id, maxdate.dt
)
SELECT 
  recency_days,
  COUNT(*) AS customer_count
FROM recency
GROUP BY recency_days
ORDER BY recency_days;

-- Why: Recency distribution.

/* 
"recency_days","customer_count"
1,"525"
2,"312"
3,"104"
4,"25"
5,"10"
6,"5"
7,"2"
*/  

--6) RFM segmentation (assign quintiles)

WITH maxdate AS (
  SELECT MAX(transaction_date) AS dt
  FROM transactions
),
rfm AS (
  SELECT 
    customer_id,
    EXTRACT(
      DAY FROM ((maxdate.dt + INTERVAL '1 day') - MAX(transaction_date))
    )::int AS recency,
    COUNT(*) AS frequency,
    SUM(amount) AS monetary
  FROM transactions
  CROSS JOIN maxdate
  GROUP BY customer_id, maxdate.dt
)
SELECT 
  customer_id,
  NTILE(5) OVER (ORDER BY recency ASC) AS r_quintile,
  NTILE(5) OVER (ORDER BY frequency DESC) AS f_quintile,
  NTILE(5) OVER (ORDER BY monetary DESC) AS m_quintile
FROM rfm
LIMIT 10;

-- Why: Customer segmentation for targeting.

/*
"customer_id","r_quintile","f_quintile","m_quintile"
"758",1,3,4
"425",1,1,2
"557",1,3,3
"779",1,3,5
"74",1,1,1
"864",1,3,5
"324",1,1,2
"793",1,5,4
"568",1,5,5
"776",1,3,3
*/

-- Average RFM values

WITH maxdate AS (
  SELECT MAX(transaction_date) AS dt
  FROM transactions
),
rfm AS (
  SELECT 
    customer_id,
    EXTRACT(
      DAY FROM ((maxdate.dt + INTERVAL '1 day') - MAX(transaction_date))
    )::int AS recency,
    COUNT(*) AS frequency,
    SUM(amount) AS monetary
  FROM transactions
  CROSS JOIN maxdate
  GROUP BY customer_id, maxdate.dt
),
rfm_quintiles AS (
  SELECT 
    customer_id,
    NTILE(5) OVER (ORDER BY recency ASC) AS r_quintile,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_quintile,
    NTILE(5) OVER (ORDER BY monetary DESC) AS m_quintile
  FROM rfm
)
SELECT
  ROUND(AVG(r_quintile), 2) AS avg_r_quintile,
  ROUND(AVG(f_quintile), 2) AS avg_f_quintile,
  ROUND(AVG(m_quintile), 2) AS avg_m_quintile
FROM rfm_quintiles;

-- Why: Benchmarking customer segments.:avg_r_quintile = 3,avg_f_quintile = 3,avg_m_quintile = 3

/*
"avg_r_quintile","avg_f_quintile","avg_m_quintile"
"3.00","3.00","3.00"
*/

--7) Identify churn-risk customers (no txns in last X days, X=90)

SELECT c.customer_id, c.full_name, MAX(t.transaction_date) AS last_txn
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name
HAVING MAX(t.transaction_date) < CURRENT_DATE - INTERVAL '90 days' OR MAX(t.transaction_date) IS NULL;

--OR

WITH maxdate AS (
    SELECT MAX(transaction_date::date) AS dt
    FROM transactions
)
SELECT 
    c.customer_id,
    c.full_name,
    MAX(t.transaction_date::date) AS last_txn,
    COALESCE(
        (maxdate.dt + INTERVAL '1 day') - MAX(t.transaction_date::date),
        NULL
    ) AS days_since_last_txn
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
CROSS JOIN maxdate
GROUP BY c.customer_id, c.full_name, maxdate.dt
ORDER BY days_since_last_txn DESC;

-- Why: Retention campaigns.

-- 8) Customer Lifetime Value estimate (simple)

WITH cust AS (
  SELECT customer_id, SUM(amount) AS total_spend, COUNT(*) AS txn_count
  FROM transactions GROUP BY customer_id
)
SELECT AVG(total_spend) AS avg_lifetime_value FROM cust;


-- Why: LTV proxy for prioritization.

/*
"avg_lifetime_value"
"92800.029399796541"
*/

--9) Category preference per customer (top category)

WITH ranked_spend AS (
    SELECT 
        customer_id,
        category_id,
        SUM(amount) AS spend,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY SUM(amount) DESC) AS rn
    FROM transactions
    GROUP BY customer_id, category_id
)
SELECT customer_id, category_id, spend
FROM ranked_spend
WHERE rn = 4;

-- category 8 : shopping_pos  (order 2>13>8)

WITH cust_cat AS (
  SELECT customer_id, category_id, SUM(amount) AS spend
  FROM transactions GROUP BY customer_id, category_id
)
SELECT customer_id, category_id, spend
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY spend DESC) AS rn
  FROM cust_cat
) t WHERE rn = 1;


-- Why: Personalization.

--10) Customer growth month-over-month (new customers)

WITH first_tx AS (
  SELECT customer_id, MIN(transaction_date) AS first_tx FROM transactions GROUP BY customer_id
)
SELECT DATE_TRUNC('month', first_tx)::date AS cohort_month, COUNT(*) AS new_customers
FROM first_tx GROUP BY 1 ORDER BY 1;


-- Why: Acquisition trends.
--"cohort_month","new_customers" "2019-01-01","983"



-- SECTION D — MERCHANT ANALYTICS

-- 1) Top merchants by revenue

SELECT m.merchant_id, m.merchant_name, SUM(t.amount) AS revenue, COUNT(t.transaction_id) AS txn_count
FROM transactions t JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name ORDER BY revenue DESC LIMIT 10;


-- Why: Key partners.

--2) Top merchants by transaction count

SELECT m.merchant_id, m.merchant_name, COUNT(*) AS txn_count
FROM transactions t JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name ORDER BY txn_count DESC LIMIT 50;

-- Why: Volume leaders.

/*
"merchant_id","merchant_name","revenue","txn_count"
148,"fraud_Kilback LLC","391078.15","4403"
141,"fraud_Bradtke PLC","302481.25","2552"
44,"fraud_Doyle Ltd","300971.37","2558"
67,"fraud_Hackett-Lueilwitz","300208.14","2568"
269,"fraud_Schumm, Bauch and Ondricka","299115.14","2512"
106,"fraud_Rau and Sons","298354.77","2490"
128,"fraud_Goodwin-Nitzsche","298083.31","2542"
49,"fraud_Pacocha-O'Reilly","297584.38","2549"
263,"fraud_Murray-Smitham","296982.73","2510"
21,"fraud_Bauch-Raynor","295721.20","2513"
*/

--3) Highest average order value by merchant

SELECT m.merchant_id, m.merchant_name, ROUND(AVG(t.amount)::numeric,2) AS avg_order
FROM transactions t JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name ORDER BY avg_order DESC LIMIT 10;

-- Why: High-ticket merchants.

/*
"merchant_id","merchant_name","avg_order"
612,"fraud_Boyer-Haley","165.65"
371,"fraud_Little-Gleichner","163.05"
526,"fraud_Monahan, Hermann and Johns","158.76"
679,"fraud_Champlin, Rolfson and Connelly","156.06"
599,"fraud_Eichmann, Hayes and Treutel","147.33"
352,"fraud_Kunze, Larkin and Mayert","141.45"
628,"fraud_Tillman LLC","135.53"
437,"fraud_Medhurst, Labadie and Gottlieb","134.03"
529,"fraud_Hackett Group","133.16"
608,"fraud_Reichel, Bradtke and Blanda","129.40"
*/

--4) Merchants with highest fraud rate

SELECT m.merchant_id, m.merchant_name,
  SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END) AS fraud_count,
  COUNT(*) AS total_txn,
  ROUND(100.0 * SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions t JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name
ORDER BY fraud_rate_pct DESC LIMIT 10;

-- Why: Risk management.

/*
"merchant_id","merchant_name","fraud_count","total_txn","fraud_rate_pct"
310,"fraud_Kozey-Boehm","48","1866","2.57"
105,"fraud_Herman, Treutel and Dickens","33","1300","2.54"
12,"fraud_Kerluke-Abshire","41","1838","2.23"
295,"fraud_Brown PLC","26","1176","2.21"
336,"fraud_Goyette Inc","42","1943","2.16"
219,"fraud_Terry-Huel","43","1996","2.15"
538,"fraud_Jast Ltd","42","1953","2.15"
320,"fraud_Schmeler, Bashirian and Price","41","1968","2.08"
346,"fraud_Boyer-Reichert","38","1908","1.99"
245,"fraud_Langworth, Boehm and Gulgowski","39","1969","1.98"
*/

--5) Merchant performance month-over-month

SELECT m.merchant_id, m.merchant_name, DATE_TRUNC('month', t.transaction_date)::date AS month, SUM(t.amount) AS revenue
FROM transactions t JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name, month ORDER BY m.merchant_id, month;

-- Why: Merchant growth/seasonality.

--6) Merchant category mix (category contribution per merchant)

SELECT m.merchant_id, m.merchant_name, c.category_name, SUM(t.amount) AS revenue, ROUND(100.0 * SUM(t.amount) / NULLIF(SUM(SUM(t.amount)) OVER (PARTITION BY m.merchant_id),0),2) AS pct_of_merchant
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
JOIN categories c ON t.category_id = c.category_id
GROUP BY m.merchant_id, m.merchant_name, c.category_name;

-- Why: Product mix.

--7) Identify inactive merchants (no transactions in last N days, N=90)

SELECT m.merchant_id, m.merchant_name
FROM merchants m
LEFT JOIN transactions t ON m.merchant_id = t.merchant_id
GROUP BY m.merchant_id, m.merchant_name
HAVING MAX(t.transaction_date) < MAX(t.transaction_date) - INTERVAL '90 days' OR MAX(t.transaction_date) IS NULL;

--OR

WITH last_txn AS (
    SELECT MAX(transaction_date) AS max_date
    FROM transactions
)
SELECT m.merchant_id, m.merchant_name
FROM merchants m
LEFT JOIN transactions t 
       ON m.merchant_id = t.merchant_id
CROSS JOIN last_txn
GROUP BY m.merchant_id, m.merchant_name, last_txn.max_date
HAVING MAX(t.transaction_date) < (last_txn.max_date - INTERVAL '90 days')
       OR MAX(t.transaction_date) IS NULL;

-- Why: Marketplace hygiene.

/* All active Merchants in the dataset */

-- SECTION E — CATEGORY INSIGHTS

--1) Revenue by category

SELECT c.category_id, c.category_name, SUM(t.amount) AS revenue, COUNT(*) AS txn_count
FROM transactions t JOIN categories c ON t.category_id = c.category_id
GROUP BY c.category_id, c.category_name ORDER BY revenue DESC;

-- Why: Category value.

/*
"category_id","category_name","revenue","txn_count"
2,"grocery_pos","14460822.38","123638"
8,"shopping_pos","9307993.61","116672"
7,"shopping_net","8625149.68","97543"
4,"gas_transport","8351732.29","131659"
14,"home","7173928.11","123115"
13,"kids_pets","6503680.16","113035"
3,"entertainment","6036678.56","94014"
1,"misc_net","5117709.26","63287"
5,"misc_pos","5009582.50","79655"
9,"food_dining","4672459.44","91461"
11,"health_fitness","4653108.02","85879"
12,"travel","4516721.68","40507"
10,"personal_care","4353450.53","90758"
6,"grocery_net","2439412.68","45452"
*/

--2) Transaction count by category

SELECT t.category_id,
c.category_name, 
COUNT(*) AS txn_count 
FROM transactions t
JOIN categories c
ON t.category_id = c.category_id
GROUP BY t.category_id, c.category_name
ORDER BY txn_count DESC;

-- Why: Demand.

/*
"category_id","category_name","txn_count"
"4","gas_transport","131659"
"2","grocery_pos","123638"
"14","home","123115"
"8","shopping_pos","116672"
"13","kids_pets","113035"
"7","shopping_net","97543"
"3","entertainment","94014"
"9","food_dining","91461"
"10","personal_care","90758"
"11","health_fitness","85879"
"5","misc_pos","79655"
"1","misc_net","63287"
"6","grocery_net","45452"
"12","travel","40507"
*/

--3) Highest fraud-prone categories

SELECT c.category_id, c.category_name,
  SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END) AS fraud_count,
  COUNT(*) AS total_txn,
  ROUND(100.0 * SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions t JOIN categories c ON t.category_id = c.category_id
GROUP BY c.category_id, c.category_name ORDER BY fraud_rate_pct DESC;


-- Why: Risk focus.

--4) Monthly trends per category

SELECT DATE_TRUNC('month', t.transaction_date)::date AS month, c.category_name, SUM(t.amount) AS revenue
FROM transactions t JOIN categories c ON t.category_id = c.category_id
GROUP BY 1,2 ORDER BY 1,2;


-- Why: Category seasonality.

--5) Category share of total business

SELECT c.category_name, SUM(t.amount) AS revenue, ROUND(100.0 * SUM(t.amount)/NULLIF((SELECT SUM(amount) FROM transactions),0),2) AS pct_of_total
FROM transactions t JOIN categories c ON t.category_id = c.category_id
GROUP BY c.category_name ORDER BY revenue DESC;


-- Why: Contribution analysis.

--6) Highest-growth categories (YoY or MoM)

-- Example: month over previous month percent growth
WITH monthly AS (
  SELECT DATE_TRUNC('month', transaction_date)::date AS month, category_id, SUM(amount) AS revenue
  FROM transactions GROUP BY 1,2
)
SELECT category_id, month,
  revenue,
  LAG(revenue) OVER (PARTITION BY category_id ORDER BY month) AS prev_revenue,
  ROUND(100.0 * (revenue - LAG(revenue) OVER (PARTITION BY category_id ORDER BY month)) / NULLIF(LAG(revenue) OVER (PARTITION BY category_id ORDER BY month),0),2) AS mom_pct_change
FROM monthly
ORDER BY month DESC;


-- Why: Growth opportunities.

--7) Ranking categories by average transaction amount

SELECT c.category_id, c.category_name, AVG(t.amount) AS avg_amount
FROM transactions t JOIN categories c ON t.category_id = c.category_id
GROUP BY c.category_id, c.category_name ORDER BY avg_amount DESC;


-- Why: High-ticket categories.

-- SECTION F — FRAUD INTELLIGENCE

--1) Fraud rate overall

SELECT SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS fraud_count, COUNT(*) AS total_txn,
ROUND(100.0 * SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions;


-- Why: Baseline risk metric.

--2) Fraud rate by month

SELECT DATE_TRUNC('month', transaction_date)::date AS month,
  SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS fraud_count,
  COUNT(*) AS total_txn,
  ROUND(100.0 * SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions GROUP BY 1 ORDER BY 1;


-- Why: Trend monitoring.

--3) Fraud rate by merchant

SELECT m.merchant_id, m.merchant_name,
  SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END) AS fraud_count,
  COUNT(*) AS total_txn,
  ROUND(100.0 * SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions t JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name ORDER BY fraud_rate_pct DESC;


-- Why: Merchant risk profiling.

--4) Fraud rate by category

SELECT c.category_id, c.category_name,
  SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END) AS fraud_count,
  COUNT(*) AS total_txn,
  ROUND(100.0 * SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions t JOIN categories c ON t.category_id = c.category_id
GROUP BY c.category_id, c.category_name ORDER BY fraud_rate_pct DESC;


-- Why: Category red flags.

--5) Fraud amount lost per month

SELECT DATE_TRUNC('month', transaction_date)::date AS month, SUM(amount) FILTER (WHERE is_fraud) AS fraud_loss
FROM transactions GROUP BY 1 ORDER BY 1;


-- Why: Financial impact.

--7) Top customers with most fraud cases

SELECT customer_id, COUNT(*) AS fraud_cases, SUM(amount) FILTER (WHERE is_fraud) AS fraud_amount
FROM transactions
WHERE is_fraud
GROUP BY customer_id ORDER BY fraud_cases DESC LIMIT 50;


-- Why: Investigate repeat offenders or victims.

--8) Top merchants involved in highest value fraud

SELECT merchant_id, SUM(amount) AS total_fraud_amount, COUNT(*) AS fraud_cases
FROM transactions WHERE is_fraud GROUP BY merchant_id ORDER BY total_fraud_amount DESC LIMIT 50;


-- Why: Prioritize merchant reviews.

--9) Time-of-day fraud patterns (fraud by hour)

SELECT EXTRACT(HOUR FROM transaction_time)::int AS hour,
  COUNT(*) FILTER (WHERE is_fraud) AS fraud_txn, COUNT(*) AS total_txn,
  ROUND(100.0 * COUNT(*) FILTER (WHERE is_fraud)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions GROUP BY hour ORDER BY hour;


-- Why: Operational fraud monitoring.

--10) Probability of fraud by transaction amount bucket

SELECT width_bucket(amount, 0, (SELECT MAX(amount) FROM transactions), 10) AS bucket,
  MIN(amount) AS bucket_min, MAX(amount) AS bucket_max,
  COUNT(*) AS total_txn,
  COUNT(*) FILTER (WHERE is_fraud) AS fraud_txn,
  ROUND(100.0 * COUNT(*) FILTER (WHERE is_fraud) / NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions
GROUP BY bucket ORDER BY bucket;


-- Why: Amount-risk correlation.

-- SECTION G — TIME-SERIES & TRENDS

--1) Month-over-month revenue growth

WITH monthly AS (
  SELECT DATE_TRUNC('month', transaction_date)::date AS month, SUM(amount) AS revenue
  FROM transactions GROUP BY 1
)
SELECT month, revenue,
  LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
  ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month),0),2) AS mom_pct_change
FROM monthly ORDER BY month;


-- Why: Growth momentum.

--2) Week-over-week transaction growth

WITH weekly AS (
  SELECT DATE_TRUNC('week', transaction_date)::date AS week, COUNT(*) AS txn_count
  FROM transactions GROUP BY 1
)
SELECT week, txn_count,
 LAG(txn_count) OVER (ORDER BY week) AS prev_week,
 ROUND(100.0 * (txn_count - LAG(txn_count) OVER (ORDER BY week)) / NULLIF(LAG(txn_count) OVER (ORDER BY week),0),2) AS wow_pct_change
FROM weekly ORDER BY week;


-- Why: Short-term trends.

--3 )Revenue moving average (3-month, 6-month)

SELECT month, revenue,
  ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS ma_3m,
  ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW),2) AS ma_6m
FROM (
  SELECT DATE_TRUNC('month', transaction_date)::date AS month, SUM(amount) AS revenue
  FROM transactions GROUP BY 1
) s ORDER BY month;


-- Why: Smooth volatility.

--4) Rolling 7-day fraud rate

SELECT day, fraud_count, total_txn,
  ROUND(100.0 * SUM(fraud_count) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) / NULLIF(SUM(total_txn) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),0),2) AS rolling_7d_fraud_rate
FROM (
  SELECT transaction_date::date AS day, COUNT(*) FILTER (WHERE is_fraud) AS fraud_count, COUNT(*) AS total_txn
  FROM transactions GROUP BY transaction_date::date
) d ORDER BY day;


-- Why: Short-term fraud spikes.

--5) Year-to-date (YTD) revenue

SELECT SUM(amount) FILTER (WHERE DATE_PART('year', transaction_date) = DATE_PART('year', CURRENT_DATE)) AS ytd_revenue;


-- Why: Current year performance.

--6) Quarter-to-date (QTD) revenue

SELECT SUM(amount) FILTER (WHERE DATE_TRUNC('quarter', transaction_date) = DATE_TRUNC('quarter', CURRENT_DATE)) AS qtd_revenue;


-- Why: Quarterly tracking.

-- SECTION H — ADVANCED SQL (CTEs, WINDOW FUNCTIONS)

--1) Ranking customers by spend (RANK / DENSE_RANK)

SELECT customer_id, total_spend,
  RANK() OVER (ORDER BY total_spend DESC) AS rank_spend,
  DENSE_RANK() OVER (ORDER BY total_spend DESC) AS dense_rank_spend
FROM (SELECT customer_id, SUM(amount) AS total_spend FROM transactions GROUP BY customer_id) s;


-- Why: Top-customer identification with ties handled.

--2) Ranking merchants by monthly performance

SELECT month, merchant_id, merchant_name, revenue,
  RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS month_rank
FROM (
  SELECT DATE_TRUNC('month', t.transaction_date)::date AS month, m.merchant_id, m.merchant_name, SUM(t.amount) AS revenue
  FROM transactions t JOIN merchants m ON t.merchant_id = m.merchant_id
  GROUP BY 1,2,3
) q ORDER BY month, month_rank;


-- Why: Monthwise winners.

--3) Cohort analysis (customer cohort by first transaction month, retention)

WITH first_tx AS (
  SELECT customer_id, DATE_TRUNC('month', MIN(transaction_date))::date AS cohort_month FROM transactions GROUP BY customer_id
),
activity AS (
  SELECT customer_id, DATE_TRUNC('month', transaction_date)::date AS activity_month FROM transactions
)
SELECT f.cohort_month, a.activity_month, COUNT(DISTINCT a.customer_id) AS active_customers
FROM first_tx f
JOIN activity a ON f.customer_id = a.customer_id
GROUP BY f.cohort_month, a.activity_month
ORDER BY f.cohort_month, a.activity_month;


-- Why: Retention and cohort LTV.

--4) First transaction date per customer

SELECT customer_id, MIN(transaction_date) AS first_txn FROM transactions GROUP BY customer_id;


-- Why: Onboarding timing.

--5) Repeat purchase rate (customers with >1 txn)

SELECT ROUND(100.0 * SUM(CASE WHEN cnt > 1 THEN 1 ELSE 0 END) / COUNT(*),2) AS repeat_customer_pct
FROM (SELECT customer_id, COUNT(*) AS cnt FROM transactions GROUP BY customer_id) s;


-- Why: Loyalty measure.

--6) Time gap between transactions per customer (LAG)

SELECT customer_id, transaction_id, transaction_date,
  EXTRACT(EPOCH FROM (transaction_date - LAG(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date)))/3600 AS hours_since_prev
FROM transactions
ORDER BY customer_id, transaction_date;


-- Why: Purchase cadence.

--7) Customer lifecycle analysis (LAG + LEAD example)

SELECT customer_id, transaction_id, transaction_date,
  LAG(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS prev_txn,
  LEAD(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS next_txn
FROM transactions;


-- Why: Behavior around events.

--8) Running total of revenue (window SUM)

SELECT transaction_date::date AS day, SUM(amount) AS day_revenue,
  SUM(SUM(amount)) OVER (ORDER BY transaction_date::date) AS cumulative_revenue
FROM transactions GROUP BY transaction_date::date ORDER BY day;


-- Why: Cumulative performance.

--9) Percent contribution of each category (percent of total)

SELECT category_id, SUM(amount) AS revenue,
  ROUND(100.0 * SUM(amount)/NULLIF((SELECT SUM(amount) FROM transactions),0),2) AS pct_of_total
FROM transactions GROUP BY category_id ORDER BY revenue DESC;


-- Why: Share analysis.

-- SECTION I — JOINS & RELATIONAL ANALYSIS

--1) Customer × Transaction join for full profile view (sample)

SELECT t.transaction_id, t.transaction_date, t.amount, c.customer_id, c.full_name, c.city, c.state
FROM transactions t JOIN customers c ON t.customer_id = c.customer_id
LIMIT 100;


--Why: Row-level context.

--2) Merchant × Category × Transaction multi-table join

SELECT t.transaction_id, t.amount, m.merchant_name, cat.category_name
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
JOIN categories cat ON t.category_id = cat.category_id
LIMIT 100;


-- Why: Enriched transaction-level view.

--3) Customer home state vs merchant state (in-state vs out-of-state spend)

SELECT t.transaction_id, c.customer_id, c.state AS cust_state, m.merchant_zipcode AS merchant_zip, m.merchant_id,
  CASE WHEN c.state = m.merchant_zipcode THEN 'In-state' ELSE 'Out-of-state' END AS in_state_flag
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN merchants m ON t.merchant_id = m.merchant_id
LIMIT 100;


-- Note: Adjust merchant location field matching.
-- Why: Local vs cross-region behavior.

--4) Revenue by customer–merchant pairs

SELECT customer_id, merchant_id, SUM(amount) AS revenue, COUNT(*) AS txn_count
FROM transactions GROUP BY customer_id, merchant_id ORDER BY revenue DESC LIMIT 100;


-- Why: Relationship strength.

--5) Fraud by customer–merchant pairs

SELECT customer_id, merchant_id, SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS fraud_cases, COUNT(*) AS total_txn
FROM transactions GROUP BY customer_id, merchant_id HAVING SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) > 0 ORDER BY fraud_cases DESC LIMIT 100;


-- Why: Suspicious pair detection.

-- SECTION J — BUSINESS READY SUMMARY TABLES / VIEWS

--1) Customer summary view

CREATE OR REPLACE VIEW customer_summary AS
SELECT c.customer_id, c.full_name, COUNT(t.transaction_id) AS txn_count,
       SUM(t.amount) AS total_spend, AVG(t.amount) AS avg_txn,
       MIN(t.transaction_date) AS first_txn, MAX(t.transaction_date) AS last_txn
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name;


-- Why: One-stop customer data for dashboards.

--2) Merchant performance view

CREATE OR REPLACE VIEW merchant_summary AS
SELECT m.merchant_id, m.merchant_name, COUNT(t.transaction_id) AS txn_count, SUM(t.amount) AS total_spend,
  AVG(t.amount) AS avg_txn, SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END) AS fraud_count
FROM merchants m
LEFT JOIN transactions t ON m.merchant_id = t.merchant_id
GROUP BY m.merchant_id, m.merchant_name;


-- Why: Dashboard-ready merchant metrics.

--3) Category dashboard view

CREATE OR REPLACE VIEW category_summary AS
SELECT cat.category_id, cat.category_name, COUNT(t.transaction_id) AS txn_count, SUM(t.amount) AS total_revenue,
  AVG(t.amount) AS avg_txn, SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END) AS fraud_count
FROM categories cat
LEFT JOIN transactions t ON cat.category_id = t.category_id
GROUP BY cat.category_id, cat.category_name;


-- Why: Category KPIs.

--4) Fraud summary view

CREATE OR REPLACE VIEW fraud_summary AS
SELECT DATE_TRUNC('month', t.transaction_date)::date AS month,
  SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END) AS fraud_count,
  SUM(t.amount) FILTER (WHERE t.is_fraud) AS fraud_loss,
  COUNT(*) AS total_txn,
  ROUND(100.0 * SUM(CASE WHEN t.is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS fraud_rate_pct
FROM transactions t
GROUP BY 1 ORDER BY 1;


-- Why: Time-based fraud monitoring.

--5) Master analytical view combining core metrics (one row)

CREATE OR REPLACE VIEW business_kpis AS
SELECT
  (SELECT COUNT(*) FROM transactions) AS total_txns,
  (SELECT SUM(amount) FROM transactions) AS total_revenue,
  (SELECT COUNT(DISTINCT customer_id) FROM customers) AS distinct_customers,
  (SELECT COUNT(DISTINCT merchant_id) FROM merchants) AS distinct_merchants,
  (SELECT ROUND(100.0 * SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) FROM transactions) AS fraud_rate_pct,
  (SELECT ROUND(SUM(amount)/NULLIF(COUNT(*),0),2) FROM transactions) AS avg_order_value;


-- Why: Executive snapshot for a dashboard card.

-- SECTION K — CLEAN PRESENTATION QUERIES FOR PORTFOLIO

--1) Top 5 insights (SQL comments + queries) 

-- Insight 1: 20% of customers contribute 34.26% of revenue (Pareto)

WITH cust AS (
  SELECT customer_id, SUM(amount) AS spend FROM transactions GROUP BY customer_id
), totals AS (
  SELECT SUM(spend) AS total_spend FROM cust
)
SELECT ROUND(100.0 * SUM(spend) / (SELECT total_spend FROM totals),2) AS pct_by_top_20
FROM (
  SELECT * FROM cust ORDER BY spend DESC LIMIT CEIL(0.2 * (SELECT COUNT(*) FROM cust))
) top20;

-- Why: Demonstrates concentration.

-- Insight 2: Fraud transactions spike during late-night hours ( Hour 23, 22, 1,  0, 2).

WITH hourly AS (
  SELECT 
      EXTRACT(HOUR FROM transaction_time::time) AS hr,
      COUNT(*) AS total_txn,
      SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS fraud_txn
  FROM transactions
  GROUP BY 1
)
SELECT 
    hr,
    fraud_txn,
    total_txn,
    ROUND(100.0 * fraud_txn / NULLIF(total_txn,0), 2) AS fraud_rate_pct
FROM hourly
ORDER BY fraud_rate_pct DESC
LIMIT 5;

-- Why: High-risk window)

-- Insight 3: Fraud Rate by Category

SELECT
    c.category_name,
    COUNT(*) FILTER (WHERE t.is_fraud) AS fraud_cases,
    COUNT(*) AS total_txn,
    ROUND(100.0 * COUNT(*) FILTER (WHERE t.is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
GROUP BY c.category_name
ORDER BY fraud_cases,total_txn,fraud_rate_pct DESC;

/* Fraud patterns are distributed across high-volume categories, with gas transport, shopping, groceries, and food & dining driving the largest fraud counts simply due to scale. However, categories like health, personal care, and online grocery show meaningfully higher fraud rates, indicating increased exposure for card-not-present channels. These categories warrant stricter monitoring and risk scoring. Meanwhile, the home category shows zero fraud activity, suggesting minimal exposure and limited attacker interest.*/

-- Why: Category risk profiling.

--Insight 4: Fraud Rate by State

SELECT
    cust.state,
    COUNT(*) FILTER (WHERE t.is_fraud) AS fraud_cases,
    COUNT(*) AS total_txn,
    ROUND(100.0 * COUNT(*) FILTER (WHERE t.is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions t
JOIN customers cust ON t.customer_id = cust.customer_id
GROUP BY cust.state
ORDER BY fraud_rate_pct DESC;

-- Why: Geographic fraud hotspots.

--Insight 5: Fraud Rate by Customer Segment (Age Groups)

SELECT
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 40 THEN '25–40'
        WHEN age BETWEEN 41 AND 60 THEN '41–60'
        ELSE '60+'
    END AS age_group,
    COUNT(*) FILTER (WHERE t.is_fraud) AS fraud_cases,
    COUNT(*) AS total_txn,
    ROUND(100.0 * COUNT(*) FILTER (WHERE t.is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY age_group
ORDER BY fraud_rate_pct DESC;

-- Why: Demographic risk insights.

--2) A “story query” (combined) — top customers, their top category, top merchant, and fraud exposure

WITH top_customers AS (
  SELECT customer_id, SUM(amount) AS total_spend FROM transactions GROUP BY customer_id ORDER BY total_spend DESC LIMIT 10
),
cust_top_cat AS (
  SELECT t.customer_id, t.category_id, SUM(t.amount) AS spend,
    ROW_NUMBER() OVER (PARTITION BY t.customer_id ORDER BY SUM(t.amount) DESC) AS rn
  FROM transactions t WHERE t.customer_id IN (SELECT customer_id FROM top_customers)
  GROUP BY t.customer_id, t.category_id
),
cust_top_merchant AS (
  SELECT t.customer_id, t.merchant_id, SUM(t.amount) AS spend,
    ROW_NUMBER() OVER (PARTITION BY t.customer_id ORDER BY SUM(t.amount) DESC) AS rn
  FROM transactions t WHERE t.customer_id IN (SELECT customer_id FROM top_customers)
  GROUP BY t.customer_id, t.merchant_id
)
SELECT tc.customer_id, tc.total_spend,
  c1.category_id AS top_category, cat.category_name,
  m1.merchant_id AS top_merchant, mer.merchant_name,
  SUM(t.is_fraud::int) FILTER (WHERE t.customer_id = tc.customer_id) AS fraud_cases
FROM top_customers tc
LEFT JOIN cust_top_cat c1 ON tc.customer_id = c1.customer_id AND c1.rn = 1
LEFT JOIN categories cat ON c1.category_id = cat.category_id
LEFT JOIN cust_top_merchant m1 ON tc.customer_id = m1.customer_id AND m1.rn = 1
LEFT JOIN merchants mer ON m1.merchant_id = mer.merchant_id
LEFT JOIN transactions t ON t.customer_id = tc.customer_id
GROUP BY tc.customer_id, tc.total_spend, c1.category_id, cat.category_name, m1.merchant_id, mer.merchant_name;

-- Why: Compact story linking top customers to categories, merchants, and fraud exposure.

--3) Final combined KPI query (single-row with many metrics)

SELECT
  (SELECT COUNT(*) FROM transactions) AS total_txns,
  (SELECT SUM(amount) FROM transactions) AS total_revenue,
  (SELECT ROUND(SUM(amount)/NULLIF(COUNT(*),0),2) FROM transactions) AS avg_transaction,
  (SELECT ROUND(100.0 * SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) FROM transactions) AS fraud_rate_pct,
  (SELECT COUNT(DISTINCT customer_id) FROM transactions) AS active_customers,
  (SELECT COUNT(DISTINCT merchant_id) FROM transactions) AS active_merchants,
  (SELECT category_name FROM categories WHERE category_id = (SELECT category_id FROM transactions GROUP BY category_id ORDER BY SUM(amount) DESC LIMIT 1)) AS best_category,
  (SELECT EXTRACT(HOUR FROM transaction_time)::int FROM transactions GROUP BY EXTRACT(HOUR FROM transaction_time) ORDER BY SUM(amount) DESC LIMIT 1) AS peak_hour;

-- Why: Executive summary with key metrics in one row.




