# %%
import pandas as pd
import numpy as np

import jax.numpy as jnp
from sklearn.metrics import mean_absolute_percentage_error

from lightweight_mmm import preprocessing

from lightweight_mmm import utils
from lightweight_mmm import lightweight_mmm
from lightweight_mmm import plot
from lightweight_mmm import optimize_media

# %%
sim_data = pd.read_csv("./input/simulated_data.csv")
sim_data = sim_data.dropna(axis=0)

# %% config: set variables
spend_columns = ['spend_TV', 'spend_Facebook', 'spend_Search']
media_columns = ['impressions_TV', 'impressions_Facebook', 
                 'clicks_Search']
sales = ['total_revenue']

spend_data = sim_data[spend_columns]
media_data = sim_data[media_columns]
sales_data = sim_data[sales]

# %% convert jax format
cost_jax = jnp.array(
    spend_data.values
)

media_data_jax = jnp.array(
    media_data.values
)

sales_jax = jnp.array(
    sales_data.values
)

# %% train test split
split_point = len(media_data_jax) - 20

media_data_train = media_data_jax[:split_point]
media_data_test = media_data_jax[split_point:]

target_train = sales_jax[:split_point]
target_test = sales_jax[split_point:]

costs_train = cost_jax[:split_point].sum(axis=0)
costs_test = cost_jax[split_point:].sum(axis=0)
media_names = media_data.columns

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
    media_names=['TV', 'Facebook', 'Search'],
    media_prior=costs_train,
    target=target_train,
    number_warmup=1000,
    number_samples=10_000,
    number_chains=5,
    # degrees_seasonality=degrees,
    weekday_seasonality=True,
    seasonality_frequency=365,
    seed=42
)

#%%
pred = mmm.predict(
    media=media_data_test,
    target_scaler=target_scaler
)

# %% 
mmm.print_summary()

# %%
media_effect_hat, roi_hat = mmm.get_posterior_metrics()

# %%
lambda_table = pd.DataFrame(mmm.trace['lag_weight']._value, columns=mmm.media_names)
# When I used lightweight MMM on this dataset, 
# I assumed mmm.trace['lag_weight'] would recover my lambdas. Instead, 
# I am getting these (relatively) very large values:
lambda_table.apply(np.mean, axis=0)

# %%
utils.save_model(mmm, "./output/lightweight_mmm_20240724_model.pkl")
