setwd("./R_Advent_Calendar_2025")
source("./module/module.R")

params <- data.frame(
  param_name = "真のパラメータ",
  t_before = 104,
  t_after = round(104 * 0.3),
  baseline = 0.3,
  trend = 0.01,
  level_change = -1,
  slope_change = 0.01,
  noise_sd = 0.5,
  ar_coef = 0.3,
  seed = 123
)

simulate_ts_data <- simulate_its_data(
  t_before = params$t_before,
  t_after = params$t_after,
  baseline = params$baseline,
  trend = params$trend,
  level_change = params$level_change,
  slope_change = params$slope_change,
  noise_sd = params$noise_sd,
  ar_coef = params$ar_coef,
  seed = params$seed
)


# 可視化（ggplot2がインストールされている場合）
result_plot <- visualize_its_data(simulate_ts_data, "生成データ")

result_plot

# パラメータ推定
## OLS
ols_model <- lm(y ~ time + intervention + time_after, data = simulate_ts_data)

summary(ols_model)

# 可視化 OLS推定値
simulate_ts_data <- simulate_ts_data |>
  dplyr::mutate(
    ols_fitted = predict(ols_model),
    # 予測値の95%信頼区間
    ols_lower = ols_fitted - 1.96 * summary(ols_model)$sigma,
    ols_upper = ols_fitted + 1.96 * summary(ols_model)$sigma
  )

result_plot <- visualize_its_data(simulate_ts_data, "OLS推定値の可視化") +
  ggplot2::geom_line(
    ggplot2::aes(y = ols_fitted),
    color = "green",
    linewidth = 1,
    linetype = "solid"
  ) + 
  ggplot2::geom_ribbon(
    ggplot2::aes(ymin = ols_lower, ymax = ols_upper),
    fill = "green",
    alpha = 0.1
  )

result_plot

## パラメータ比較
params_comparison <- params |>
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

params_comparison
