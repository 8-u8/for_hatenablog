'''
Objective: to learn causalnex
ref: https://causalnex.readthedocs.io/en/latest/03_tutorial/03_tutorial.html

I changed some object name to understand myself.
'''

# %%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import graphviz
import warnings

from IPython.display import Image
from sklearn.preprocessing import LabelEncoder

import os
import sys
import gc

from causalnex.structure import StructureModel
from causalnex.plots import plot_structure, NODE_STYLE, EDGE_STYLE
from causalnex.structure.notears import from_pandas

# %%
# sm = StructureModel()

# %% add edge
warnings.filterwarnings('ignore')
# # %%
# sm.add_edges_from([('health', 'absences'), ('health', 'G1')])

# # %% watch object structure
# sm.edges

# # %% check graph
# viz = plot_structure(sm,
#                      graph_attributes={'scale': '0.5'},
#                      all_node_attributes=NODE_STYLE.WEAK,
#                      all_edge_attributes=EDGE_STYLE.WEAK)
# Image(viz.draw(format='png'))

# %% load data
student_por = pd.read_csv('../sample_data/student-por.csv', sep=';')
student_por.shape

# %% modeling from expert knowledge
# check data
# data: student performance.
student_por.head()

# %%
# to drop sensitive features(to avoid statistical discrimination)
drop_col = ['school', 'sex', 'age', 'Mjob', 'Fjob', 'reason', 'guardian']
student_por.drop(drop_col, axis=1, inplace=True)

# %% preprocessing
# label encoding
le = LabelEncoder()
categorical_features = list(
    student_por.select_dtypes(exclude=[np.number]).columns)
categorical_features

# %%
for cat_col in categorical_features:
    student_por[cat_col] = le.fit_transform(student_por[cat_col])
student_por.head()

# %% NOTEARS algorithm structure
# maybe some times to calculate.
no_tears_sm = from_pandas(student_por)

# %% visualization
# overwrite viz object to reduce memory
# if OSError, check issue below:
#  https://github.com/quantumblacklabs/causalnex/issues/27
# does not work. maybe my local PC spec is low
# or graphviz version is not match.
# I think it is caused by my PC.
viz = plot_structure(no_tears_sm,
                     graph_attributes={"scale": "0.5"},
                     all_node_attributes=NODE_STYLE.WEAK,
                     all_edge_attributes=EDGE_STYLE.WEAK)
# %% view
filename = './output/structure_model.png'
viz.draw(filename)
Image(filename)
# %%
no_tears_sm.remove_edges_below_threshold(0.8)
viz = plot_structure(no_tears_sm,
                     graph_attributes={"scale": "0.5"},
                     all_node_attributes=NODE_STYLE.WEAK,
                     all_edge_attributes=EDGE_STYLE.WEAK)
Image(viz.draw(format='png'))
# it works.
# %%
