# init
library(showtext)
font_add_google("Noto Sans JP", "noto")
showtext_auto()

#' 分断時系列デザインを想定した時系列データを生成する
#'
#' @param t_before 介入前の観測数
#' @param t_after 介入後の観測数
#' @param baseline ベースライン
#' @param trend トレンド
#' @param level_change 介入による水準変化
#' @param slope_change 介入による傾き変化
#' @param noise_sd ノイズの標準偏差
#' @param ar_coef 自己回帰係数（ARモデル用、0-1の範囲）
#' @param seed 乱数シード
#'
#' @return data.frame 時系列データ（time, y, intervention列を含む）
#'
#' @examples
#' # 基本的な使用例
#' data <- simulate_its_data(t_before = 20, t_after = 20, level_change = 5)
#' plot(data$time, data$y, type = "b")
#' abline(v = 20.5, col = "red", lty = 2)
#'
simulate_its_data <- function(t_before = 20,
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
  # ar_coef: 誤差項の自己回帰係数
  # y_rho: 観測値yのラグ項の係数（内生的フィードバック）

  if (ar_coef == 0) {
    # 独立なノイズ
    epsilon <- rnorm(t_total, mean = 0, sd = noise_sd)
  } else {
    # AR(1)ノイズ
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
  } else {
    # フィードバックあり: バーンイン期間を追加して定常状態から開始
    burnin <- 100 # バーンイン期間

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

    # バーンイン期間を捨てる
    y <- y_extended[(burnin + 1):(t_total + burnin)]
  }

  # データフレーム作成
  data <- data.frame(
    time = time,
    y = y,
    intervention = intervention,
    time_after = time_after
  )

  data
}


#' シミュレーションデータの可視化関数
#'
#' @param data simulate_its_data()で生成されたデータフレーム
#' @param title プロットのタイトル
#'
#' @return ggplot2オブジェクト
#'
visualize_its_data <- function(data, title = "Interrupted Time Series Data") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2パッケージが必要です。install.packages('ggplot2')で入れてください")
  }

  # 介入時点を特定
  intervention_point <- max(data$time[data$intervention == 0]) + 0.5

  # プロット作成
  p <- ggplot2::ggplot(
    data = data,
    ggplot2::aes(x = time, y = y)
  ) +
    ggplot2::geom_point(ggplot2::aes(color = factor(intervention)), size = 2) +
    ggplot2::geom_line(alpha = 0.5) +
    ggplot2::geom_vline(
      xintercept = intervention_point,
      linetype = "dashed",
      color = "red",
      linewidth = 1
    ) +
    ggplot2::scale_color_manual(
      values = c("0" = "blue", "1" = "orange"),
      labels = c("介入前", "介入後"),
      name = ""
    ) +
    ggplot2::labs(
      title = title,
      x = "時間",
      y = "観測値"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "top")

  p
}

#' モンテカルロシミュレーションの実行関数
#'
#' @param t_before 介入前の観測数
#' @param n_sim シミュレーション回数
#' @param true_params 真のパラメータのリスト
#'
#' @return data.frame 推定結果
#'
run_monte_carlo <- function(t_before, n_sim = 100, true_params) {
  t_after <- ceiling(t_before * 0.3)

  results <- purrr::map_dfr(1:n_sim, function(sim_id) {
    # パラメータをランダムに変動させる
    if (is.null(true_params$y_rho)) {
      y_rho <- runif(1, 0, 0.5)
    } else {
      y_rho <- true_params$y_rho
    }
    if (is.null(true_params$ar_coef)) {
      ar_coef <- runif(1, 0, 0.5)
    } else {
      ar_coef <- true_params$ar_coef
    }
    if (is.null(true_params$noise_sd)) {
      noise_sd <- runif(1, 0.5, 1)
    } else {
      noise_sd <- true_params$noise_sd
    }

    # データ生成
    data <- simulate_its_data(
      t_before = t_before,
      t_after = t_after,
      baseline = true_params$baseline,
      trend = true_params$trend,
      level_change = true_params$level_change,
      slope_change = true_params$slope_change,
      noise_sd = noise_sd,
      y_rho = y_rho,
      ar_coef = ar_coef,
      seed = sim_id * t_before
    ) |>
      dplyr::mutate(
        y_lag1 = dplyr::lag(y, 1),
        y_lag2 = dplyr::lag(y, 2)
      )

    # OLS推定
    ols_model <- lm(y ~ time + intervention + time_after, data = data)
    ols_coef <- coef(ols_model)
    names(ols_coef) <- c("baseline", "trend", "level_change", "slope_change")

    # OLS推定（ラグ項追加）
    ols_lag_model <- lm(
      y ~ time + intervention + time_after + y_lag1,
      data = data
    )
    ols_lag_coef <- coef(ols_lag_model)[
      c("(Intercept)", "time", "intervention", "time_after")
    ]
    names(ols_lag_coef) <- c(
      "baseline", "trend", "level_change",
      "slope_change"
    )

    # ARIMA推定（外生変数付き）
    # 変数を事前に初期化（スコープ問題を回避）
    arima_baseline <- NA
    arima_trend <- NA
    arima_level <- NA
    arima_slope <- NA

    tryCatch(
      {
        arima_model <- forecast::Arima(
          data$y,
          xreg = cbind(data$time, data$intervention, data$time_after),
          method = "ML",
          order = c(1, 0, 1) # AR(1)
        )
        arima_coef <- arima_model$coef
        # 外生変数の係数を抽出（名前が異なる場合があるので柔軟に対応）
        arima_baseline <- arima_coef[grepl(
          "intercept|Intercept", names(arima_coef)
        )][1]
        arima_trend <- arima_coef[grepl(
          "time|xreg1",
          names(arima_coef)
        )][1]
        arima_level <- arima_coef[grepl(
          "intervention|xreg2",
          names(arima_coef)
        )][1]
        arima_slope <- arima_coef[grepl(
          "time_after|xreg3",
          names(arima_coef)
        )][1]
      },
      error = function(e) {
        # エラー時はすでにNAで初期化済み
        NULL
      }
    )

    # 操作変数法（IVモデル）
    # 介入ダミーを操作変数として使用
    tryCatch(
      {
        iv_model <- ivreg::ivreg(
          y ~ time + intervention + time_after + y_lag1 |
            time + intervention + time_after + y_lag2,
          data = data, method = "OLS"
        )
        iv_coef <- coef(iv_model)[
          c("(Intercept)", "time", "intervention", "time_after")
        ]
        names(iv_coef) <- c("baseline", "trend", "level_change", "slope_change")
      },
      error = function(e) {
        iv_coef <- c(
          baseline = NA,
          trend = NA,
          level_change = NA,
          slope_change = NA
        )
      }
    )

    # 結果を返す
    data.frame(
      sim_id = sim_id,
      t_before = t_before,
      t_total = t_before + t_after,
      method = c("OLS", "OLS (Lag)", "ARIMA", "IV"),
      baseline = c(
        ols_coef[["baseline"]],
        ols_lag_coef[["baseline"]],
        arima_baseline,
        iv_coef[["baseline"]]
      ),
      trend = c(
        ols_coef[["trend"]],
        ols_lag_coef[["trend"]],
        arima_trend,
        iv_coef[["trend"]]
      ),
      level_change = c(
        ols_coef[["level_change"]],
        ols_lag_coef[["level_change"]],
        arima_level,
        iv_coef[["level_change"]]
      ),
      slope_change = c(
        ols_coef[["slope_change"]],
        ols_lag_coef[["slope_change"]],
        arima_slope,
        iv_coef[["slope_change"]]
      )
    )
  })

  results
}

#' シミュレーション結果の集約関数
#'
#' @param results run_monte_carlo()の結果
#'
#' @return data.frame 平均値と標準誤差
#'
summarize_results <- function(results) {
  results |>
    dplyr::group_by(t_total, method) |>
    dplyr::summarise(
      baseline_mean = mean(baseline, na.rm = TRUE),
      baseline_se = sd(baseline, na.rm = TRUE),
      baseline_lower = quantile(baseline, 0.05, na.rm = TRUE),
      baseline_upper = quantile(baseline, 0.95, na.rm = TRUE),
      trend_mean = mean(trend, na.rm = TRUE),
      trend_se = sd(trend, na.rm = TRUE),
      trend_lower = quantile(trend, 0.05, na.rm = TRUE),
      trend_upper = quantile(trend, 0.95, na.rm = TRUE),
      level_change_mean = mean(level_change, na.rm = TRUE),
      level_change_se = sd(level_change, na.rm = TRUE),
      level_change_lower = quantile(level_change, 0.05, na.rm = TRUE),
      level_change_upper = quantile(level_change, 0.95, na.rm = TRUE),
      slope_change_mean = mean(slope_change, na.rm = TRUE),
      slope_change_se = sd(slope_change, na.rm = TRUE),
      slope_change_lower = quantile(slope_change, 0.05, na.rm = TRUE),
      slope_change_upper = quantile(slope_change, 0.95, na.rm = TRUE),
      .groups = "drop"
    )
}

#' 結果の可視化関数
#'
#' @param summary_df summarize_results()の結果
#' @param true_params 真のパラメータ
#' @param y_rho 観測値のAR(1)係数（データ生成時に使用した値）
#'
#' @return ggplot2オブジェクト
#'
plot_monte_carlo_results <- function(summary_df, true_params, y_rho = 0) {
  # データをlong形式に変換
  plot_data <- summary_df |>
    tidyr::pivot_longer(
      cols = -c(t_total, method),
      names_to = c("parameter", ".value"),
      names_pattern = "(.+)_(mean|se|lower|upper)"
    ) |>
    dplyr::mutate(
      parameter = dplyr::case_when(
        parameter == "baseline" ~ "Baseline",
        parameter == "trend" ~ "Trend",
        parameter == "level_change" ~ "Level Change",
        parameter == "slope_change" ~ "Slope Change"
      ),
      parameter = factor(parameter,
        levels = c("Baseline", "Trend", "Level Change", "Slope Change")
      )
    )

  # 真の値を追加
  # データ生成時に (1-y_rho) でスケーリングしているため、真の値もスケーリング
  # OLS(Lag), ARIMA, IV は即時効果 = parameter * (1-y_rho) を推定
  true_values <- data.frame(
    parameter = factor(c("Baseline", "Trend", "Level Change", "Slope Change"),
      levels = c("Baseline", "Trend", "Level Change", "Slope Change")
    ),
    true_value = c(
      true_params$baseline * (1 - y_rho),
      true_params$trend * (1 - y_rho),
      true_params$level_change * (1 - y_rho),
      true_params$slope_change * (1 - y_rho)
    )
  )

  # プロット作成
  # 真の値の周辺に範囲を制限（±30%または絶対値で±5のどちらか大きい方）
  y_limits <- true_values |>
    dplyr::mutate(
      range = pmax(abs(true_value) * 1.5, 0.75),
      y_min = true_value - range,
      y_max = true_value + range
    )

  # 各パラメータの表示範囲内にデータをクリップ
  plot_data_clipped <- plot_data |>
    dplyr::left_join(
      y_limits |> dplyr::select(parameter, y_min, y_max),
      by = "parameter"
    ) |>
    dplyr::mutate(
      mean = pmax(pmin(mean, y_max), y_min),
      lower = pmax(pmin(lower, y_max), y_min),
      upper = pmax(pmin(upper, y_max), y_min)
    )

  p <- ggplot2::ggplot(
    plot_data_clipped,
    ggplot2::aes(
      x = t_total,
      y = mean,
      color = method,
      fill = method
    )
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = lower, ymax = upper),
      alpha = 0.2, color = NA
    ) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_hline(
      data = true_values, ggplot2::aes(yintercept = true_value),
      linetype = "dashed", color = "black", linewidth = 0.8
    ) +
    ggplot2::facet_wrap(~parameter, scales = "free_y", ncol = 2) +
    ggplot2::geom_blank(
      data = y_limits,
      ggplot2::aes(x = min(plot_data$t_total), y = y_min),
      inherit.aes = FALSE
    ) +
    ggplot2::geom_blank(
      data = y_limits,
      ggplot2::aes(x = min(plot_data$t_total), y = y_max),
      inherit.aes = FALSE
    ) +
    ggplot2::scale_color_manual(
      values = c(
        "OLS" = "#D55E00",
        "OLS (Lag)" = "#E69F00",
        "ARIMA" = "#56B4E9",
        "IV" = "#009E73"
      )
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        "OLS" = "#D55E00",
        "OLS (Lag)" = "#E69F00",
        "ARIMA" = "#56B4E9",
        "IV" = "#009E73"
      )
    ) +
    ggplot2::labs(
      title = "パラメータ推定結果",
      subtitle = sprintf(
        "実線: 推定値の平均, 帯: 5%%tile~95%%tile, 破線: 真の値 (y_rho=%.2f でスケーリング済)",
        y_rho
      ),
      x = "総観測数 (t_total)",
      y = "推定値",
      color = "推定方法",
      fill = "推定方法"
    ) +
    ggplot2::theme_minimal(base_family = "noto") +
    ggplot2::theme(
      legend.position = "top",
      strip.text = ggplot2::element_text(size = 14, face = "bold"),
      plot.title = ggplot2::element_text(size = 16, face = "bold")
    )

  p
}
