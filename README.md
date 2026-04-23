# Client Transaction Risk Analytics

### End-to-End Fraud Risk Analytics Pipeline on 1.5M+ Transactions

This project simulates how financial institutions identify potentially fraudulent customers using transaction behavior patterns. By engineering interpretable behavioral risk signals from 1.5M+ transactions, the pipeline prioritizes clients for investigation and demonstrates how analytics can improve fraud monitoring efficiency.

The system cleans, models, and analyzes transaction data within a PostgreSQL (Supabase) warehouse, generating client-level risk indicators based on transaction amount anomalies and unusual activity velocity.

---

### Live Dashboard  
[View Interactive Tableau Dashboard](https://public.tableau.com/app/profile/mohammed.s1243/viz/ClientTransactionRiskAnalyticsDashboard/Dashboard1?publish=yes)

## Dashboard Preview
![dashboard preview](https://github.com/MohammedSShaikh/client-transaction-risk-analytics/blob/main/dashboards/tableauDash.png)
---

## Risk Scoring Logic

Client risk is calculated using two interpretable behavioral indicators commonly used in rule-based fraud detection systems. 

#### Large Transaction Amount
Transactions above the **95th percentile** of all transaction values are flagged as unusually large relative to the population baseline.

#### High Transaction Velocity
Clients performing more than **5 transactions within one hour** are flagged for unusually high activity frequency, a common signal of anomalous behavior.

#### Risk Score: Each transaction receives a score based on triggered flags:

| Score | Risk Level |
|------|------------|
| 0 | Low |
| 1 | Medium |
| 2 | High |

Client-level risk is calculated by aggregating transaction-level signals across each client’s activity history.


## Machine Learning Model

In addition to the rule-based risk scoring system, this project includes a predictive Machine Learning component implemented in model.py. A Logistic Regression model from scikit-learn is trained on preprocessed transaction data enriched with engineered features (e.g., time-based behavioral patterns).

The model learns to estimate the probability that a transaction is fraudulent, complementing deterministic rules with data-driven insights. Once trained, the model is serialized and saved as model.joblib, allowing it to be easily loaded for inference in production or during further evaluation.


## Key Findings

- Majority of clients (~93%) fall into **Medium risk**, suggesting skewed distribution in the dataset and highlighting an opportunity to refine threshold logic for better risk differentiation
- Off-hours transactions (**midnight–5am**) show ~**15% higher average spend**, suggesting a strong behavioral signal for anomalous activity  
- High-value transactions are unexpectedly concentrated in **grocery_pos**, suggesting potential misuse patterns in typically low-risk merchant categories
- Clients aged **30–40** exhibit the highest average transaction amounts across groups  
- Transaction volume peaks at **11pm**, followed by a sharp drop after midnight - a natural threshold for defining off-hours   

---

## Business Impact

- Enables prioritization of high-risk clients for investigation  
- Reduces manual review effort by surfacing behavioral risk signals  
- Demonstrates how transaction data can support fraud detection workflows  
- Provides a scalable framework for client-level risk monitoring  

---

## Skills Demonstrated
- SQL analytics (CTEs, window functions)
- feature engineering
- risk segmentation
- data modeling
- machine learning (Logistic Regression)
- EDA
- End-to-end pipeline design.

---

## Tech Stack

| Layer | Tools |
|---|---|
| Data Processing | Python, pandas |
| Warehouse | PostgreSQL, Supabase |
| Analysis | SQL (CTEs, window functions, percentile scoring), Exploratory Data Analysis |
| Machine Learning | scikit-learn, joblib (Logistic Regression) |
| Visualization | Tableau, matplotlib |

---

## Pipeline Flow
```
Raw Transaction Data (CSV)
   → Data Cleaning & Sampling (pandas)
      → Supabase Staging Tables
         → Data Warehouse Modeling (PostgreSQL)
            → Data Validation (nulls, duplicates, outliers)
               → Feature Engineering (temporal, demographic, risk flags)
                  → Risk Scoring (percentile thresholds + velocity rules)
                     → Machine Learning Modeling (model.py: Logistic Regression)
                        → client_risk_summary view
                           → Tableau Dashboard (interactive risk monitoring)
```

