setwd("./R_Advent_Calendar_2025")
# source("./use_packages.R")
source("./src/init_module.R")

params <- data.frame(
  param_name = "grand_truth",
  n_before = 100,
  n_after = 50,
  baseline = 5,
  trend = 0.1,
  level_change = -10,
  slope_change = 0.01,
  noise_sd = 1,
  ar_coef = 0.3,
  seed = 123
)

simulate_ts_data <- simulate_its_data(
  n_before = params$n_before,
  n_after = params$n_after,
  baseline = params$baseline,
  trend = params$trend,
  level_change = params$level_change,
  slope_change = params$slope_change,
  noise_sd = params$noise_sd,
  ar_coef = params$ar_coef,
  seed = params$seed
)


# 可視化（ggplot2がインストールされている場合）
visualize_its_data(simulate_ts_data, "例: 水準変化 + 傾き変化") + 
  ggplot2::theme(aspect.ratio = 0.5)

# パラメータ推定
## OLS
ols_model <- lm(y ~ time + intervention + time_after, data = simulate_ts_data)

summary(ols_model)

## Newey-West標準誤差による標準誤差評価
nw_vconv <- sandwich::NeweyWest(ols_model, prewhite = FALSE, adjust = TRUE)
nw_se <- sqrt(diag(nw_vconv))

summary_table <- data.frame(
    Estimate = coef(ols_model),
    ols_SE = summary(ols_model)$coefficients[, "Std. Error"],
    NW_SE = nw_se,
    t_value = coef(ols_model) / nw_se,
    p_value = 2 * (1 - pt(abs(coef(ols_model) / nw_se),
    df = ols_model$df.residual)))
summary_table

## パラメータ比較表
use_comparison <- params |>
  dplyr::select(
    param_name,
    baseline,
    trend,
    level_change,
    slope_change
  ) |>
  dplyr::bind_rows(
    tibble::tibble(
      param_name = "OLS推定値",
      baseline = coef(ols_model)[["(Intercept)"]],
      trend = coef(ols_model)[["time"]],
      level_change = coef(ols_model)[["intervention"]],
      slope_change = coef(ols_model)[["time_after"]]
    )
  )
