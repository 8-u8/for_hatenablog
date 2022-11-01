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
usedata = pd.read_excel(
    "../input/kaggle_ad_data.xlsx"
)

# %% data.chk
print(usedata.head())

# %% data aggregation
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

# %% transform data format
media_data_jax = jnp.array(
    media_data_raw.values
)

costs_jax = jnp.array(
    costs_raw.values
)

sales_jax = jnp.array(
    sales_raw.values
)

media_data_jax = jnp.nan_to_num(media_data_jax)
cost_jax = jnp.nan_to_num(media_data_jax)
sales_jax = jnp.nan_to_num(sales_jax)


# %% train test split
split_point = len(media_data_jax) - 20

media_data_train = media_data_jax[:split_point]
media_data_test = media_data_jax[split_point:]

target_train = sales_jax[:split_point]
target_test = sales_jax[split_point:]

costs_train = cost_jax[:split_point].sum(axis=0)
costs_test = cost_jax[split_point:].sum(axis=0)
media_names = media_data_raw.columns

# %% scaling
media_scaler = preprocessing.CustomScaler(divide_operation=jnp.mean)
target_scaler = preprocessing.CustomScaler(divide_operation=jnp.mean)
costs_scaler = preprocessing.CustomScaler(divide_operation=jnp.mean)

media_data_train = media_scaler.fit_transform(media_data_train)
media_data_test = media_scaler.transform(media_data_test)

target_train = target_scaler.fit_transform(target_train)
target_test = target_scaler.transform(target_test)

costs_train = costs_scaler.fit_transform(costs_train)
cost_test = costs_scaler.transform(costs_test)

# %% find best model
# carryover model is slow.
model_name = 'hill_adstock'
degrees_season = [1, 2, 3]

mmm = lightweight_mmm.LightweightMMM(model_name=model_name)
mmm.fit(
    media=media_data_train,
    media_prior=costs_train,
    target=target_train,
    number_warmup=1000,
    number_samples=1000,
    number_chains=1,
    # degrees_seasonality=degrees,
    weekday_seasonality=True,
    seasonality_frequency=365,
    seed=42
)
pred = mmm.predict(
    media=media_data_test,
    target_scaler=target_scaler
)

# p = pred.mean(axis=0)

# mape = mean_absolute_percentage_error(
#     target_test.values,
#     p
# )
# # print(f"model_name: {model_name}, degrees={degrees}")
# print(f"MAPE={mape}, samples={p[:3]}")

# %%
media_effect_hat, roi_hat = mmm.get_posterior_metrics()

# %% 1. accuracy
plot.plot_model_fit(
    media_mix_model=mmm,
    target_scaler=target_scaler
)

# %% 2. media effect
plot.plot_bars_media_metrics(
    metric=media_effect_hat, channel_names=media_names
)

# %% 3. roi effect
plot.plot_bars_media_metrics(
    metric=roi_hat,
    channel_names=media_names
)

# %% 4. media get_posterior
plot.plot_media_channel_posteriors(
    media_mix_model=mmm
)

# %% 5. response curve
plot.plot_response_curves(
    media_mix_model=mmm
)

# %% 6. plot contribution
plot.plot_media_baseline_contribution_area_plot(
    media_mix_model=mmm,
    target_scaler=target_scaler
)

# %% media allocation.
prices = costs_test / media_data_raw.sum(axis=0)
budget = 1  # your budget here
solution = optimize_media.find_optimal_budgets(
    n_time_periods=1,
    media_mix_model=mmm,
    budget=budget,
    prices=prices.values)

# %%
