print(fitSGL)



X %>% apply(., 2, mean)    # 
fitSGL$X.transform$X.means # 
X %>% apply(., 2, var)    # 
fitSGL$X.transform$X.scale # 

X_tst = matrix(rnorm(n * p, mean = 3), ncol = p, nrow = n) %>% scale
y_tst = (X_tst %*% beta + 0.1*rnorm(n)) %>% scale

a <- SGL::predictSGL(newX = X_tst, x = fitSGL, lam = c(1:20))
a
plot(fitSGL$lambdas)
plot(y_tst,a[,20])

