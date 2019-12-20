library(lme4)
library(glmmML)
library(tidyverse)
set.seed(1234)

x <- c(abs(rnorm(20, 3, 4)),
       abs(rnorm(30, 0, 1)),
       abs(rnorm(50, 6, 4))
       )
cat <- c(rep(1,20), rep(2,30), rep(3,50))
y <- numeric(100)
gam <- numeric(100)
for(i in 1:20){
  gam[i] <- rgamma(1, shape = 4 * x[i]) + 0
  y[i]   <- rpois(1, gam[i])
}
for(i in 21:30){
  gam[i] <- rgamma(1, shape =  4 * x[i]) + 5.0
  y[i]   <- rpois(1, gam[i])
}
for(i in 31:50){
  gam[i] <- rgamma(1, shape = 4*x[i]) + 10
  y[i]   <- rpois(1, gam[i])
}

usedata <- data.frame(y = y, x = x, cat = cat)

usedata %>% summary

usedata$y %>% var   # 96.00919
usedata$y %>% mean  # 6.03

model_pois <- glm(y ~ x, data = usedata, family = "poisson")
summary(model_pois)

model_lme4 <- lme4::glmer.nb(y ~ x + (x|cat) + (1|cat), data = usedata)
summary(model_lme4)

result <- data.frame(res_lme4 = expm1(predict(model_lme4)),
                     res_pois = expm1(predict(model_pois)),
                     y        = usedata$y,
                     cat      = usedata$cat)
plot_pois <- ggplot2::ggplot(data = result, aes(x = res_pois, y)) + geom_point(color = cat)
plot_pois

plot_lme4 <- ggplot2::ggplot(data = result, aes(x = res_lme4, y)) + geom_point(color = cat)
plot_lme4_fix <- plot_lme4 + xlim(c(0,40))


ggsave(plot_lme4    , filename = "plot_lme4.png", device = "png", width = 7, height = 7)
ggsave(plot_lme4_fix, filename =  "plot_lme4_fix.png", device = "png", width = 7, height = 7)
ggsave(plot_pois, filename =  "plot_pois.png", device = "png", width = 7, height = 7)



ぽ# Call:
#   glm(formula = y ~ x, family = "poisson", data = usedata)
# 
# Deviance Residuals: 
#   Min      1Q  Median      3Q     Max  
# -3.808  -3.337  -2.759   0.787  15.643  
# 
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)  1.98627    0.05586  35.557  < 2e-16 ***
#   x           -0.05012    0.01118  -4.484 7.34e-06 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for poisson family taken to be 1)
# 
# Null deviance: 1233.5  on 99  degrees of freedom
# Residual deviance: 1211.7  on 98  degrees of freedom
# AIC: 1411.3
# 
# Number of Fisher Scoring iterations: 7


# Generalized linear mixed model fit by maximum likelihood (Laplace Approximation) ['glmerMod']
# Family: Negative Binomial(7.0696)  ( log )
# Formula: y ~ x + (1 | cat)
# Data: usedata
# 
# AIC      BIC   logLik deviance df.resid 
# 323.2    333.7   -157.6    315.2       96 
# 
# Scaled residuals: 
#   Min       1Q   Median       3Q      Max 
# -1.69248 -0.13224 -0.03589 -0.01440  2.13598 
# 
# Random effects:
#   Groups Name        Variance Std.Dev.
# cat    (Intercept) 32.78    5.726   
# Number of obs: 100, groups:  cat, 3
# 
# Fixed effects:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)  -2.3935     3.6930  -0.648    0.517    
# x             0.3068     0.0376   8.160 3.35e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#   (Intr)
# x -0.070