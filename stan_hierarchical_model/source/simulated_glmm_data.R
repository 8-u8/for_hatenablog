library(lme4)
library(tidyverse)
options(bitmapType="cairo")
# データ生成
set.seed(42)
# モデル構造。
form <- y ~ 1 + X1 + X2 + (1+X2| grp)
simulate_data <- lme4::mkDataTemplate(formula = form, nGrps = 5 , nPerGrp = 500, rfunc = "rnorm")

# パラメータの箱を作る
params <- lme4::mkParsTemplate(formula = form, data = simulate_data)
params$beta[] <- c(0.1, 0.5, 0.7)

# 変量効果の分散共分散行列を定義する。
random_effect <- matrix(c(1.0, 0.3,
                          0.3, 1.0),2,2)
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


g <- ggplot2::ggplot(simulate_data, aes(x = X2, y = y$sim_1))+
  # scatter plot
  geom_point(aes(group = grp, color = grp))

plot(g)