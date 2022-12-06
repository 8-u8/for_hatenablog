library(tidyverse)
data("trees")

head(trees, n = 10)

# Girth Height Volume
# 1    8.3     70   10.3
# 2    8.6     65   10.3
# 3    8.8     63   10.2
# 4   10.5     72   16.4
# 5   10.7     81   18.8
# 6   10.8     83   19.7
# 7   11.0     66   15.6
# 8   11.0     75   18.2
# 9   11.1     80   22.6
# 10  11.2     75   19.9
model_lm <- lm(Girth ~ Height, data = trees)
summary(model_lm)
mean(model_lm$residuals)

use_trees <- trees %>%
  scale() %>% 
  as.data.frame()

model_lm_scaled <- lm(Girth ~ Height, data = use_trees)
summary(model_lm_scaled)

# Call:
#   lm(formula = Girth ~ Height, data = use_trees)
# 
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -1.35068 -0.61199 -0.02274  0.87472  1.44621 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)   
# (Intercept) 1.890e-16  1.561e-01   0.000  1.00000   
# Height      5.193e-01  1.587e-01   3.272  0.00276 **
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.8692 on 29 degrees of freedom
# Multiple R-squared:  0.2697,	Adjusted R-squared:  0.2445 
# F-statistic: 10.71 on 1 and 29 DF,  p-value: 0.002758



plot_point <- ggplot2::ggplot(data = trees, aes(x = Height, y = Girth)) +
  ggplot2::geom_point() + 
  ggplot2::stat_smooth(method = "lm", se = F)
plot_point

plot_point_scaled <- ggplot2::ggplot(data = use_trees, aes(x = Height, y = Girth)) +
  ggplot2::geom_point() + 
  ggplot2::stat_smooth(method = "lm", se = F)
plot_point_scaled
ggsave(plot_point_scaled, filename = "lm_plot.png", device = "png", width = 7, height = 7)

# Call:
#   lm(formula = Girth ~ Height, data = trees)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -4.2386 -1.9205 -0.0714  2.7450  4.5384 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)   
# (Intercept) -6.18839    5.96020  -1.038  0.30772   
# Height       0.25575    0.07816   3.272  0.00276 **
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 2.728 on 29 degrees of freedom
# Multiple R-squared:  0.2697,	Adjusted R-squared:  0.2445 
# F-statistic: 10.71 on 1 and 29 DF,  p-value: 0.002758