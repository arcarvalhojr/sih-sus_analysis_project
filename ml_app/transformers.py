# %%
# import necessary packages
import pandas as pd
import numpy as np
from sklearn.base import BaseEstimator
from sklearn.base import TransformerMixin

# %%
# custom transformer for group bed speciality feature
class SpecialityGrouper(BaseEstimator, TransformerMixin):
  def __init__(self, target_col="death_flag"):
    self.target_col = target_col
    self.zero_risk_ = []
    self.few_cases_ = []
    self.rare_cases_ = []

  def fit(self, X, y):
    df_temp = X.copy()
    df_temp[self.target_col] = y
    
    # create the summary
    summary = df_temp.groupby("bed_speciality")[self.target_col].agg([
      'sum', 'count'])
    summary.columns = ['total_deaths', 'total_obs']

    # define the filters
    self.zero_risk_ = summary[
      (summary["total_deaths"] == 0) & (summary["total_obs"] > 100)
    ].index.tolist()

    self.few_cases_ = summary[
      (summary["total_deaths"] > 0) & (summary["total_obs"] > 100) & 
      (summary["total_obs"] <= 3000)
    ].index.tolist()
    
    self.rare_cases_ = summary[
      (summary["total_obs"] <= 100)
    ].index.tolist()

    return self

  def transform(self, X):
    X = X.copy()

    # define conditions to be applied
    conditions = [
      X["bed_speciality"].isin(self.zero_risk_),
      X["bed_speciality"].isin(self.few_cases_),
      X["bed_speciality"].isin(self.rare_cases_)
    ]
    results = ["zero risk", "few cases", "rare cases"]

    # apply the conditions
    X["bed_speciality"] = np.select(
      conditions, results, default=X["bed_speciality"] 
    )
    return X

# %%
# custom transformer for group procedure feature
class ProcedureGrouper(BaseEstimator, TransformerMixin):
  def __init__(self, target_col="death_flag"):
    self.target_col = target_col
    self.zero_risk_ = []
    self.few_cases_ = []
    self.rare_cases_ = []
    
  def fit(self, X, y):
    df_temp = X.copy()
    df_temp[self.target_col] = y
    
    summary = df_temp.groupby("procedure")[self.target_col].agg(['sum', 'count'])
    summary.columns = ['total_deaths', 'total_obs']
    
    self.zero_risk_ = summary[
        (summary["total_deaths"] == 0) & (summary["total_obs"] > 100)
    ].index.tolist()
    
    self.few_cases_ = summary[
        (summary["total_deaths"] > 0) & (summary["total_obs"] > 100) &
        (summary["total_obs"] <= 1000)
    ].index.tolist()
    
    self.rare_cases_ = summary[
      (summary["total_obs"] <= 100)
    ].index.tolist()

    return self

  def transform(self, X):
    X = X.copy()

    conditions = [
      X["procedure"].isin(self.zero_risk_),
      X["procedure"].isin(self.few_cases_),
      X["procedure"].isin(self.rare_cases_)
    ]
    results = ["zero risk", "few cases", "rare cases"]

    X["procedure"] = np.select(
      conditions, results, default=X["procedure"] 
    )
    return X

# %%
# custom transformer to calculate the median days of hosptalization by age and some other feature
class MeanDaysByGrouper(BaseEstimator, TransformerMixin):
  def __init__(self, days_column, grouping_cols, feature_name):
    self.days_column = days_column
    self.grouping_cols = grouping_cols
    self.feature_name = feature_name
    self.mapping_ = None

  def fit(self, X, y):
    X_fit = X.copy()
    X_fit["target"] = y.values
    # define the filter by who survived
    survivors = X_fit[X_fit["target"] == 0]
    # set the map to get the mean only by the survivors
    self.mapping_ = (survivors
        .groupby(self.grouping_cols)[self.days_column]
        .mean()
    )
    return self

  def transform(self, X):
    X_tr = X.copy()
    
    X_tr[self.feature_name] = (
      X_tr
      .set_index(self.grouping_cols)
      .index
      .map(self.mapping_)
    )
    return X_tr