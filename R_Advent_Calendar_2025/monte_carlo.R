# モンテカルロシミュレーションによるITSパラメータ推定の一致性評価
setwd("./R_Advent_Calendar_2025")

# 必要なライブラリの読み込み
library(tidyverse) # データ操作と可視化用
library(ivreg) # 操作変数法
library(forecast) # ARIMA用

# モジュールの読み込み
source("module/module.R")

# メイン実行部分 -----------------------------------------------------------

# 真のパラメータ設定
true_params <- list(
  baseline = 50,
  trend = 0.5,
  level_change = -10,
  slope_change = 1.0,
  y_rho = 0.5,
  ar_coef = 0.5,
  noise_sd = 0.3
)

# シミュレーション設定
t_before_seq <- seq(100, 2000, by = 50)
n_sim <- 200

# モンテカルロシミュレーション実行
cat("モンテカルロシミュレーション開始...\n")
all_results <- map_dfr(t_before_seq, function(t_before) {
  cat(sprintf("t_before = %d 実行中...\n", t_before))
  run_monte_carlo(t_before, n_sim, true_params)
})

# 結果の集約
cat("結果を集約中...\n")
summary_results <- summarize_results(all_results)

# 可視化
cat("プロット作成中...\n")
p <- plot_monte_carlo_results(summary_results, true_params, y_rho = true_params$y_rho)

# プロット表示
print(p)

# pについてx >= 600の部分を拡大表示したい場合
# p + ggplot2::coord_cartesian(xlim = c(600, 1000))

# 結果の保存
ggsave("./output/monte_carlo_results.png",
  plot = p, width = 24, height = 12,
  dpi = 75
)
all_results |>
  readr::write_csv("./output/monte_carlo_results.csv")
