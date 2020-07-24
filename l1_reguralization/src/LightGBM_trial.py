'''
main objective
compare to L1 reguralization and Feature selection 
'''


#%%
import os 
import sys

from sklearn.datasets import load_wine
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error

import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
import lightgbm as lgb

import matplotlib.pyplot as plt

#%% load data
use_data = pd.read_csv('../input/UseData.csv',sep=",")

#%% make validation(simple train-test split)
X = use_data.drop(['ID','y'], axis=1)
y = use_data['y']

X_train, X_test, y_train, y_test = train_test_split(X, y)

#%% feature selection by randomforest regression.

RF_model = RandomForestRegressor()
RF_fit   = RF_model.fit(X=X_train, y=y_train)

#%%
feature_names = X.columns.values
feature_importances = RF_model.feature_importances_
indices = np.argsort(feature_importances)

plt.barh(range(1,31), feature_importances[indices][0:30])
plt.yticks(range(1,31), feature_names[indices][0:30])

#%% lightgbm params

lightgbm_params_l1 = {
    'objective':'regression',
    'metrics'  : 'rmse',
    'reg_alpha': 0.2,       # trial
}

lightgbm_params_fs = {
    'objective':'regression',
    'metrics'  :'rmse'
}

#%% drop features based on RandomForest importance.
drop_features = ['Var.'+str(i) for i in indices[500:600]]

#%% lightgbm datasets
lgb_train_l1 = lgb.Dataset(X_train, y_train, feature_name=list(X.columns.values))
lgb_valid_l1 = lgb.Dataset(X_test,  y_test , reference=lgb_train_l1)

#%%
X_train_fs, X_test_fs = X_train.drop(drop_features, axis=1), X_test.drop(drop_features, axis=1)

lgb_train_fs = lgb.Dataset(X_train_fs, y_train, feature_name=list(X_train_fs.columns.values))
lgb_valid_fs = lgb.Dataset(X_test_fs, y_test, reference=lgb_train_fs)

#%% model
model_l1 = lgb.train(lightgbm_params_l1, lgb_train_l1, valid_sets=lgb_valid_l1)
model_fs = lgb.train(lightgbm_params_fs, lgb_train_fs, valid_sets=lgb_valid_fs)

#%%
pred_l1 = model_l1.predict(X_test, num_iteration=model_l1.best_iteration)
pred_fs = model_fs.predict(X_test_fs, num_iteration=model_fs.best_iteration)

#%% 
lgb.plot_importance(model_l1,title='L1 importance',max_num_features=30)

#%%
lgb.plot_importance(model_fs,title='Feature selection importances', max_num_features=30)
#%% 
rmse_l1 = np.sqrt(mean_squared_error(y_test, pred_l1))
rmse_fs = np.sqrt(mean_squared_error(y_test, pred_fs))

# %%

print(f'L1 implemented LightGBM RMSE is: {rmse_l1}')
print(f'Feature selected LightGBM RMSE is: {rmse_fs}')



# %%
