# バーンイン期間のデバッグ用スクリプト
setwd("./R_Advent_Calendar_2025")

library(tidyverse)
source("module/module.R")

# バーンイン期間を含む時系列を生成する関数（デバッグ用）
simulate_its_data_with_burnin <- function(t_before = 20,
                                          t_after = 20,
                                          baseline = 50,
                                          trend = 0.5,
                                          level_change = 10,
                                          slope_change = 0,
                                          noise_sd = 3,
                                          y_rho = 0,
                                          ar_coef = 0,
                                          seed = NULL) {
  # 乱数シード設定
  if (!is.null(seed)) {
    set.seed(seed)
  }

  # 総観測数
  t_total <- t_before + t_after

  # 時間変数
  time <- 1:t_total

  # 介入ダミー変数（0: 介入前, 1: 介入後）
  intervention <- c(rep(0, t_before), rep(1, t_after))

  # 介入後の時間変数（介入前は0、介入後は1,2,3...）
  time_after <- c(rep(0, t_before), 1:t_after)

  # 決定論的な部分（トレンド + 介入効果）
  deterministic <- baseline +
    trend * time +
    level_change * intervention +
    slope_change * time_after

  # ノイズ生成
  if (ar_coef == 0) {
    epsilon <- rnorm(t_total, mean = 0, sd = noise_sd)
  } else {
    epsilon <- numeric(t_total)
    epsilon[1] <- rnorm(1, mean = 0, sd = noise_sd)
    for (i in 2:t_total) {
      epsilon[i] <- ar_coef * epsilon[i - 1] +
        rnorm(1, mean = 0, sd = noise_sd * sqrt(1 - ar_coef^2))
    }
  }

  # 観測値の生成（y_rhoによる内生的フィードバック）
  if (y_rho == 0) {
    # フィードバックなし
    y <- deterministic + epsilon

    # データフレーム作成
    data <- data.frame(
      time = time,
      y = y,
      intervention = intervention,
      time_after = time_after,
      phase = "data"
    )
  } else {
    # フィードバックあり: バーンイン期間を追加
    burnin <- 100

    # バーンイン期間中は固定値でトレンドなし
    # AR(1)過程の定常状態: E[y] = E[μ]/(1-ρ)
    # 実データ期間でE[y]≈baselineにするため、決定論的部分を(1-ρ)でスケーリング
    deterministic_burnin <- rep(baseline * (1 - y_rho), burnin)
    deterministic_scaled <- deterministic * (1 - y_rho)
    deterministic_extended <- c(deterministic_burnin, deterministic_scaled)

    # バーンイン期間のノイズを追加
    if (ar_coef == 0) {
      epsilon_burnin <- rnorm(burnin, mean = 0, sd = noise_sd)
    } else {
      # AR(1)ノイズもバーンイン期間分生成
      epsilon_burnin <- numeric(burnin)
      epsilon_burnin[1] <- rnorm(1, mean = 0, sd = noise_sd)
      for (i in 2:burnin) {
        epsilon_burnin[i] <- ar_coef * epsilon_burnin[i - 1] +
          rnorm(1, mean = 0, sd = noise_sd * sqrt(1 - ar_coef^2))
      }
    }
    epsilon_extended <- c(epsilon_burnin, epsilon)

    # AR(1)過程を生成: y_t = deterministic_t + epsilon_t + y_rho * y_{t-1}
    # ベクトル化: stats::filter()でAR(1)過程を生成（dplyr::filter()との衝突回避）
    # 初期値も(1-y_rho)で調整して定常状態から開始
    y_extended <- as.numeric(stats::filter(
      deterministic_extended + epsilon_extended,
      filter = y_rho,
      method = "recursive",
      init = baseline * (1 - y_rho)
    ))

    # バーンイン期間を含む全データを返す
    # time軸はバーンイン期間を負の値で表現
    time_extended <- c((-burnin + 1):0, 1:t_total)
    intervention_extended <- c(rep(0, burnin), intervention)
    time_after_extended <- c(rep(0, burnin), time_after)

    data <- data.frame(
      time = time_extended,
      y = y_extended,
      deterministic = deterministic_extended,
      epsilon = epsilon_extended,
      intervention = intervention_extended,
      time_after = time_after_extended,
      phase = c(rep("burnin", burnin), rep("data", t_total))
    )
  }

  data
}

# テストパラメータ
test_data <- simulate_its_data_with_burnin(
  t_before = 100,
  t_after = 30,
  baseline = 50,
  trend = 0.5,
  level_change = -10,
  slope_change = 1.0,
  noise_sd = 0.3,
  y_rho = 0.5,
  ar_coef = 0.5,
  seed = 123
)

# バーンイン期間の統計情報を表示
cat("=== バーンイン期間の統計 ===\n")
burnin_data <- test_data |> filter(phase == "burnin")
cat(sprintf("バーンイン期間のy平均: %.2f\n", mean(burnin_data$y)))
cat(sprintf("バーンイン期間のy標準偏差: %.2f\n", sd(burnin_data$y)))
cat(sprintf(
  "バーンイン期間のy範囲: [%.2f, %.2f]\n",
  min(burnin_data$y), max(burnin_data$y)
))

cat("\n=== 実データ期間の統計 ===\n")
data_portion <- test_data |> filter(phase == "data")
cat(sprintf("実データ期間のy平均: %.2f\n", mean(data_portion$y)))
cat(sprintf("実データ期間のy標準偏差: %.2f\n", sd(data_portion$y)))
cat(sprintf(
  "実データ期間のy範囲: [%.2f, %.2f]\n",
  min(data_portion$y), max(data_portion$y)
))

cat("\n=== 境界付近の値（t=-5 から t=5）===\n")
boundary_data <- test_data |> filter(time >= -5 & time <= 5)
print(boundary_data |> select(time, y, deterministic, phase))

cat("\n=== 最初の10時点の変化率 ===\n")
first_10 <- data_portion |> head(10)
first_10 <- first_10 |>
  mutate(
    y_change = y - lag(y),
    y_change_pct = (y - lag(y)) / lag(y) * 100
  )
print(first_10 |> select(time, y, y_change, y_change_pct))

# 可視化: バーンイン期間を含む全体
p1 <- ggplot(test_data, aes(x = time, y = y, color = phase)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  geom_vline(xintercept = 100, linetype = "dashed", color = "blue") +
  annotate("text",
    x = -50, y = max(test_data$y),
    label = "バーンイン期間", color = "red", size = 5
  ) +
  annotate("text",
    x = 50, y = max(test_data$y),
    label = "実データ期間", color = "blue", size = 5
  ) +
  scale_color_manual(values = c("burnin" = "gray50", "data" = "steelblue")) +
  labs(
    title = "バーンイン期間を含む時系列データ",
    subtitle = sprintf("y_rho=%.1f, ar_coef=%.1f, noise_sd=%.1f", 0.5, 0.5, 0.3),
    x = "時間",
    y = "観測値 y"
  ) +
  theme_minimal(base_family = "noto") +
  theme(legend.position = "bottom")

print(p1)

# 可視化: 決定論的部分との比較
p2 <- ggplot(test_data, aes(x = time)) +
  geom_line(aes(y = y, color = "観測値"), linewidth = 0.8) +
  geom_line(aes(y = deterministic, color = "決定論的部分"),
    linewidth = 0.8, linetype = "dashed"
  ) +
  geom_vline(xintercept = 0, linetype = "dotted", color = "red") +
  geom_vline(xintercept = 100, linetype = "dotted", color = "blue") +
  facet_wrap(~phase, scales = "free_x") +
  scale_color_manual(values = c(
    "観測値" = "steelblue",
    "決定論的部分" = "orange"
  )) +
  labs(
    title = "観測値と決定論的部分の比較",
    x = "時間",
    y = "値",
    color = ""
  ) +
  theme_minimal(base_family = "noto") +
  theme(legend.position = "bottom")

print(p2)

# 可視化: 実データ部分のみ拡大
p3 <- test_data |>
  filter(phase == "data") |>
  ggplot(aes(x = time, y = y)) +
  geom_line(linewidth = 0.8, color = "steelblue") +
  geom_vline(xintercept = 100, linetype = "dashed", color = "red") +
  labs(
    title = "実データ期間のみ（バーンイン後）",
    subtitle = "最初の急激な変化がなくなっているか確認",
    x = "時間",
    y = "観測値 y"
  ) +
  theme_minimal(base_family = "noto")

print(p3)

p1 |> ggplot2::ggsave(
  filename = "./output/debug_burnin_full.png",
  # plot = ,
  width = 19,
  height = 10,
  dpi = 75
)

p2 |> ggsave(
  filename = "./output/debug_burnin_deterministic.png",
  width = 19,
  height = 10,
  dpi = 75
)
p3 |> ggplot2::ggsave(
  filename = "./output/debug_burnin_data.png",
  width = 19,
  height = 10,
  dpi = 75
)
