library(rstan)
library(palmerpenguins)
library(tidyverse)
library(lme4)
library(lmerTest)

stan_filepath <- "source/hierarchical_stan.stan"

usedata <- penguins %>% 
  na.omit()

stan_params <- list(
  N = nrow(usedata),
  J = 3,
  grp = as.numeric(usedata$species),
  X = usedata$flipper_length_mm,
  y = usedata$bill_length_mm
)


stan_model <- rstan::stan(file = stan_filepath, data = stan_params, seed = 42,
                          iter = 10000, warmup = 1000, chains = 3)
result <- summary(stan_model)$summary

glmm_model <- lmerTest::lmer(bill_length_mm ~ flipper_length_mm + (1 + flipper_length_mm|species),
                             data = usedata)


usedata$y_pred_glmm <- fitted(glmm_model)
usedata$y_pred_beyes <- result[grep("y_pred", row.names(result)), "mean"]

g <- ggplot2::ggplot(usedata, aes(x = flipper_length_mm, y = bill_length_mm))+
     geom_point(aes(group = species, color = species)) + 
     geom_smooth(aes(group = species, color = species),
                 method = "lm", se = F) + 
     geom_smooth(aes(y = y_pred_glmm, color = species), linetype = "dashed") + 
     geom_smooth(aes(y = y_pred_beyes, color = species), linetype = "twodash")

plot(g)
Date <- Sys.Date()
graph_name <- paste0("output/",Date,"_plot_penguins_regression.png")
ggsave(graph_name)