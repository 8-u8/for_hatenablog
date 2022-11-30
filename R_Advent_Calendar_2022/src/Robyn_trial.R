library(languageserver)
library(Robyn)
library(tidyverse)

library(readxl)

# load data
usedata <- readxl::read_excel("./input/kaggle_ad_data.xlsx")

# check data
usedata %>% head
usedata %>% summary

# setup: robyn dataset
## to be continued.
