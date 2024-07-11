# 真の構造
x1 <- rnorm(100, 0, 1)
x2 <- rnorm(100, 0, 1)
x3 <- rnorm(100, 0, 1)

y <- 0.3 + 0.45 * x1 - 0.1*x2 + 0.22*x3 + rnorm(100, 0, 0.1)

usedata <- data.frame(
  y = y,
  x1 = x1,
  x2 = x2,
  x3 = x3
)

# モデル
model <- lm(y ~ ., family = "gaussian", data = usedata)
summary(model)
sigma_hat <- vcov(model)
