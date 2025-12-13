packages_list <- c(
    "DT", "tidyverse", "tidymodels", "lme4",
    "rdrobust", "CausalImpact", "plm",
    "forecast", "ivreg", "sandwich"
)

install.packages(packages_list)
renv::snapshot()