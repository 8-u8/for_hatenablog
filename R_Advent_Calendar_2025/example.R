setwd("./R_Advent_Calendar_2025")
source("./module/module.R")
library(tidyverse)
library(forecast)
library(sandwich) # Newey-West推定で標準誤差の補正
library(ivreg) # 操作変数法 

data_time <- 52 * 2

params <- data.frame(
  param_name = "真のパラメータ",
  t_before = data_time,
  t_after = round(data_time * 0.3),
  baseline = 50,
  trend = 0.5,
  level_change = -10,
  slope_change = 1,
  noise_sd = 5,
  y_rho = 0.5,
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
  y_rho = params$y_rho,
  ar_coef = params$ar_coef,
  seed = params$seed
)

simulate_ts_data$y

# 可視化（ggplot2がインストールされている場合）
result_plot <- visualize_its_data(simulate_ts_data, "生成データ")

result_plot

ggsave(
  filename = "./output/example_simulated_data_plot.png",
  plot = result_plot,
  width = 19,
  height = 10,
  dpi = 75
)

# 自己相関の確認
acf(simulate_ts_data$y, main = "目的変数の自己相関")


# パラメータ推定
## OLS
ols_model <- lm(y ~ time + intervention + time_after, data = simulate_ts_data)

## 結果の確認
summary(ols_model)

## 残差の自己相関の確認
acf(residuals(ols_model), main = "OLS残差の自己相関")

## ARIMAモデルによる推定
arima_model <- forecast::Arima(
  simulate_ts_data$y,
  xreg = cbind(
    time = simulate_ts_data$time,
    intervention = simulate_ts_data$intervention,
    time_after = simulate_ts_data$time_after
  ),
  method = "ML",
  order = c(1, 0, 1)  # AR(1)モデル
)

## 結果の確認
summary(arima_model)

## 操作変数法(2時点前のラグを使用)
simulate_ts_data <- simulate_ts_data |>
  dplyr::mutate(
    y_lag1 = dplyr::lag(y, 1),
    y_lag2 = dplyr::lag(y, 2)
  )

iv_model <- ivreg::ivreg(
  y ~ time + intervention + time_after + y_lag1| 
  time + intervention + time_after + y_lag2,
  data = simulate_ts_data,
  method = "OLS" # 2LS
)

summary(iv_model)

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
      param_name = "OLS",
      baseline = coef(ols_model)[["(Intercept)"]],
      trend = coef(ols_model)[["time"]],
      level_change = coef(ols_model)[["intervention"]],
      slope_change = coef(ols_model)[["time_after"]]
    )
  ) |>
  dplyr::bind_rows(
    tibble::tibble(
      param_name = "操作変数法",
      baseline = coef(iv_model)[["(Intercept)"]],
      trend =  coef(iv_model)[["time"]],
      level_change = coef(iv_model)[["intervention"]],
      slope_change = coef(iv_model)[["time_after"]]
    )
  ) |>
  dplyr::bind_rows(
    tibble::tibble(
      param_name = "ARIMA",
      baseline = arima_model$coef[["intercept"]],
      trend = arima_model$coef[["time"]],
      level_change = arima_model$coef[["intervention"]],
      slope_change = arima_model$coef[["time_after"]]
    )
  )

params_comparison

