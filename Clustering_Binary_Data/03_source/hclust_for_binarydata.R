library(dplyr)
library(ggplot2)
library(gridExtra)

source("./03_source/data_create.R")

kmeans_data <- binom_cls_data_creator(35, 3000, 3)

params <- list()
params$width <- 800
params$height <- 600

kmeans_data_bin <- kmeans_data %>% 
  dplyr::select(-init_x4_out)



d_mat_bin <- dist(kmeans_data_bin, method = "binary", diag = TRUE, upper = TRUE)
a <- as.matrix(d_mat_bin)



h_cluster_bin <- hclust(d_mat_bin, method = "single")

png("./02_output/pic3-1_dendrogram_binary_data.png", width = params$width, height = params$height)
plot(h_cluster_bin)
dev.off()
kmeans_data$cls <- paste0("hclust_",cutree(h_cluster_bin,k = 3,h = 0.30))
kmeans_data$numID <- c(1:nrow(kmeans_data))

png("./02_output/pic3-2_hclust_with_only_bin.png", width = params$width, height = params$height)
graph_bin <-  plot_this_proj()
dev.off()

kmeans_data_con <- kmeans_data %>% 
  dplyr::select(-cls, -numID)

d_mat_con <- dist(kmeans_data_con, method = "euclidean")
h_cluster_con <- hclust(d_mat_con, method = "ward.D2")
png("./02_output/pic3-3.dendrogram_all_data.png", width = params$width, height = params$height)
plot(h_cluster_con)
dev.off()
kmeans_data$cls <- paste0("hclust_",cutree(h_cluster_con, k=3))

png("./02_output/pic3-4_hclust_with_all_daata.png", width = params$width, height = params$height)
graph_con <-  plot_this_proj()
dev.off()
