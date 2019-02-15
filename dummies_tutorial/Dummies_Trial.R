install.packages("dummies") # If you do not install package.

library(dummies)

dat <- iris

head(dat)

dummied_dat <- dummies::dummy.data.frame(dat, sep = "_", )
