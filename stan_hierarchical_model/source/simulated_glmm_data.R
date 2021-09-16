library(lme4)
library(tidyverse)
options(bitmapType="cairo")
# データ生成
set.seed(42)
# モデル構造。
form <- y ~ 1 + X1 + X2 + (1+X2| grp)
simulate_data <- lme4::mkDataTemplate(formula = form, nGrps = 5 , nPerGrp = 1000,
                                      rfunc = "rnorm", mean=0, sd = 0.4)

# パラメータの箱を作る
params <- lme4::mkParsTemplate(formula = form, data = simulate_data)
params$beta[] <- c(0.6, 0.1, 1.7) # fixed effect parameters

# 変量効果の分散共分散行列を定義する。
random_effect <- matrix(c(1.0, 0.7,
                          0.7, 1.0),2,2)
params$theta[] <- lme4::Vv_to_Cv(lme4::mlist2vec(random_effect))

simulate_data$y <- simulate(form, newdata = simulate_data, newparams = params, family = "gaussian")

# modeling
model1 <- lm(y$sim_1~X1+X2 ,data = simulate_data)
summary(model1)

model2 <- lme4::lmer(y$sim_1 ~ X1 + X2 + (1 | grp), data = simulate_data)
summary(model2)

model3 <- lme4::lmer(y$sim_1 ~ X1 + X2 + (X2 | grp), data = simulate_data)
summary(model3)

model4 <- lme4::lmer(y$sim_1 ~ X1 + X2 + (1 + X2 | grp), data = simulate_data)
summary(model4)

anova(model4,model3,model2, model1)


simulate_data$lm_fitted <- fitted(model1)
simulate_data$glmm_fitted <- fitted(model4)

g <- ggplot2::ggplot(simulate_data, aes(x = X2, y = y$sim_1))+
  # scatter plot
  geom_point(aes(group = grp, color = grp))+
  # fitted value from lm model
  geom_smooth(aes(group = grp, color = grp),
              method = "lm", se = F) + 
  # geom_smooth(aes(y = lm_fitted, color = grp)) + 
  # generated value from hierarchical bayes model.
  geom_smooth(aes(y = glmm_fitted, color = grp), linetype = "twodash")


plot(g)
