library(ggplot2)
library(gridExtra)

source("./03_source/data_create.R")
set.seed(114)
kmeans_data <- binom_cls_data_creator(10000, 1000, 3)
## k-means for binary data ONLY
kmeans_data_bin <- kmeans_data %>% 
  dplyr::select(-init_x4_out)

k_means_bin <- stats::kmeans(kmeans_data_bin, centers = 3, iter.max = 20000)
kmeans_data$cls <- paste0("clster_",k_means_bin$cluster)
kmeans_data$numID <- c(1:nrow(kmeans_data))

png("./02_output/pic1_kmeans_with_only_bin.png", width = 800, height = 600)
graph_bin <-  plot_this_proj()
dev.off()

## k-means for binary and continuous data
kmeans_data_con <- kmeans_data %>% 
  dplyr::select(-cls, -numID)

k_means_con <- stats::kmeans(kmeans_data_con, centers = 3, iter.max = 20000)
kmeans_data$cls <- paste0("clster_",k_means_con$cluster)

png("./02_output/pic2_kmeans_with_all_data.png", width = 800, height = 600)
graph_con <- plot_this_proj()
dev.off()
