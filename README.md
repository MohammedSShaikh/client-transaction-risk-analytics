# Client Transaction Risk Analytics

### End-to-End Fraud Risk Analytics Pipeline on 1.5M+ Transactions

This project simulates how financial institutions identify potentially fraudulent customers using transaction behavior patterns. By engineering interpretable behavioral risk signals from 1.5M+ transactions, the pipeline prioritizes clients for investigation and demonstrates how analytics can improve fraud monitoring efficiency.

The system cleans, models, and analyzes transaction data within a PostgreSQL (Supabase) warehouse, generating client-level risk indicators based on transaction amount anomalies and unusual activity velocity.

### Live Dashboard  
[View Interactive Tableau Dashboard](https://public.tableau.com/app/profile/mohammed.s1243/viz/ClientTransactionRiskAnalyticsDashboard/Dashboard1?publish=yes)

## Dashboard Preview
![dashboard preview](https://github.com/MohammedSShaikh/client-transaction-risk-analytics/blob/main/dashboards/tableauDash.png)
---

## Business Problem
Financial institutions process millions of transactions daily, making manual fraud investigations impossible at scale. Without automated detection systems, fraud teams waste time reviewing low-risk activity while truly suspicious behavior goes unnoticed.

This project addresses that challenge by building a two-layer fraud detection system:

1. Rule-based risk scoring to flag anomalous customer behavior
2. Machine learning model to identify high-risk transactions for deeper review

This is similar to how modern fraud operation teams prioritize investigations, reduce false positives, and scale risk monitoring efficiently.

---

## Project Scope 
 
Working from a raw CSV of 1.5M+ credit card transactions, I built a complete analytics pipeline end-to-end:
 
- **Data Cleaning & Sampling**: Reduced the full dataset to ~900K records for warehouse loading, resolving nulls, duplicates, and type inconsistencies in Python/pandas
- **Data Warehouse**: Modeled a normalized 3-table schema (`clients`, `accounts`, `transactions`) in PostgreSQL via Supabase, with a staging layer for raw ingestion
- **Feature Engineering**: Extracted temporal behavioral signals including transaction velocity, off-hours activity, spend deviation, and merchant category exposure
- **Rule-Based Risk Scoring**: Built an interpretable scoring system using SQL CTEs and window functions, producing a `client_risk_summary` view
- **Machine Learning**: Trained and compared Logistic Regression, Random Forest, and XGBoost classifiers on labeled fraud data
- **Dashboard**: Published an interactive Tableau dashboard for live risk monitoring
---

## Key Findings

- Off-hours transactions (**midnight–5am**) show ~**15% higher average spend**, suggesting a strong behavioral signal for anomalous activity  
- High-value transactions are unexpectedly concentrated in **grocery_pos**, suggesting potential misuse patterns in typically low-risk merchant categories
- Clients aged **30–40** exhibit the highest average transaction amounts across groups  
- Transaction volume peaks at **11pm**, followed by a sharp drop after midnight - a natural threshold for defining off-hours
- Majority of clients (~93%) fall into **Medium risk**, suggesting skewed distribution in the dataset and highlighting an opportunity to refine threshold logic for better risk differentiation  

---
 
## Business Recommendations
  
**1. Prioritize `grocery_pos` for enhanced monitoring**
Unexpectedly high average transaction values in a typically low-risk category is a classic fraud pattern. Relatively smaller merchant categories used to blend fraudulent spending. Flag accounts with `grocery_pos` transactions significantly above the category baseline.
 
**2. Implement off-hours transaction alerts**
Midnight–5am activity carries a measurable spend premium. An automated alert for accounts exceeding their personal baseline during off-hours would surface anomalies with minimal false-positive overhead.
 
**3. Deploy the `client_risk_summary` view as a fraud team feed**
The PostgreSQL view is already structured for direct consumption. Connecting it to a real-time dashboard (or a daily Slack alert for new High-risk clients) would make this actionable without additional infrastructure.

**4. Refine risk tiers with multi-signal scoring**
The current 3-tier system (Low/Medium/High) under-differentiates. 93% of clients land in Medium. Introducing a weighted continuous score across more behavioral signals (velocity, off-hours rate, spend deviation, merchant exposure, geographic consideration) would give fraud teams a clearer and specific view of risk rather than a broad bucket.
 
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

In addition to the rule-based risk scoring system, this project includes a predictive Machine Learning component implemented in model.py. Three classifiers were trained and compared on the labeled dataset:
 
| Model | Accuracy | Precision (macro) | Recall (macro) | F1 (macro) |
|-------|----------|-------------------|----------------|------------|
| Logistic Regression | 99.79% | 0.79 | 0.68 | 0.70 |
| Logistic Regression (Balanced) | 0.98 | 0.65 | 0.91 | 0.68 |
| **Random Forest** | **99.99%** | **0.99** | **0.98** | **0.99** |
| XGBoost | 99.90% | 0.99 | 0.97 | 0.96 |

The model learns to estimate the probability that a transaction is fraudulent, complementing deterministic rules with data-driven insights. 

Random Forest was selected for production deployment (`model.joblib`) based on its near-perfect recall on the minority fraud class - correctly identifying 9,171 of 9,176 medium-risk and 189 of 204 high-risk transactions in the test set.

---

## Tech Stack

| Layer | Tools |
|---|---|
| Data Processing | Python, pandas |
| Warehouse | PostgreSQL, Supabase |
| Analysis | SQL (CTEs, window functions, percentile scoring), Exploratory Data Analysis |
| Machine Learning | scikit-learn, joblib (Random Forest) |
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
                     → Machine Learning Modeling (model.py: Random Forest)
                        → client_risk_summary view
                           → Tableau Dashboard (interactive risk monitoring)
```

---

## Skills Demonstrated
- SQL analytics (CTEs, window functions)
- feature engineering
- risk segmentation
- data modeling
- machine learning (multiple trained models)
- EDA
- End-to-end pipeline design.


