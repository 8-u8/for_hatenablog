## init
seed(1234)
x1 <- rnorm(100,0,1)

## multico_generator
multico_regressor <- function(x2_std = 100,
                              x1 = x1,
                              beta1 = 0.4,
                              beta2 = 0.3,
                              intercept = 1.0){
  x2 <- x1 + rnorm(100, 0, x2_std)
  y  <- beta1*x1 + beta2 * x2 + intercept + rnorm(100, 0, 0.5)
  print(paste0(cat("correlation of x1 and x2: \n"),round(cor(x1, x2), digits = 3)))
  cat(c("------------------------------------ \n"))
  usedata <- data.frame(y = y, 
                      x1 = x1,
                      x2 = x2)

  model <-  lm(y~., data = usedata)
  cat("true parameters are \n")
  print(paste0(c(intercept, beta1, beta2)))
  cat(c("------------------------------------\n", "coefficients are \n"))
  print(round(summary(model)$coefficients[,1], digits = 3))
  cat(c("------------------------------------\n", "standard error are \n"))
  print(round(summary(model)$coefficients[,2], digits = 3))
  cat(c("------------------------------------ \n"))
}


params <- c(100, 10, 1, 0.5, 0.1)
for(i in params){
  cat(paste0("\n-*-*-*-*-* x2_std = ",i," *-*-*-*-*-*- \n"))
  multico_regressor(x2_std = i, x1 = x1)
  cat(paste0("-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- \n"))
}

