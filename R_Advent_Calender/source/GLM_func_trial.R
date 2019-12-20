library(tidyverse)
set.seed(1234)

UseData <- matrix(0,300,10) %>% data.frame()
for(i in 1:ncol(UseData)) {
  UseData[,i] <- runif(nrow(UseData)) + rpois(nrow(UseData), rgamma(nrow(UseData),shape = 1))
}
glm_data <- UseData %>% scale() %>% data.frame()
fact <-  3 * glm_data$X10 + 6 * glm_data$X3 + 2 * glm_data$X5
fact <-1/(1 + 3*exp(-fact))

glm_data$y <- 0
for(i in 1:nrow(glm_data)){
  glm_data$y[i] <- rbinom(1, 1, fact[i])
}


glm_data <- glm_data %>% 
   dplyr::arrange(y)

glm_model <- glm(y ~ . ,data = glm_data, family = binomial("logit"))
glm_model %>% summary

# Call:
#   glm(formula = y ~ ., family = binomial("logit"), data = glm_data)
# 
# Deviance Residuals: 
#   Min        1Q    Median        3Q       Max  
# -2.79723  -0.17374  -0.02177   0.01670   2.18644  
# 
# Coefficients:
#               Estimate Std. Error z value Pr(>|z|)    
# (Intercept) -1.16230    0.30015  -3.872 0.000108 ***
# X1           0.06391    0.28657   0.223 0.823517    
# X2          -0.08146    0.25308  -0.322 0.747532    
# X3           6.42789    1.02494   6.271 3.58e-10 ***
# X4           0.39690    0.26543   1.495 0.134826    
# X5           2.24315    0.39967   5.612 1.99e-08 ***
# X6           0.27260    0.29696   0.918 0.358641    
# X7          -0.08142    0.23464  -0.347 0.728589    
# X8           0.05814    0.27094   0.215 0.830100    
# X9           0.04441    0.28057   0.158 0.874241    
# X10          3.32751    0.54027   6.159 7.32e-10 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for binomial family taken to be 1)
# 
# Null deviance: 392.051  on 299  degrees of freedom
# Residual deviance:  95.277  on 289  degrees of freedom
# AIC: 117.28
# 
# Number of Fisher Scoring iterations: 8



glm_plot <- ggplot2::ggplot(data = glm_data, aes(x = X3, y = y)) +
  geom_point()+
  stat_smooth(method = "glm",method.args = list(family = "binomial"),se = F)  
glm_plot

ggsave(glm_plot, filename = "glm_plot.png", device = "png", width = 7, height = 7)
