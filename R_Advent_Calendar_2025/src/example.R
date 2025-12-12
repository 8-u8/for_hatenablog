setwd("./R_Advent_Calendar_2025")
# source("./use_packages.R")
source("./src/init_module.R")


simulate_ts_data <- simulate_its_data(
  n_before = 100,
  n_after = 50,
  baseline = 5,
  trend = 0.1,
  level_change = -10,
  slope_change = 0,
  noise_sd = 1,
  seed = 123
)


# 可視化（ggplot2がインストールされている場合）
visualize_its_data(simulate_ts_data, "例: 水準変化 + 傾き変化")

