library(rstan)
library(tidyverse)

N <- 10
M <- c(1:N)
X <- rbinom(N, size = M, prob = 0.5)

stan_data <- list(
  N = N, 
  M_max = 40,
  X = X
)

model <- rstan::stan(file = "02_stan_code.stan", data = stan_data, verbose = TRUE)
model

