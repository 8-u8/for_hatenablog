# load libraries
library(SGL)
library(tidyverse)

# dummy data creation
set.seed(1)
n = 500; p = 50; size.groups = 12
index <- ceiling(1:p / size.groups)
X = matrix(rnorm(n * p, mean = 0, sd = 2), ncol = p, nrow = n)
for(k in 1:ncol(X)){
  rand_param <- runif(1, min = -15, max = 15)
  beta = rnorm(n = ncol(X), mean = 0, sd = 1) * rlnorm(ncol(X), meanlog = rand_param)
}
plot(beta)
y = X %*% beta + 0.1*rnorm(n)
y <- scale(y)
X <- scale(X)
plot(y)
sampledata <- data.frame(X = X, y = y)

# modeling SGL
fit <- list(x=X, y=y)
lambda <- sort(abs(rnorm(2000,mean = 0, sd = 0.0005)),decreasing = TRUE)
plot(lambda)

# alpha = zero -> Group Lasso
fitSGL_zero_alpha <- SGL::SGL(data = fit,
                              index = index,
                              type = 'linear',
                              min.frac = 0.01,
                              alpha = 0,
                              verbose = TRUE,
                              thresh  = 0.1,
                              gamma = 0.4,
                              #nlam = 2000,
                              lambdas = lambda)
# alpha = one -> Normal Lasso
fitSGL_one_alpha <- SGL::SGL(data = fit,
                             index = index,
                             type = 'linear',
                             min.frac = 0.01,
                             alpha = 1,
                             verbose = TRUE,
                             thresh  = 0.1,
                             gamma = 0.4,
                             #nlam = 2000,
                             lambdas = lambda)

# alpha = 0.5 -> Sparse Group Lasso
fitSGL_half_alpha <- SGL::SGL(data = fit,
                              index = index,
                              type = 'linear',
                              min.frac = 0.01,
                              alpha = 0.5,
                              verbose = TRUE,
                              thresh  = 0.1,
                              gamma = 0.4,
                              #nlam = 2000,
                              lambdas = lambda)

result <- data.frame(X_name          = colnames(sampledata)[-51],
                     group           = index,
                     beta_nlam_200_zero   = fitSGL_zero_alpha$beta[,200],
                     beta_nlam_500_zero   = fitSGL_zero_alpha$beta[,500],
                     beta_nlam_1000_zero  = fitSGL_zero_alpha$beta[,1000],
                     beta_nlam_2000_zero  = fitSGL_zero_alpha$beta[,2000],
                     beta_nlam_200_one    = fitSGL_one_alpha$beta[,200],
                     beta_nlam_500_one    = fitSGL_one_alpha$beta[,500],
                     beta_nlam_1000_one   = fitSGL_one_alpha$beta[,1000],
                     beta_nlam_2000_one   = fitSGL_one_alpha$beta[,2000],
                     beta_nlam_200_half    = fitSGL_half_alpha$beta[,200],
                     beta_nlam_500_half    = fitSGL_half_alpha$beta[,500],
                     beta_nlam_1000_half   = fitSGL_half_alpha$beta[,1000],
                     beta_nlam_2000_half   = fitSGL_half_alpha$beta[,2000])

result %>% dplyr::select(X_name,group,contains('zero'))
result %>% dplyr::select(X_name,group,contains('one'))
result %>% dplyr::select(X_name,group,contains('half'))


write.csv(result, "output/SGL_trial_understand.csv", row.names = FALSE)

#length(fitSGL$lambdas)
val <- predictSGL(x=fitSGL,newX = X,  lam=c(1:2000))
plot(y, val[,2000])
plot(y, val[,200])
RMSE <- function(pred, obs){
  return(mean((pred - obs)^2))
}
metrics <- numeric(2000)
for(i in 1:2000){
  
  #plot(y, val[,i], main = paste0("lambda = ", fitSGL$lambdas[i]))
  print(paste0('number ',i,' lambda: ', fitSGL$lambdas[i],' RMSE is ',RMSE(val[,i],y)))
  metrics[i] <- RMSE(val[,i],y)
}
fitSGL$lambdas[grep(min(metrics),metrics)]

par(mfrow = c(1,3))
plot(metrics, fit_zero_SGL$lambdas)
plot(metrics, fit_one_SGL$lambdas)
plot(metrics, fit_half_SGL$lambdas)

