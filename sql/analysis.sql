--1. Client Segmentation
-- Total transaction volume per client
-- Average transaction amount per client
-- Ranked clients by transaction volume
WITH CLIENT_METRICS AS 
  (
    SELECT C.client_id, C.first_name, 
    COUNT(transaction_id) AS TOTAL_TXS, 
    SUM(T.AMOUNT) AS TOTAL, 
    AVG(T.AMOUNT) AS avg
    FROM clients c
    LEFT JOIN accounts a ON A.client_id = C.client_id
    LEFT JOIN transactions T ON A.account_id = T.account_id
    GROUP BY C.client_id, C.first_name
  )
SELECT client_id, first_name, TOTAL_TXS, TOTAL, ROUND(AVG,2) as average,
  DENSE_RANK() OVER(ORDER BY TOTAl DESC) as volume_rank
FROM CLIENT_METRICS;


--2. Risk Detection
WITH TOP_PERCENTILE AS (
  SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount) AS percentile
  FROM transactions
),
HIGH_VELOCITY AS (
  SELECT account_id,
         DATE_TRUNC('HOUR', transaction_date) AS hour,
         COUNT(transaction_id) AS tx_count
  FROM transactions
  GROUP BY account_id, DATE_TRUNC('HOUR', transaction_date)
  HAVING COUNT(transaction_id) > 5
)
SELECT t.transaction_id,
       t.account_id,
       a.client_id,
       t.amount,
       CASE WHEN t.amount > tp.percentile THEN 1 ELSE 0 END AS large_amount_flag,
       CASE WHEN hv.account_id IS NOT NULL THEN 1 ELSE 0 END AS high_velocity_flag,
       (CASE WHEN t.amount > tp.percentile THEN 1 ELSE 0 END +
        CASE WHEN hv.account_id IS NOT NULL THEN 1 ELSE 0 END) AS risk_score,
       CASE
         WHEN (CASE WHEN t.amount > tp.percentile THEN 1 ELSE 0 END +
               CASE WHEN hv.account_id IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN 'Low'
         WHEN (CASE WHEN t.amount > tp.percentile THEN 1 ELSE 0 END +
               CASE WHEN hv.account_id IS NOT NULL THEN 1 ELSE 0 END) = 1 THEN 'Medium'
         ELSE 'High'
       END AS risk_level
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
CROSS JOIN TOP_PERCENTILE tp
LEFT JOIN HIGH_VELOCITY hv
  ON hv.account_id = t.account_id
  AND hv.hour = DATE_TRUNC('HOUR', t.transaction_date)
WHERE t.amount > tp.percentile
   OR hv.account_id IS NOT NULL;

--3. Create Client-Risk view
DROP VIEW IF EXISTS client_risk_summary;

CREATE VIEW client_risk_summary AS
WITH TOP_PERCENTILE AS (
  SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount) AS percentile
  FROM transactions
),
HIGH_VELOCITY AS (
  SELECT account_id,
         DATE_TRUNC('HOUR', transaction_date) AS hour,
         COUNT(transaction_id) AS tx_count
  FROM transactions
  GROUP BY account_id, DATE_TRUNC('HOUR', transaction_date)
  HAVING COUNT(transaction_id) > 5
),
TRANSACTION_FLAGS AS (
  SELECT t.transaction_id,
         t.account_id,
         a.client_id,
         t.amount,
         CASE WHEN t.amount > tp.percentile THEN 1 ELSE 0 END AS large_amount_flag,
         CASE WHEN hv.account_id IS NOT NULL THEN 1 ELSE 0 END AS high_velocity_flag
  FROM transactions t
  JOIN accounts a ON a.account_id = t.account_id
  CROSS JOIN TOP_PERCENTILE tp
  LEFT JOIN HIGH_VELOCITY hv
    ON hv.account_id = t.account_id
   AND hv.hour = DATE_TRUNC('HOUR', t.transaction_date)
)
SELECT client_id,
       COUNT(transaction_id) AS total_transactions,
       ROUND(AVG(amount), 2) AS avg_amount,
       SUM(large_amount_flag) AS large_amount_count,
       SUM(high_velocity_flag) AS high_velocity_count,
       (CASE WHEN SUM(large_amount_flag) > 0 THEN 1 ELSE 0 END +
        CASE WHEN SUM(high_velocity_flag) > 0 THEN 1 ELSE 0 END) AS risk_score,
       CASE
         WHEN (CASE WHEN SUM(large_amount_flag) > 0 THEN 1 ELSE 0 END +
               CASE WHEN SUM(high_velocity_flag) > 0 THEN 1 ELSE 0 END) = 0 THEN 'Low'
         WHEN (CASE WHEN SUM(large_amount_flag) > 0 THEN 1 ELSE 0 END +
               CASE WHEN SUM(high_velocity_flag) > 0 THEN 1 ELSE 0 END) = 1 THEN 'Medium'
         ELSE 'High'
       END AS risk_level
FROM TRANSACTION_FLAGS
GROUP BY client_id;