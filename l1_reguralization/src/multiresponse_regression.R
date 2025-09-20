library(glmnet)

data("MultiGaussianExample")

X  <- MultiGaussianExample$x

# multiple response variables
y <- MultiGaussianExample$y

dim(X) # 100 20
dim(y) # 100 4

model <- glmnet(X, y, family = "mgaussian", alpha = 0.5)

plot(model, xvar = "lambda", label = TRUE, type.coef = "coef")


# evaluate
y_pred <- predict(model, X, s = min(model$lambda))[,,1]

rmse <- function(y, y_pred) {
  sqrt(mean((y - y_pred)^2))
}

mape <- function(y, y_pred) {
  mean(abs(y - y_pred)/ abs(y))
}

for (i in 1:4) {
  print(paste("simplified Rsq: ", cor(y[, i], y_pred[, i])^2))
  print(paste("RMSE: ", rmse(y[, i], y_pred[, i])))
  print(paste("MAPE: ", mape(y[, i], y_pred[, i])))
}


coefs <- coef(model, s = min(model$lambda))
coefs_mat <- do.call(cbind, lapply(coefs, as.matrix))
colnames(coefs_mat) <- paste0("y", 1:4)
coefs_mat
