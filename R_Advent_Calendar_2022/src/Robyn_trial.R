# issue: pipenvの仮想環境の導入が出来ていないんだよなあ。

library(reticulate)
library(Robyn)
library(tidyverse)

library(readxl)

source("./src/R_pipenv_link.R")


# setup clean conda virtual environment
virtualenv_create("r-reticulate")
py_install("nevergrad", pip = TRUE)
use_virtualenv("r-reticulate", required = TRUE)

# load data
usedata <- readxl::read_excel("./input/kaggle_ad_data.xlsx")

# check data
usedata %>% head()
usedata %>% summary()

# data preparation
# by robyn's reccomend, filter some ad variables.
agg_data <- usedata %>%
    dplyr::mutate(Date = lubridate::ymd(Date)) %>% 
    dplyr::group_by(Date, `Ad group alias`) %>%
    dplyr::summarise(
        Impressions = sum(Impressions, na.rm = TRUE),
        Spend = sum(Spend, na.rm = TRUE),
        Sales = sum(Sales, na.rm = TRUE)
    ) %>%
    dplyr::filter(
        `Ad group alias` != "Brand 1 Ad Group 12" &
        `Ad group alias` != 'Brand 1 Ad Group 10'&
        `Ad group alias` != 'Brand 1 Ad Group 11'&
        `Ad group alias` != 'Brand 1 Ad Group 3'&
        `Ad group alias` != 'Brand 1 Ad Group 5'&
        `Ad group alias` != 'Brand 1 Ad Group 7'& 
        `Ad group alias` != 'Brand 1 Ad Group 8'&
        `Ad group alias` != 'Brand 2 Ad Group 5'&
        `Ad group alias` != 'Brand 2 Ad Group 6'&
        `Ad group alias` != 'Brand 1 Ad Group 1' &
        `Ad group alias` != 'Brand 1 Ad Group 13' &
        `Ad group alias` != 'Brand 1 Ad Group 2' &
        `Ad group alias` != 'Brand 1 Ad Group 6' &
        `Ad group alias` != 'Brand 2 Ad Group 1' &
        `Ad group alias` != 'Brand 2 Ad Group 2' &
        `Ad group alias` != 'Brand 2 Ad Group 3' &
        `Ad group alias` != 'Brand 2 Ad Group 4'
        )

agg_data %>% dim()

media_data <- agg_data %>%
    dplyr::select(Date, `Ad group alias`, Impressions) %>%
    tidyr::pivot_wider(
        id_cols = "Date",
        names_prefix = "Impressions_",
        names_from = `Ad group alias`,
        values_from = "Impressions",
        values_fill = 0
    )

costs_data <- agg_data %>%
    dplyr::select(Date, `Ad group alias`, Spend) %>%
    tidyr::pivot_wider(
        id_cols = "Date",
        names_prefix = "Spend_",
        names_from = `Ad group alias`,
        values_from = "Spend",
        values_fill = 0
    )


sales_target <- agg_data %>%
    dplyr::select(Date, `Ad group alias`, Sales) %>%
    dplyr::group_by(Date) %>% 
    dplyr::summarise(
        Sales = sum(Sales, na.rm = TRUE)
    )

colnames(media_data)[-1]  <- gsub(" ", "_", colnames(media_data)[-1])
colnames(costs_data)[-1]  <- gsub(" ", "_", colnames(costs_data)[-1])

media_col_names <- colnames(media_data)[-1]
costs_col_names <- colnames(costs_data)[-1]

robyn_usedata  <- media_data %>% 
    dplyr::left_join(costs_data, by = "Date") %>% 
    dplyr::left_join(sales_target, by = "Date")

rm(media_data, costs_data, sales_target)
gc()

# make input data
InputCollect  <- Robyn::robyn_inputs(
    dt_input = robyn_usedata,
    date_var = "Date",
    dep_var = "Sales",
    dep_var_type = "revenue",
    prophet_vars = c("trend", "season", "weekday"),
    prophet_country = "US",
    paid_media_spends = costs_col_names,
    paid_media_vars = media_col_names,
    paid_media_signs = rep("positive", length(media_col_names)),
    window_start = "2021-10-17",
    window_end = "2022-01-11",
    adstock = "geometric"
)

# hyperparameter setup
hyperparameter_names  <- Robyn::hyper_names(
        adstock = InputCollect$adstock,
        all_media = InputCollect$all_media
)

alpha_params <- hyperparameter_names[grep("_alphas", hyperparameter_names)]
gamma_params <- hyperparameter_names[grep("_gammas", hyperparameter_names)]
theta_params <- hyperparameter_names[grep("_thetas", hyperparameter_names)]

alpha_params_from <- rep(0.5, length(alpha_params))
gamma_params_from <- rep(0.3, length(gamma_params))
theta_params_from <- rep(0, length(theta_params))

alpha_params_to <- rep(3, length(alpha_params))
gamma_params_to <- rep(1, length(gamma_params))
theta_params_to <- rep(0.3, length(theta_params))

hyper_params_names <- c(
    alpha_params, 
    gamma_params,
    theta_params
)

hyper_params_from <- c(
    alpha_params_from,
    gamma_params_from,
    theta_params_from
)

hyper_params_to <- c(
    alpha_params_to,
    gamma_params_to,
    theta_params_to
)

hyper_params <- cbind(
    hyper_params_from, 
    hyper_params_to
) %>% t %>% 
as.data.frame

colnames(hyper_params) <- hyper_params_names
hyper_params <- as.list(hyper_params)

# error not found, but not defined the hyperparameter.
InputCollect <- Robyn::robyn_inputs(
    InputCollect = InputCollect,
    hyperparameters = hyper_params
)

print(InputCollect)


# model fit
OutputModels <- Robyn::robyn_run(
    InputCollect = InputCollect,
    iterations = 15000,
    trials = 5,
    outputs = FALSE
)

OutputModels$convergence$moo_distrb_plot
OutputModels$convergence$moo_cloud_plot

# output
output_path <- "./output"
OutputCollect <- Robyn::robyn_outputs(
  InputCollect = InputCollect,
  OutputModels = OutputModels,
  csv_out = "pareto",
  clusters = TRUE,
  plot_pareto = TRUE,
  plot_folder = output_path
)
print(OutputCollect)

# allocation
best_model <- "1_585_10"
all_spend <- robyn_usedata %>% 
  dplyr::ungroup() %>% 
  dplyr::select(-Date, -Sales, -contains("Impressions")) %>% 
  apply(., 1, sum) %>% sum

AllocationCollect_01 <- Robyn::robyn_allocator(
  InputCollect = InputCollect,
  OutputCollect = OutputCollect,
  select_model = best_model,
  scenario = "max_historical_response",
  channel_constr_low = 0.7,
  export=TRUE,
  date_min="2022-01-01",
  date_max="2022-01-11"
  
)
