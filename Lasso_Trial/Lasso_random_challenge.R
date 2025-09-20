#  基本的思考
## 問題: glmnetの推定がブレる問題の検証
## 再現: 5000obs, 60varsのデータ構造に対するfit
## 方法: seedを固めて実行する。

library(glmnet)
library(tidymodels)
library(tidyverse)

# 完全に固めきった疑似乱数生成。
#source("/home/u0-0/Desktop/for_hatenablog/Lasso_Trial/Data_Creation.R", encoding='utf-8')
UseData2 <- readr::read_csv("./Lasso_Trial/out/UseData.csv")

# splitはこうして確実に同じvalidationを行う。
set.seed(1234);

SplitData <- rsample::initial_split(UseData2, prop = 0.8)

train <- rsample::training(SplitData) 
test  <- rsample::testing(SplitData)

print((train$ID |> head))
print((test$ID |> head))

### 
use_y     <- train$y
use_Model <- train |> 
  dplyr::select(-y, -ID) |> 
  data.matrix()

output_test <- matrix(0, 601, 10)
# 300回実行。
for(j in 1:10){
  print(paste0(j, 'th trial'))
  lasso_model <- glmnet::cv.glmnet(
                                    x = use_Model,
                                    y = use_y,
                                    nfolds = 4,
                                    alpha = 1,
                                    lower.limits = 0,
                                    type.measure = 'auc',
                                    family = 'binomial')
  output_test[, j] <- coef(lasso_model) |> as.vector()
}
## ぶれますねぇ！
output_test[1:10,1:4]

# jごとに同じseedを持ってくる
output_test_strict <- matrix(0, 601, 10)
for(j in 1:10){
  # 関数実行前にseed実行
  set.seed(1234)
  print(paste0(j, 'th trial'))
  lasso_model <- glmnet::cv.glmnet(x = use_Model, y = use_y, nfolds = 4, alpha = 1,
                                   lower.limits = 0, type.measure = 'auc', family = 'binomial')
  output_test_strict[, j] <- coef(lasso_model) |> as.vector()
}

output_test_strict[1:10,1:4]

# ROC曲線の確認
roc_test_X <- test |> 
  dplyr::select(-y, -ID) |> 
  data.matrix()

roc_test_y <- test$y |> 
  as.vector()

roc.glmnet(
  object = predict(lasso_model, newx = roc_test_X, s = "lambda.min"),
  newy = roc_test_y
) |> plot()

confusion.glmnet(
  object = predict(lasso_model, newx = roc_test_X, s = "lambda.min"),
  newy = roc_test_y,
  threshold = 0.5,
  family = "binomial"
)
