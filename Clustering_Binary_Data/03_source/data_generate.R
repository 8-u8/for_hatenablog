#' Title
#'
#' @param nrow n row of output
#' @param npat n col of output
#' @param num_cls cluster of output
#' @import dplyr
#' @return
#' @export
#'
#' @examples
#' 

library(dplyr)
binom_cls_data_creator <- function(nrow, npat, num_cls){
 # "
 # data_create.Rの一般化。
 # クラスタ別に異なるパラメータを持つ二値変数を生成する。
 # "
  init_prob <- runif(num_cls) # 初期の生成確率。
  print(round(init_prob, digits = 2))
  init_x1   <- numeric() # x1の生成
  output    <- numeric() # 出力
  
  ## x1xとx4xを作る
  for(cls in 1:num_cls){
    init_x1_tmp <- rbinom(nrow, 1, init_prob[cls])
    init_x4_tmp <- rnorm(nrow, mean = (runif(1) * 10)^2, sd = 1)
    if(cls == 1){
      init_x1_in <- init_x1_tmp
      init_x4_in <- init_x4_tmp
      init_x1_out <- init_x1_tmp
      init_x4_out <- init_x4_tmp
    }else{
      init_x1_in <- cbind(init_x1_in, init_x1_tmp)
      init_x4_in <- cbind(init_x4_in, init_x4_tmp)
      init_x1_out <- c(init_x1_out, init_x1_tmp)
      init_x4_out <- c(init_x4_out, init_x4_tmp)
      
    }
  }
  
  ## x2x以降を作る
  for(pat in 1:npat){
    for(cls in 1:num_cls){
      ## 基本は同じだが、生成過程を変える。
      ## 各クラスタでのx1onの条件で分岐する。
      ## xx同士は独立(x1との交絡)
      init_xx_tmp <- ifelse(init_x1_in[,cls]==1,
                            rbinom(nrow, 1, runif(nrow, min = 0.8)),
                            rbinom(nrow, 1, runif(nrow, min = 0.2))
                            )
      if(cls == 1){
        init_xx_in <- init_xx_tmp
        init_xx_out <- init_xx_tmp
      }else{
        init_xx_in <- cbind(init_x1_in, init_xx_tmp)
        init_xx_out <- c(init_xx_out, init_xx_tmp)
      } 
    }

    if(pat == 1){
      output <- cbind(init_x1_out, init_xx_out)
    }else{
      output <- cbind(output, init_xx_out)
    }
  }
  colnames(output) <- paste0("x", c(1:ncol(output)))
  # colnames(init_x4_out) <- paste0("x_norm" ,c(1:ncol(init_x4)))
  output <- cbind(output, init_x4_out)
  output <- output %>%
    as.data.frame
  #   dplyr::arrange(x1)
  return(output)
}

