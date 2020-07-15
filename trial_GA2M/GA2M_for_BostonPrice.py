#%% import libraries
import pandas as pd
import numpy as np
#import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler
from sklearn.datasets import load_boston
from interpret.glassbox import ExplainableBoostingRegressor
from interpret import preserve
from interpret.data import Marginal

import os


# %% load data
boston_data = load_boston()
# こんな事しなくてもいいんだけど雑にpd.DataFrame化しとく。
boston_dataframe = pd.DataFrame(boston_data['data'])
column_names = ['feature_' + str(x) for x in boston_dataframe.columns.values]
boston_dataframe.columns = column_names
boston_dataframe['target'] = boston_data['target']

#%% 
boston_dataframe.head()
# %%
boston_dataframe.describe()
# %% Scaling
scaler = StandardScaler()
boston_dataframe[column_names] = scaler.fit_transform(boston_dataframe[column_names])


#%% data split 
from sklearn.model_selection import train_test_split
boston_train, boston_test = train_test_split(boston_dataframe)


#%% Train test split
X_train, X_test = boston_train[column_names], boston_test[column_names]
y_train, y_test = boston_train['target'], boston_test['target']

#%% Marginalize
marginal = Marginal()
explainable_data = marginal.explain_data(X_train, y_train, name='Train_data')
preserve(explainable_data)

#%% Do GA2M
class_GA2M = ExplainableBoostingRegressor(random_state=1234)
GA2M_model = class_GA2M.fit(X_train, y_train)

#%% result viewing
GA2M_global = class_GA2M.explain_global(name='EBM') 
GA2M_local  = class_GA2M.explain_local(X_test, y_test,name='SHAP')
#%% show global explanation
preserve(GA2M_global)

#%% 
preserve(GA2M_local)
#%% predict
model_pred = class_GA2M.predict(X_test)

# %%

