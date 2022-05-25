library(tidyverse)
library(lubridate)
library(minpack.lm) # fit non-linear regression
library(investr) # predict non-linear model.
options(bitmapType = "cairo")
# define functions
## custom logistic curve.
logistic_curve <- function(X, const, alpha, beta, d){
    model <- (const / (1 + exp(alpha + beta * X))) + d
    return(model)
}

## calculate the residuals of logistic curve model.
resid <- function(par, X, Y){
    const  <- par[1]
    alpha  <- par[2]
    beta   <- par[3]
    d      <- par[4]

    model  <- logistic_curve(X, const, alpha, beta, d)
    resid  <- (Y - model)^2
    return(resid)
}

# simulate data.
X <- sort(rlnorm(1000, 0, 1))
Y <- logistic_curve(X, max(X), 3, -0.56, 0) + rnorm(1000, 0, 10)

usedata <- data.frame(X = X, Y = Y) |> 
    arrange(X)

# fit the model.
## setting parmeters.
nls_params <- list(
    start = c(const = 0, alpha = 0, beta = -0.1, d = 0),
    upper = c(Inf, Inf, 0, Inf),
    lower = c(0, 0, -Inf, 0),
    X = usedata$X,
    Y = usedata$Y
)

## model fit.
model <- nlsLM(Y ~ logistic_curve(X, const, alpha, beta, d), 
                data = usedata, 
                start = nls_params$start,
                upper = nls_params$upper,
                lower = nls_params$lower)


summary(model)

## visualize.
pred <- predFit(model,
                interval = "confidence", 
                level = 0.95) |> 
            as.data.frame() |> 
            dplyr::mutate(X = usedata$X)



g <- ggplot2::ggplot(data = usedata, aes(x = X, y = Y)) + 
    ggplot2::geom_point() +
    ggplot2::geom_ribbon(data = pred, aes(x = X, ymin = lwr, ymax = upr),
                         alpha = 0.5,fill = "grey70") + 
    ggplot2::geom_line(data = pred, aes(x = X, y = fit), size = 2) 
g

