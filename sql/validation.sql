-- 1. Null / missing-value profile
-- transactions
SELECT
    COUNT(*) FILTER (WHERE transaction_id IS NULL) AS null_transaction_id,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS null_account_id,
    COUNT(*) FILTER (WHERE transaction_date IS NULL) AS null_transaction_date,
    COUNT(*) FILTER (WHERE amount IS NULL) AS null_amount,
    COUNT(*) FILTER (WHERE merchant IS NULL OR merchant = '') AS null_or_blank_merchant,
    COUNT(*) FILTER (WHERE merchant_category IS NULL OR merchant_category = '') AS null_or_blank_category,
    COUNT(*) FILTER (WHERE merchant_lat IS NULL) AS null_merchant_lat,
    COUNT(*) FILTER (WHERE merchant_long IS NULL) AS null_merchant_long
FROM transactions;

-- clients
SELECT
    COUNT(*) FILTER (WHERE client_id IS NULL) AS null_client_id,
    COUNT(*) FILTER (WHERE cc_num IS NULL) AS null_cc_num,
    COUNT(*) FILTER (WHERE first_name IS NULL OR first_name = '') AS null_or_blank_first_name,
    COUNT(*) FILTER (WHERE last_name IS NULL OR last_name = '') AS null_or_blank_last_name,
    COUNT(*) FILTER (WHERE dob IS NULL) AS null_dob,
    COUNT(*) FILTER (WHERE city IS NULL OR city = '') AS null_or_blank_city,
    COUNT(*) FILTER (WHERE lat IS NULL) AS null_home_lat,
    COUNT(*) FILTER (WHERE long IS NULL) AS null_home_long
FROM clients;

-- accounts
SELECT
    COUNT(*) FILTER (WHERE account_id IS NULL) AS null_account_id,
    COUNT(*) FILTER (WHERE client_id IS NULL) AS null_client_id,
    COUNT(*) FILTER (WHERE account_type IS NULL OR account_type = '') AS null_or_blank_account_type,
    COUNT(*) FILTER (WHERE opened_date IS NULL) AS null_opened_date
FROM accounts;

-- 2. Duplicate primary keys: transaction IDs should be unique.
SELECT transaction_id, COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Potential business duplicates: same account, timestamp, amount, and merchant.
SELECT account_id, transaction_date, amount, merchant, COUNT(*) AS duplicate_count
FROM transactions
GROUP BY account_id, transaction_date, amount, merchant
HAVING COUNT(*) > 1;

-- 3. Foreign-key integrity: orphan transactions.
SELECT COUNT(*) AS orphan_transactions
FROM transactions t
LEFT JOIN accounts a ON a.account_id = t.account_id
WHERE a.account_id IS NULL;

SELECT t.transaction_id, t.account_id
FROM transactions t
LEFT JOIN accounts a ON a.account_id = t.account_id
WHERE a.account_id IS NULL
ORDER BY t.transaction_id;

-- Foreign-key integrity: orphan accounts.
SELECT COUNT(*) AS orphan_accounts
FROM accounts a
LEFT JOIN clients c ON c.client_id = a.client_id
WHERE c.client_id IS NULL;

SELECT a.account_id, a.client_id
FROM accounts a
LEFT JOIN clients c ON c.client_id = a.client_id
WHERE c.client_id IS NULL
ORDER BY a.account_id;

-- 4. Business-rule checks: transaction amounts and dates.
SELECT
    COUNT(*) FILTER (WHERE amount < 0) AS negative_amounts,
    COUNT(*) FILTER (WHERE amount = 0) AS zero_amounts,
    COUNT(*) FILTER (WHERE transaction_date > CURRENT_TIMESTAMP) AS future_dated_transactions
FROM transactions;

SELECT t.transaction_id, t.account_id, t.transaction_date, a.opened_date
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
WHERE t.transaction_date::date < a.opened_date
ORDER BY t.transaction_date;

-- 4 Account and client date quality checks.
SELECT COUNT(*) FILTER (WHERE opened_date > CURRENT_DATE) AS future_open_dates
FROM accounts;

SELECT
    COUNT(*) FILTER (WHERE dob > CURRENT_DATE) AS future_dobs,
    COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, dob)) < 18) AS under_18_clients,
    COUNT(*) FILTER (WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, dob)) > 100) AS over_100_clients
FROM clients
WHERE dob IS NOT NULL;

-- 5. Statistical outliers: transactions above mean + 3 * stddev.
WITH transaction_stats AS (
    SELECT AVG(amount) AS avg_amount, STDDEV_SAMP(amount) AS std_amount
    FROM transactions
    WHERE amount IS NOT NULL
)
SELECT
    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,
    ROUND(s.avg_amount::numeric, 2) AS dataset_avg_amount,
    ROUND((s.avg_amount + 3 * s.std_amount)::numeric, 2) AS three_sigma_threshold
FROM transactions t
CROSS JOIN transaction_stats s
WHERE t.amount > s.avg_amount + 3 * s.std_amount
ORDER BY t.amount DESC;



