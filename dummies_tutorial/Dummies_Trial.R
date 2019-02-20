####
# 20190220
# データのエンコーディングによってはdummies::dummy.data.frame()による変換後に
# colnamesが文字化けする事象を確認。
# Todo: 再現検証
####

install.packages("dummies") # If you do not install package.
library(dummies)

dat <- iris

# 入力かくにん！よかった
head(dat)

# one-hot encoding
dummied_dat <- dummies::dummy.data.frame(dat,                   # one-hotにしたいDataFrame
                                         sep = "_",             # 変数名の加工．ここでは「元変数名_カテゴリ番号」という形を指定．
                                         dummy.classes = "factor"  # classを指定してone-hot．全部やってほしいときは"ALL"
                                         )
head(dummied_dat)

dummied_dat <- dummies::dummy.data.frame(dat,
                                         sep = "_",
                                         names = c("Sepal.Length", "Species")
                                         )

head(dummied_dat)
  
