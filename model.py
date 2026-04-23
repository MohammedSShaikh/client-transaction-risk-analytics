import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from joblib import dump

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

# DATA
data = pd.read_csv('data/modelData_transaction.csv')

# Ensure transaction_date is datetime type
data['transaction_date'] = pd.to_datetime(data['transaction_date'], errors="coerce")

# Calculate transaction velocity per absolute hour bucket per account
data['tx_date_only'] = data['transaction_date'].dt.date
data['tx_hour_only'] = data['transaction_date'].dt.hour

data['transactions_this_hour'] = data.groupby(
    ['account_id', 'tx_date_only', 'tx_hour_only']
)['account_id'].transform('count')

# Drop temporary date/hour columns used for grouping
data = data.drop(columns=['tx_date_only', 'tx_hour_only'])

X = data.drop(columns=["is_fraud", "transaction_id", "account_id", "merchant", "merchant_category"], errors="ignore")
Y = data['is_fraud']

# Convert date column
if "transaction_date" in X.columns:
    X["tx_year"] = X["transaction_date"].dt.year
    X["tx_month"] = X["transaction_date"].dt.month
    X["tx_day"] = X["transaction_date"].dt.day
    X["tx_weekday"] = X["transaction_date"].dt.weekday
    X = X.drop(columns=["transaction_date"])
    
X = X.fillna(X.median(numeric_only=True))

print(X.dtypes)
print(X.columns)

X_train, X_test, Y_train, Y_test = train_test_split(
    X, Y, test_size=0.2, random_state=42
)

scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)


# MODEL
model = RandomForestClassifier(n_estimators=100, class_weight='balanced', random_state=42)
model.fit(X_train, Y_train)

Y_pred = model.predict(X_test)


# EVALUATION
accuracy = accuracy_score(Y_test, Y_pred)
print(f'Accuracy: {accuracy}')

print("Random Forest Performance:\n")
print(confusion_matrix(Y_test, Y_pred))
print(classification_report(Y_test, Y_pred, digits=4))

dump(model, 'model.joblib')
