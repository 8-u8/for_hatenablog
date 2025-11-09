#' lintrを使ってmlogit_test.Rのリンティングを実行
library(lintr)

# ファイルパスを指定
file_path <- "src/mlogit_test.R"

# リンティングを実行
lint_results <- lint(file_path)

# 結果を表示
print(lint_results)
