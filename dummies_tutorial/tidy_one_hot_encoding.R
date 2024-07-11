library(palmerpenguins)
library(tidyverse)

## one hot encoding on tidyverse.
data("penguins")

penguins_raw

species_dummies <- penguins_raw %>% 
  dplyr::mutate(value = 1) %>% 
  tidyr::pivot_wider(
    names_from = "Species",
    values_from = "value", 
    values_fill = 0
  )

data("mtcars")

a <- mtcars %>% 
  dplyr::mutate(
    car_names = row.names(.),
    dummy_value = 1) %>% 
  tidyr::pivot_wider(
    names_from = "car_names",
    names_prefix = "car_name_",
    values_from = "dummy_value",
    values_fill = 0
  )
