# Client Transaction Risk Analytics

This project is an end-to-end fraud-risk analytics workflow built on the “Client Transaction Risk Analytics” dataset. It takes raw transaction exports, cleans and samples them, materializes them into a Supabase/Postgres warehouse, adds derived features, validates the data, and surfaces client-level risk signals via SQL-backed analysis and visuals.

## Project Purpose

The goal is to show how transaction data can be prepared, enriched, and modeled to highlight clients with unusual behavior (large amounts, high velocity) so a downstream analyst or automated alerting system can prioritize investigations. The work illustrates ETL, SQL modeling, feature engineering, and exploratory visualization in a compact intern-style project.

## Flow Overview

1. **Cleaning stage** – `notebooks/clean_data.ipynb` reads `data/fraudTrain.csv` and `data/fraudTest.csv`, coerces datetimes/numerics/bools, concatenates, optionally samples 50%, and writes `data/transactions_clean.csv`. This cleaned asset feeds the warehouse load.
2. **Ingestion & validation** – `sql/table_creation.sql` defines `clients`, `accounts`, `transactions`, and `transactions_staging`, deduplicates clients/accounts, and loads transactions from the staging table; `sql/validation.sql` runs null/duplicate/orphan/business-rule and statistical outlier checks to certify the Postgres tables.
3. **Export to Supabase** – `notebooks/export_supabase.ipynb` batches the cleaned rows into Supabase so the warehouse tables back the analytics view.
4. **Feature engineering & EDA** – After the export, `notebooks/feature_engineering.ipynb` derives temporal (hour/day/month), demographic (age), and risk-related (off-hours flag, category weight) features, saving `data/transactions_features.csv`. The derived dataset plus `notebooks/eda.ipynb` support offline exploration that is not materialized in the warehouse.
5. **Risk summary & analysis** – `sql/analysis.sql` builds client-level metrics plus large-amount and high-velocity flags, exposing the summarized view `client_risk_summary`. `notebooks/risk_analysis.ipynb` connects to the warehouse, queries that view, plots risk-level distributions, and highlights the top high-risk clients for quick interpretation.

## Key Assets

- `data/`: raw and derived CSVs (`fraudTrain.csv`, `fraudTest.csv`, `transactions_clean.csv`, `transactions_features.csv`).
- `notebooks/`: cleaning, feature engineering, Supabase export, EDA, and risk-analysis notebooks.
- `sql/`: DDL + DML scripts that set up the warehouse/tables, validate the data, and define the risk summary view (including the client risk summary exposed to the notebooks).
- `.env` (local only): stores Supabase connection info for the notebooks and SQL clients that run against the hosted warehouse.

The combination of notebooks and SQL demonstrates how cleaned transaction data can transition into a modeled warehouse and inform client-level risk reporting.
