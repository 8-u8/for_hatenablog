# %%
import pandas as pd
# import numpy as np

import jax.numpy as jnp
from sklearn.metrics import mean_absolute_percentage_error

from lightweight_mmm import preprocessing
# from lightweight_mmm import utils
from lightweight_mmm import lightweight_mmm
from lightweight_mmm import plot
from lightweight_mmm import optimize_media

# %% data loading functions
# data from: https://www.kaggle.com/datasets/saicharansirangi/adanalyse
usedata = pd.read_excel("../input/Sr_Advertising_Analyst_Work_Sample.xlsx")

# %% data.chk
print(usedata.head())

# %%
agg_data = usedata.groupby(["Date", "Ad group alias"])[
    ["Impressions", "Spend", "Sales"]].sum()
agg_data = agg_data.drop(["Brand 1 Ad Group 12"], axis=0, level=1)

# media impressions(response)
media_data_raw = agg_data["Impressions"].unstack().fillna(0)
# how many spend each media?
costs_raw = agg_data["Spend"].unstack()
# brand sales
sales_raw = agg_data["Sales"].reset_index().groupby(["Date"]).sum()

# %% chk
print(media_data_raw)
print(costs_raw)
print(sales_raw)

# %% train test split
split_point = pd.Timestamp("2021-12-15")
time_delta = pd.Timedelta(1, 'D')

media_data_train = media_data_raw.loc[:split_point - time_delta]
media_data_test = media_data_raw.loc[split_point:]

target_train = sales_raw.loc[:split_point - time_delta]
target_test = sales_raw.loc[split_point:]

costs_train = costs_raw.loc[:split_point - time_delta].sum(axis=0).\
    loc[media_data_train.columns]

# %% scaling
media_scaler = preprocessing.CustomScaler(divide_operation=jnp.mean)
target_scaler = preprocessing.CustomScaler(divide_operation=jnp.mean)
costs_scaler = preprocessing.CustomScaler(divide_operation=jnp.mean)

media_scaled_fit = media_scaler.fit(media_data_train.values)
media_data_train_scaled = media_scaler.transform(media_data_train.values)
target_train_scaled = target_scaler.fit_transform(target_train.values)
costs_train_scaled = costs_scaler.fit_transform(costs_train.values)

media_data_test_scaled = media_scaler.transform(media_data_test.values)
media_names = media_data_raw.columns
# %% find best model
# carryover model is slow.
mmm_model_list = ["adstock", "hill_adstock", "carryover"]
degrees_season = [1, 2, 3]

for model_name in mmm_model_list:
    for degrees in degrees_season:
        mmm = lightweight_mmm.LightweightMMM(model_name=model_name)
        mmm.fit(
            media=media_data_train_scaled,
            media_prior=costs_train_scaled,
            target=target_train_scaled,
            number_warmup=1000,
            number_samples=1000,
            number_chains=1,
            degrees_seasonality=degrees,
            weekday_seasonality=True,
            seasonality_frequency=365,
            seed=42
        )
        pred = mmm.predict(
            media=media_data_test_scaled,
            target_scaler=target_scaler
        )
        p = pred.mean(axis=0)

        mape = mean_absolute_percentage_error(
            target_test.values,
            p
        )
        print(f"model_name: {model_name}, degrees={degrees}")
        print(f"MAPE={mape}, samples={p[:3]}")

# %%
costs = costs_raw.sum(axis=0).loc[media_names]

media_scaler2 = preprocessing.CustomScaler(divide_operation=jnp.mean)
target_scaler2 = preprocessing.CustomScaler(
    divide_operation=jnp.mean)
cost_scaler2 = preprocessing.CustomScaler(divide_operation=jnp.mean)

media_data_scaled = media_scaler2.fit_transform(media_data_raw.values)
target_scaled = target_scaler2.fit_transform(sales_raw.values)
costs_scaled2 = cost_scaler2.fit_transform(costs.values)

media_names = media_data_raw.columns

mmm = lightweight_mmm.LightweightMMM(model_name="hill_adstock")
mmm.fit(media=media_data_scaled,
        media_prior=costs_scaled2,
        target=target_scaled,
        number_warmup=1000,
        number_samples=1000,
        number_chains=1,
        degrees_seasonality=1,
        weekday_seasonality=True,
        seasonality_frequency=365,
        seed=1)

# %%
media_effect_hat, roi_hat = mmm.get_posterior_metrics()
plot.plot_bars_media_metrics(
    metric=media_effect_hat, channel_names=media_names)

# %%
plot.plot_bars_media_metrics(metric=roi_hat, channel_names=media_names)

# %% media allocation.
prices = costs / media_data_raw.sum(axis=0)
budget = 1  # your budget here
solution = optimize_media.find_optimal_budgets(
    n_time_periods=1,
    media_mix_model=mmm,
    budget=budget,
    prices=prices.values)

# %%
