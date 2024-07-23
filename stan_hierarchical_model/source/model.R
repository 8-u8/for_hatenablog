# load libraries
library(rstan)
library(palmerpenguins)
library(tidyverse)
library(lme4)
library(lmerTest)
options(bitmapType = "cairo")

# map estimator
# map <- function(z) {
#   tmp <- density(z)
#   out <- tmp$x[which.max(density(z)$y)]
# }

# stan code path
stan_filepath <- "./source/hierarchical_stan.stan"

# define data
# to simple, we omit NA rows.
usedata <- palmerpenguins::penguins |>
  na.omit()

# input info for data block in stan code.
stan_params <- list(
  N = nrow(usedata),
  J = 3,
  grp = as.numeric(usedata$species),
  X = usedata$flipper_length_mm,
  y = usedata$bill_length_mm
)

# model run
stan_model <- rstan::stan(
  file = stan_filepath, data = stan_params, seed = 42,
  iter = 1000, warmup = 100, chains = 3
)

# glmm model run (for comparison)
glmm_model <- lmerTest::lmer(
  bill_length_mm ~ flipper_length_mm + (1 + flipper_length_mm | species),
  data = usedata
)

# fitted value output
usedata$y_pred_glmm <- fitted(glmm_model)
result <- summary(stan_model)$summary
y_pred <- result[grep("y_pred", row.names(result)), "mean"]
# y_pred_map <- apply(y_pred, 1, map)
# result[grep("y_pred", row.names(result)), "mean"]
usedata$y_pred_beyes <- y_pred

# visualization
g <- ggplot2::ggplot(usedata, aes(x = flipper_length_mm, y = bill_length_mm)) +
  # scatter plot
  geom_point(aes(group = species, color = species)) +
  # hole regression
  geom_smooth(method = "lm", se = F, color = "grey", formula = y ~ x) +
  # single linear regression model for each species.
  geom_smooth(aes(group = species, color = species),
    method = "lm", se = F, linetype = "dashed"
  ) +
  # fitted value from GLMM model.
  geom_smooth(aes(y = y_pred_glmm, color = species)) +
  # generated value from hierarchical bayes model.
  geom_smooth(aes(y = y_pred_beyes, color = species), linetype = "twodash")

plot(g)
Date <- Sys.Date()
graph_name <- paste0("output/", Date, "_plot_penguins_regression.png")
ggsave(graph_name)

saveRDS(stan_model, "./doc/stan_model.rds")