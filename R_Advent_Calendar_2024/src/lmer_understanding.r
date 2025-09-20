library(tidylog)
library(psych)

data(bfi)

bfi_to_pca <- bfi |> 
  dplyr::select(-gender, -education, -age)

psych::fa.parallel(
  bfi_to_pca, fa = "fa"
)

fa_result <- psych::fa(
                       bfi_to_pca,
                       nfactors = 6,
                       rotate = "promax",
                       fm = "ml")

summary(fa_result)

# Factor analysis with Call: psych::fa(r = bfi_to_pca, nfactors = 6, rotate = "promax", fm = "ml")
# 
# Test of the hypothesis that 6 factors are sufficient.
# The degrees of freedom for the model is 165  and the objective function was  0.36 
# The number of observations was  2800  with Chi Square =  1013.79  with prob <  4.6e-122 
# 
# The root mean square of the residuals (RMSA) is  0.02 
# The df corrected root mean square of the residuals is  0.03 
# 
# Tucker Lewis Index of factoring reliability =  0.922
# RMSEA index =  0.043  and the 10 % confidence intervals are  0.04 0.045
# BIC =  -295.88
# With factor correlations of 
# ML1   ML2   ML3   ML5   ML4  ML6
# ML1  1.00 -0.36  0.41  0.33 -0.11 0.09
# ML2 -0.36  1.00 -0.21 -0.18  0.11 0.26
# ML3  0.41 -0.21  1.00  0.31 -0.15 0.20
# ML5  0.33 -0.18  0.31  1.00  0.03 0.28
# ML4 -0.11  0.11 -0.15  0.03  1.00 0.09
# ML6  0.09  0.26  0.20  0.28  0.09 1.00


fa_result$weights  # 因子負荷量
fa_result$scores   # 因子特点行列
