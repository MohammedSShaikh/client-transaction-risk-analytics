import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from joblib import dump

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

# DATA
data = pd.read_csv('data/modelData_transaction.csv')


X = data.drop(columns=["is_fraud", "transaction_id", "account_id", "merchant", "merchant_category"], errors="ignore")
Y = data['is_fraud']

# Convert date column
if "transaction_date" in X.columns:
    X["transaction_date"] = pd.to_datetime(X["transaction_date"], errors="coerce")
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
model = LogisticRegression()
model.fit(X_train, Y_train)

Y_pred = model.predict(X_test)


# EVALUATION
accuracy = accuracy_score(Y_test, Y_pred)
print(f'Accuracy: {accuracy}')

print(confusion_matrix(Y_test, Y_pred))
print(classification_report(Y_test, Y_pred, digits=4))

dump(model, 'model.joblib')
