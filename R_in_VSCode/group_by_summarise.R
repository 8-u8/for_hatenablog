install.packages("palmerpenguin")

library(palmerpenguins)
library(tidyverse)
library(tidylog)

data(penguins)

penguins |>
  dplyr::summarise(
    mean_bill_length = mean(bill_length_mm, na.rm = TRUE),
    sd_bill_length = sd(bill_length_mm, na.rm = TRUE),
    .by = species
)
