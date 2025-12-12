packages_list <- c(
    "DT", "tidyverse", "tidymodels", "lme4",
    "rdrobust", "CausalImpact", "plm",
    "forecast"
)

install.packages(packages_list)
renv::snapshot()