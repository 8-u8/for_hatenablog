# この記事も！
[R Advent Calendar 22日目の記事ではありません！](https://qiita.com/advent-calendar/2019/rlang)

記事は書いてます！読後メモも書いてます！でもしょうがない。問題にぶち当たったので。

## どんな問題？
Rの`glmnet::cv.glmnet()`関数で実行するL1正則化回帰(Lasso)において、  
`set.seed()`でシード値を固めても、選択される変数にばらつきが生じる

## 原因は？
Rでは`set.seed()`の効力は同時実行に限られる。  
つまり`set.seed()`と`glmnet::cv.glmnet()`が同時に実行されるような実装をしないと、  
変数選択の結果がぶれます……かなしい……

## 結果は？
githubにあげました♨

<!-- more -->

## 問題設定
下記のようにダミーデータを作ります。  
諸事情で説明変数も目的変数も2値のデータでを設定します。  

## Lassoの変数選択
Lassoは皆さんご存知の通り、ざっくり言えば「予測精度のために必要のない変数のパラメータを0にする」ことで、変数の選択を行います。  
ただ、この「0になる変数」は、ある程度までいくと「ランダム」に選ばれます((カステラ本とかにも書いている))。  
説明のためのモデル、すなわち、回帰係数を使って「この変数が重要そうですね」などという物を使う場合、  
このランダム性は厄介です。  
これはLasso回帰の実装アルゴリズムの性質の一つなので、この点を制御して同じ結果が再現できることは重要です。  
というわけで、その原因を探しに行きましょう。結果は`set.seed()`

### 実験データ生成
今回は5000個、60個のデータでやってみます。  
理由は気持ちの問題。
今回は完全にランダムに変数を作るのは説明変数にとどめて、目的変数は説明変数をもとに「作ります」。  
つまり、正解になるパラメータも設定して、それを変換せしめることで目的変数を設計します。

```r
library(glmnet)
library(tidymodels)
library(tidyverse)

# 説明変数の設計。
X <- matrix(0, 5000, 60)
p=1
for(i in 1:ncol(X)){
  # p <- runif(1)
  while(p >= 0.5){
    set.seed(1234) # 実は伏線です。
    p <- runif(1)
  }
  X[, i] <- rbinom(length(X[, i]), 1, p)
}

# 目的変数の作成
X <- X %>% data.matrix()

# 「正解となるパラメータ」の作成。
set.seed(1234);obs_weights <- abs(rnorm(60, 0, 1)) %>% data.matrix()
obs_weights[obs_weights<=0.6] <- 0

# 「正解データ」の作成
y <- numeric(5000)
for(i in 1:5000){
  y[i]  <- t(obs_weights) %*%  X[i, ]
  # print(y[i])
  if(y[i] >= 10){
    y[i] <- 1
  }else{
    y[i] <- 0
  }
}

# アウトプット
UseData   <- data.frame(ID=c(1:5000), Var = X, y = y)
write.csv(UseData, "UseData.csv", row.names = FALSE)
```

### バリデーション設計
まあ諸事情ですよね。
`tidymodels`に含まれるパッケージ`rsample`を使うと、かっこよくtrain-test splitが設計できます。

```r
# ここも伏線です。
set.seed(1234);SplitData <- rsample::initial_split(UseData, p = 0.8)

train <- rsample::training(SplitData) 
test  <- rsample::testing(SplitData) # じつは使わないんですけどね。

print((train$ID %>% head)) # 分割のされ方の確認。
print((test$ID %>% head))  

# glmnetに突っ込むためにデータ構造を変える。

use_y     <- train$y
use_Model <- train %>% 
  dplyr::select(-y, -ID) %>% 
  data.matrix()
```

### Lasso実行
`glmnet`では線形モデルに罰則を付与する形で正則化回帰を行います。  
Lassoを実行したい場合、`glmnet::cv.glmnet()`で正則化項の重みパラメータ`alpha`を1にします。  
Ridgeを実行したい場合は0にして、Elastic netで無双したいなら好きにしたらいいと思います。
罰則の強さ`lambda`は`cv.glmnet()`内でガリガリと変えてやってくれるので、最終的に最小の`lambda`を選択すれば精度は基本的にまともになるかなと思います。

今回は変数選択のパターンを固定できないか問題の解決なので、`cv.glmnet()`を10回、まずは独立に回して横に並べてみましょう。

```r
output_test <- matrix(0, 61, 100)
set.seed(1234)
# 300回実行。
for(j in 1:100){
  lasso_model <- glmnet::cv.glmnet(x = use_Model, y = use_y, nfolds = 4, alpha = 1,
                                 lower.limits = 0, type.measure = 'auc', family = 'binomial')
  output_test[, j] <- glmnet::coef.cv.glmnet(lasso_model) %>% as.vector()
}
## ぶれますねぇ！
output_test[1:10,1:4]
#                [,1]        [,2]         [,3]         [,4]
# [1,]  -32.40010491 -35.3814624 -25.83707130 -33.86445809
# [2,]    3.48632160   3.8494744   2.69906946   3.66436395
# [3,]    0.08530562   0.0833281   0.07277408   0.08476497
# [4,]    3.45787943   3.8050349   2.67709818   3.62971749
# [5,]    7.02163216   7.6698726   5.59719999   7.33967681
# [6,]    0.23253162   0.2870704   0.11419004   0.25899391
# [7,]    0.00000000   0.0000000   0.00000000   0.00000000
# [8,]    0.15083996   0.1689927   0.10728222   0.15983828
# [9,]    0.10452582   0.1416395   0.02254697   0.12268253
# [10,]   0.00000000   0.0000000   0.00000000   0.00000000


```
推定値がぶれました。`for`文の前でシードを固めてもあまり意味はないようです。   
紙面の都合上アレですが、データ全体で見ると、0として変数が選ばれている項目も変わってきたりします。  
そこで、`for`文内の各ステップで同じシード値で固めて回してみます。

```r
# jごとに同じseedを持ってくる
output_test_s１trict <- matrix(0,61,100)
for(j in 1:100){
  # 関数実行前にseed実行
  set.seed(1234)
  lasso_model <- glmnet::cv.glmnet(x = use_Model, y = use_y, nfolds = 4, alpha = 1,
                                   lower.limits = 0, type.measure = 'auc', family = 'binomial')
  output_test_strict[, j] <- glmnet::coef.cv.glmnet(lasso_model) %>% as.vector()
}
output_test_strict[1:10,1:4]

#                [,1]         [,2]         [,3]         [,4]
# [1,]  -40.26466421 -40.26466421 -40.26466421 -40.26466421
# [2,]    4.44789601   4.44789601   4.44789601   4.44789601
# [3,]    0.07437219   0.07437219   0.07437219   0.07437219
# [4,]    4.36233295   4.36233295   4.36233295   4.36233295
# [5,]    8.73281140   8.73281140   8.73281140   8.73281140
# [6,]    0.37811074   0.37811074   0.37811074   0.37811074
# [7,]    0.00000000   0.00000000   0.00000000   0.00000000
# [8,]    0.19808327   0.19808327   0.19808327   0.19808327
# [9,]    0.20536557   0.20536557   0.20536557   0.20536557
# [10,]   0.00000000   0.00000000   0.00000000   0.00000000
```

ぶれませんねぇ。

## で？
結局、`set.seed()`と`cv.glmnet()`を一緒に実行すれば結果を再現できることがわかりました。  
これは`glmnet`パッケージというよりはRのシード設定の仕様の話なので、実装上気をつけようね！という話にしかならないかなあと思います……  
さらに言えば「実装上選択される変数は(突き詰めると)ランダムになる」という実装上の性質は回避できていないので、  
例えば「この変数に影響を与えている変数を選ぼう！」みたいなことをすると、場合によっては再現性のない結果になる、ということに変わりはありません。  
幸いにも、回帰係数のパラメータが大きく変動するということはなく「0になったりならなかったりしろ」的な規則性までには絞られるので、何回かサンプリングを行い、平均をとるなどのような、ちょっとベイズっぽい的アプローチで、パラメータを分布として表現するみたいな方針が、実務上アリになるのかもなあと思っています。  
結局制約つき回帰であることに代わりはないので、例えば`rstan`でベイズモデルとしてLassoを実装すればよい、という可能性もありですかね。