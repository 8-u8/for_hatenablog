library(pipelineR) # My original Package

dir.create("./01_input")
dir.create("./02_output")
dir.create("./03_source")

set.seed(1234)
x11 <- rbinom(30, 1, 0.5)
x12 <- rbinom(20, 1, 0.75)
x13 <- rbinom(50, 1, 0.2)

x21 <- ifelse(x11==1, rbinom(30, 1, 0.7), rbinom(30, 1, 0.1))
x22 <- ifelse(x12==1, rbinom(20, 1, 0.8), rbinom(20, 1, 0.05))
x23 <- ifelse(x13==1, rbinom(50, 1, 0.75), rbinom(50, 1, 0.25))

x31 <- ifelse(x11==1, rbinom(30, 1, 0.9), rbinom(30, 1, 0.1))
x32 <- ifelse(x12==1, rbinom(20, 1, 0.6), rbinom(20, 1, 0.04))
x33 <- ifelse(x13==1, rbinom(50, 1, 0.59), rbinom(50, 1, 0.01))

x41 <- rnorm(30, 0, 1)
x42 <- rnorm(20, 5, 1)
x43 <- rnorm(50, -3, 1)

kmeans_data <- data.frame(
  id = paste0("id_", c(1:100)),
  numID = c(1:100),
  x1 = c(x11, x12, x13),
  x2 = c(x21, x22, x23),
  x3 = c(x31, x32, x33),
  x4 = c(x41, x42, x43)
)

rm(x11, x12, x13,
   x21, x22, x23,
   x31, x32, x33,
   x41, x42, x43)

## graph_function

plot_this_proj <- function(){
  
  graph_1 <- ggplot(data = kmeans_data, aes(x = numID, y = x1, color = cls)) +
    geom_point()
  
  graph_2 <- ggplot(data = kmeans_data, aes(x = numID, y = x2, color = cls)) +
    geom_point()
  
  graph_3 <- ggplot(data = kmeans_data, aes(x = numID, y = x3, color = cls)) +
    geom_point()
  
  graph_4 <- ggplot(data = kmeans_data, aes(x = numID, y = x4, color = cls)) +
    geom_point()
  
  output <- gridExtra::grid.arrange(graph_1, graph_2, graph_3, graph_4)
  return(output)
}
