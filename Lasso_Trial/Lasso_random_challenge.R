#  基本的思考
## 問題: glmnetの推定がブレる問題の検証
## 再現: 5000obs, 60varsのデータ構造に対するfit
## 方法: seedを固めて実行する。

library(glmnet)
library(tidymodels)
library(tidyverse)

# 完全に固めきった疑似乱数生成。
#source("/home/u0-0/Desktop/for_hatenablog/Lasso_Trial/Data_Creation.R", encoding='utf-8')
UseData2 <- readr::read_csv("/home/u0-0/Desktop/for_hatenablog/Lasso_Trial/UseData.csv")

# splitはこうして確実に同じvalidationを行う。
set.seed(1234);SplitData <- rsample::initial_split(UseData, p = 0.8)

train <- rsample::training(SplitData) 
test  <- rsample::testing(SplitData)

print((train$ID %>% head))
print((test$ID %>% head))

### 
use_y     <- train$y
use_Model <- train %>% 
  dplyr::select(-y, -ID) %>% 
  data.matrix()ｚ

output_test <- matrix(0, 61, 10)
# 300回実行。
for(j in 1:10){
  print(paste0(j, 'th trial'))
  lasso_model <- glmnet::cv.glmnet(x = use_Model, y = use_y, nfolds = 4, alpha = 1,
                                 lower.limits = 0, type.measure = 'auc', family = 'binomial')
  output_test[, j] <- glmnet::coef.cv.glmnet(lasso_model) %>% as.vector()
}
## ぶれますねぇ！
output_test[1:10,1:4]

# jごとに同じseedを持ってくる
output_test_strict <- matrix(0,61,10)
for(j in 1:10){
  # 関数実行前にseed実行
  set.seed(1234)
  print(paste0(j, 'th trial'))
  lasso_model <- glmnet::cv.glmnet(x = use_Model, y = use_y, nfolds = 4, alpha = 1,
                                   lower.limits = 0, type.measure = 'auc', family = 'binomial')
  output_test_strict[, j] <- glmnet::coef.cv.glmnet(lasso_model) %>% as.vector()
}
## こういうことか
output_test_strict[1:10,1:4]
