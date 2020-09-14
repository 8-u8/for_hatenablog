library(ggplot2)
library(gridExtra)

source("./03_source/data_create.R")


## k-means for binary data ONLY
k_means_bin <- stats::kmeans(kmeans_data[,c("x1", "x2", "x3")], centers = 3, iter.max = 20000)
kmeans_data$cls <- paste0("clster_",k_means_bin$cluster)

png("./02_output/pic1_kmeans_with_only_bin.png", width = 800, height = 600)
graph_bin <-  plot_this_proj()
dev.off()

## k-means for binary and continuous data
k_means_con <- stats::kmeans(kmeans_data[,c("x1", "x2", "x3", "x4")], centers = 3, iter.max = 20000)
kmeans_data$cls <- paste0("clster_",k_means_con$cluster)


png("./02_output/pic2_kmeans_with_all_data.png", width = 800, height = 600)
graph_con <- plot_this_proj()
dev.off()
