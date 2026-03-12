CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    cc_num BIGINT UNIQUE,
    first_name TEXT,
    last_name TEXT,
    gender TEXT,
    dob DATE,
    job TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    zip TEXT,
    lat NUMERIC,
    long NUMERIC,
    city_pop INT
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(client_id),
    account_type TEXT DEFAULT 'credit_card',
    opened_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE transactions (
    transaction_id TEXT PRIMARY KEY, -- using trans_num
    account_id INT REFERENCES accounts(account_id),
    transaction_date TIMESTAMP,
    amount NUMERIC(12,2),
    merchant TEXT,
    merchant_category TEXT,
    merchant_lat NUMERIC,
    merchant_long NUMERIC,
    is_fraud BOOLEAN
);

CREATE TABLE transactions_staging (
    trans_date_trans_time TIMESTAMP,
    cc_num BIGINT,
    merchant TEXT,
    category TEXT,
    amt NUMERIC(12,2),
    first TEXT,
    last TEXT,
    gender TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    zip INT,
    lat DOUBLE PRECISION,
    long DOUBLE PRECISION,
    city_pop INT,
    job TEXT,
    dob DATE,
    trans_num TEXT,
    unix_time BIGINT,
    merch_lat DOUBLE PRECISION,
    merch_long DOUBLE PRECISION,
    is_fraud BOOLEAN
);


INSERT INTO clients (
    cc_num, first_name, last_name, gender, dob,
    job, street, city, state, zip,
    lat, long, city_pop
)
SELECT DISTINCT
    cc_num,
    first,
    last,
    gender,
    dob,
    job,
    street,
    city,
    state,
    zip,
    lat,
    long,
    city_pop
FROM transactions_staging;

INSERT INTO accounts (client_id)
SELECT client_id FROM clients;

INSERT INTO transactions (
    transaction_id,
    account_id,
    transaction_date,
    amount,
    merchant,
    merchant_category,
    merchant_lat,
    merchant_long,
    is_fraud
)
SELECT
    t.trans_num,
    a.account_id,
    t.trans_date_trans_time,
    t.amt,
    t.merchant,
    t.category,
    t.merch_lat,
    t.merch_long,
    t.is_fraud
FROM transactions_staging t
JOIN clients c ON t.cc_num = c.cc_num
JOIN accounts a ON c.client_id = a.client_id;

SELECT * FROM transactions LIMIT 10
SELECT * FROM accounts LIMIT 10
SELECT * FROM clients LIMIT 10