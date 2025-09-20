# use libraries
library(tidyverse)
library(foreign)
library(AER)
library(stargazer)
library(sem) # 二段階最小二乗法がある
library(momentfit) # 一般化モーメント法
library(REndo) # Internal Instrumental Variable Method
set.seed(20231212)

mroz_rawdata <- read.dta("http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta")

mroz_usedata <- mroz_rawdata |>
  dplyr::mutate(log_wage = log(wage)) |>
  dplyr::select(wage, log_wage, educ, exper, fatheduc, motheduc) |>
  dplyr::filter(!is.na(wage))
  
psych::cor.plot(mroz_usedata)

# 普通の重回帰
lm_model <- lm(
  log(wage) ~ educ + fatheduc + motheduc,
  data = mroz_usedata)


# 設定：操作変数としてfatheduc/motheducを採用する
# 二段階最小二乗法
tls_first <- lm(educ ~ fatheduc + motheduc, data = mroz_usedata)
mroz_usedata <- mroz_usedata |>
  dplyr::mutate(educ_fitted = fitted(tls_first))
tls_second <- lm(log_wage ~ educ_fitted, data = mroz_usedata)

# 一般化モーメント法
## モーメント条件の関数
gmm_model <- momentfit::momentModel(
  log(wage) ~ educ, educ ~ fatheduc + motheduc,
  data = mroz_usedata
)

gmm_fit <- momentfit::gmmFit(gmm_model)
gmm_fit

# latent instrumental variable
IIV_model <- REndo::latentIV(
  log(wage) ~ educ,
  optimx.args = list(itnmax = 50000),
  data = mroz_usedata,
  )

summary(lm_model)
summary(tls_first)
summary(tls_second)
gmm_fit
summary(IIV_model)

