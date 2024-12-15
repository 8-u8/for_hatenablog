library(tidylog)
library(psych)

data(bfi)

bfi_to_pca <- bfi |> 
  dplyr::select(-gender, -education, -age)


psych::fa.parallel(
  bfi_to_pca
)
