source("./module/module.R")

# 固定パラメータでテスト
test_mc_small <- run_monte_carlo(
  t_before = 100,
  n_sim = 50,
  true_params = list(
    baseline = 50, trend = 0.5,
    level_change = -10, slope_change = 1.0
  )
)

test_mc_large <- run_monte_carlo(
  t_before = 2000,
  n_sim = 50,
  true_params = list(
    baseline = 50, trend = 0.5,
    level_change = -10, slope_change = 1.0
  )
)

# 各手法の推定値の平均を比較
test_mc_small |>
  group_by(method) |>
  summarise(across(baseline:slope_change, mean, na.rm = TRUE))

test_mc_large |>
  group_by(method) |>
  summarise(across(baseline:slope_change, mean, na.rm = TRUE))

# デバッグ用：実際の係数数を確認
test_data <- simulate_its_data(
  t_before = 100, t_after = 30,
  baseline = 50, trend = 0.5,
  level_change = -10, slope_change = 1.0,
  noise_sd = 1, y_rho = 0.3, ar_coef = 0.3,
  seed = 123
) |>
  dplyr::mutate(
    y_lag1 = dplyr::lag(y, 1)
  )

ols_lag_model <- lm(y ~ time + intervention + time_after + y_lag1, data = test_data)

# 係数の数を確認
length(coef(ols_lag_model)) # 5のはず
names(coef(ols_lag_model)) # 名前を確認
coef(ols_lag_model) # 値を確認
