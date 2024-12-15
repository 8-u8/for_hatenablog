n <- 10000
r <- 4
p <- 0.3
gamma_pois_p <- p/(1-p)

# from: https://hoxo-m.hatenablog.com/entry/20151012/p1
# rgamma の引数について、scale = 1/rate
lambda_by_gamma <- rgamma(n, shape = r, rate = gamma_pois_p)
poisson_values <- sapply(lambda_by_gamma, function(lambda){rpois(1, lambda)})
nbinom_values <- rnbinom(n, size = r, prob = p)

barplot(table(poisson_values)[1:21])
barplot(table(nbinom_values)[1:21])

library(ggplot2)
df <- Reduce(rbind,
             Map(function(lambda){ data.frame(lambda, x=0:20, y=dpois(0:20, lambda))},
                 lambda_by_gamma[1:16])
             )
ggplot(df, aes(x=x, y=y, fill=lambda)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~ lambda, nrow=4)

ggplot(df, aes(x=x, y=y, fill=lambda)) + 
  geom_bar(stat="identity") + 
  theme(legend.position = "none")
