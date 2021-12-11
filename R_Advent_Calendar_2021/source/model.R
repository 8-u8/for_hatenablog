library(tidyverse)
library(palmerpenguins)
library(lme4)


# define data
# to simple, we omit NA rows.
usedata <- penguins %>% 
  na.omit()

# glmm model run (for comparison)
glmm_model <- lme4::lmer(bill_length_mm ~ flipper_length_mm + (1 + flipper_length_mm|species),
                         data = usedata)

summary(glmm_model)

# fitted value output
usedata$y_pred_glmm <- fitted(glmm_model)


# vizualize
g <- ggplot2::ggplot(usedata, aes(x = flipper_length_mm, y = bill_length_mm))+
  # scatter plot
  geom_point(aes(group = species, color = species)) +
  geom_smooth(aes(group = species, color = species),
              method = "lm", se = F, linetype= "dashed") + 
  # fitted value from GLMM model.
  geom_smooth(aes(y = y_pred_glmm, color = species))

plot(g)

Date <- Sys.Date()
graph_name <- paste0("output/",Date,"_plot_penguins_regression.png")
ggsave(graph_name)