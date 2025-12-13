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
  # ノイズ生成（AR(1)モデルを考慮）
  if (ar_coef == 0) {
    # 独立なノイズ
    noise <- rnorm(t_total, mean = 0, sd = noise_sd)
  } else {
    # AR(1)ノイズ
    noise <- numeric(t_total)
    noise[1] <- rnorm(1, mean = 0, sd = noise_sd)
    for (i in 2:t_total) {
      noise[i] <- ar_coef * noise[i - 1] +
        rnorm(1, mean = 0, sd = noise_sd * sqrt(1 - ar_coef^2))
    }
  }

  # 観測値
  y <- deterministic + noise

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
  p <- ggplot2::ggplot(data = data,
                       ggplot2::aes(x = time, y = y)) +
    ggplot2::geom_point(ggplot2::aes(color = factor(intervention)), size = 2) +
    ggplot2::geom_line(alpha = 0.5) +
    ggplot2::geom_vline(xintercept = intervention_point,
                        linetype = "dashed",
                        color = "red",
                        linewidth = 1) +
    ggplot2::scale_color_manual(values = c("0" = "blue", "1" = "orange"),
                                labels = c("介入前", "介入後"),
                                name = "") +
    ggplot2::labs(title = title,
                  x = "時間",
                  y = "観測値") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "top")+
    ggplot2::theme(aspect.ratio = 1)

  p
}