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

# %% data loading functions
usedata = pd.read_excel("../input/Sr_Advertising_Analyst_Work_Sample.xlsx")

# %% data.chk
print(usedata.head())

# %%
agg_data = usedata.groupby(["Date", "Ad group alias"])[
    ["Impressions", "Spend", "Sales"]].sum()
agg_data = agg_data.drop(["Brand 1 Ad Group 12"], axis=0, level=1)

media_data_raw = agg_data["Impressions"].unstack().fillna(0)
costs_raw = agg_data["Spend"].unstack()
sales_raw = agg_data["Sales"].reset_index().groupby(["Date"]).sum()
