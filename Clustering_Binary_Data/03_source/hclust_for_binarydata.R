library(dplyr)
library(ggplot2)
library(gridExtra)


source("./03_source/data_create.R")


params <- list()
params$width <- 800
params$height <- 600

d_mat_bin <- dist(kmeans_data[,c("x1", "x2", "x3")], method = "binary")
h_cluster_bin <- hclust(d_mat_bin, method = "ward.D2")

png("./02_output/pic3-1_dendrogram_binary_data.png", width = params$width, height = params$height)
plot(h_cluster_bin)
dev.off()
kmeans_data$cls <- paste0("hclust_",cutree(h_cluster_bin, k=3))

png("./02_output/pic3-2_hclust_with_only_bin.png", width = params$width, height = params$height)
graph_bin <-  plot_this_proj()
dev.off()

kmeans_data <- kmeans_data %>% 
  dplyr::select(-cls)

d_mat_con <- dist(kmeans_data[,c("x1", "x2", "x3", "x4")], method = "euclidean")
h_cluster_con <- hclust(d_mat_con, method = "ward.D2")
png("./02_output/pic3-3.dendrogram_all_data.png", width = params$width, height = params$height)
plot(h_cluster_con)
dev.off()
kmeans_data$cls <- paste0("hclust_",cutree(h_cluster_con, k=3))

png("./02_output/pic3-4_hclust_with_all_daata.png", width = params$width, height = params$height)
graph_con <-  plot_this_proj()
dev.off()
