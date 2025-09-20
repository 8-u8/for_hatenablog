#  基本的思考
## 問題: glmnetの推定がブレる問題の検証
## 再現: 5000obs, 60varsのデータ構造に対するfit
## 方法: seedを固めて実行する。

library(glmnet)
library(tidymodels)
library(tidyverse)


### 乱数生成次はset.seedを並列に実行しないと固定されない。
X <- matrix(0, 5000, 600)
p <- 1
for (i in 1:ncol(X)) {
  # p <- runif(1)
  while (p >= 0.5) {
    set.seed(1234)
    p <- runif(1)
  }
  X[, i] <- rbinom(length(X[, i]), 1, p)
}

X <- X |> data.matrix()
set.seed(1234)
obs_weights <- abs(rnorm(600, 0, 100)) |> data.matrix()
obs_weights[obs_weights <= 0.6] <- 0
y <- numeric(5000)
for (i in 1:5000) {
  y[i] <- t(obs_weights) %*% X[i, ]
  print(y[i])
  if (y[i] >= 6000) {
    y[i] <- 1
  } else {
    y[i] <- 0
  }
}

y |> summary()

UseData <- data.frame(ID = c(1:5000), Var = X, y = y)
UseData |> summary()

write.csv(UseData, "./Lasso_Trial/out/UseData.csv", row.names = FALSE)
