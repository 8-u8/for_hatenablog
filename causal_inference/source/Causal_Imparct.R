# (5) 分析するデータのあるパッケージをインストール(初回のみ)
install.packages("Ecdat")

# (6) ライブラリの読み込み
library("Ecdat")

# (7) Proposition99の分析：集計による分析
## データの準備

### Common Trend Assumptionの為に分析から特定の州を外す
### タバコの税金が1988年以降50セント以上上がった州のリスト
### Alaska, Hawaii, Maryland, Michigan, New Jersey, New York, Washington
skip_state <- c(3,9,10,22,21,23,31,33,48)

### Cigarデータセットの読み込み
### skip_stateに含まれる州のデータを削除
Cigar <- Cigar %>%
  filter(!state %in% skip_state,
         year >= 70) %>%
  mutate(area = if_else(state == 5, "CA", "Rest of US"))

## 前後比較による分析
Cigar %>%
  mutate(period = if_else(year > 87, "after", "before"),
         state = if_else(state == 5, "CA", "Rest of US")) %>%
  group_by(period, state) %>%
  summarise(sales = sum(sales*pop16)/sum(pop16)) %>%
  spread(state, sales)

## 前後比較のプロット
Cigar %>%
  mutate(period = if_else(year > 87, "after", "before"),
         state = if_else(state == 5, "CA", "Rest of US")) %>%
  group_by(period, state) %>%
  summarise(sales = sum(sales*pop16)/sum(pop16)) %>%
  ggplot(aes(y = sales,
             x = period,
             shape = state,
             linetype = state)) +
  geom_point(size = 2) +
  geom_line(aes(group = state)) +
  ylim(0, NA) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom",
        plot.margin = margin(1,1,1,1, "cm")) +
  scale_x_discrete(name ="Period",limits=c("before","after"))


## タバコの売上のトレンドを示すプロット
Cigar %>%
  mutate(state = if_else(state == 5, "CA", "Rest of US")) %>%
  group_by(year,state) %>%
  summarise(sales = sum(sales*pop16)/sum(pop16)) %>%
  ggplot(aes(y = sales,
             x = year,
             shape = state,
             linetype = state)) +
  geom_line() +
  geom_point(size = 2) +
  geom_vline(xintercept = 88, linetype = 4) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom",
        plot.margin = margin(1,1,1,1, "cm"))

# (8) DIDのためのデータを準備
## カリフォルニア州とその他という2グループのデータ
Cigar_did_sum <- Cigar %>%
  mutate(post = if_else(year > 87, 1, 0),
         ca = if_else(state == 5, 1, 0),
         state = factor(state),
         year_dummy = paste("D", year, sep = "_")) %>%
  group_by(post, year, year_dummy, ca) %>%
  summarise(sales = sum(sales*pop16)/sum(pop16))

## カリフォルニア州とその他の州という州ごとでのデータ
Cigar_did_data <- Cigar %>%
  mutate(post = if_else(year > 87, 1, 0),
         ca = if_else(state == 5, 1, 0),
         state = factor(state),
         year_dummy = paste("D", year, sep = "_")) %>%
  group_by(post, ca, year, year_dummy, state) %>%
  summarise(sales = sum(sales*pop16)/sum(pop16))

# (9) カリフォルニア州とその他というグループでの分析
## 2グループでのデータでの分析
Cigar_did_sum_reg <- Cigar_did_sum %>%
  lm(data = ., sales ~ ca + post + ca:post + year_dummy) %>%
  tidy() %>%
  filter(!str_detect(term, "state"),
         !str_detect(term, "year"))

## 2グループでのデータでの分析(log)
Cigar_did_sum_logreg <- Cigar_did_sum %>%
  lm(data = ., log(sales) ~ ca + post + ca:post + year_dummy) %>%
  tidy() %>%
  filter(!str_detect(term, "state"),
         !str_detect(term, "year"))

# (10) 州ごとのデータでの分析
## miceaddsのインストール
install.packages("miceadds")

## 州ごとのデータでの分析
Cigar_did_data_cluster <- Cigar_did_data %>%
  miceadds::lm.cluster(data = .,
                       sales ~ ca + state + post + ca:post + year_dummy,
                       cluster = "state") %>%
  summary()

## 結果の抽出
did_cluster_result <- Cigar_did_data_cluster[row.names(Cigar_did_data_cluster) == "ca:post",]
did_cluster_result

# (11) CausalImpactを利用した分析
## ライブラリのインストール（初回のみ）
install.packages("CausalImpact")

## CigarデータをCausalImpact用に整形
### 目的変数としてカリフォルニア州の売上 だけ抜き出す
Y <- Cigar %>% filter(state == 5) %>% pull(sales)

### 共変量として他の州の売上を抜き出し整形
X_sales <- Cigar %>%
  filter(state != 5) %>%
  select(state, sales, year) %>%
  spread(state,sales)

### 介入が行われるデータを示す
pre_period <- c(1:NROW(X_sales))[X_sales$year < 88]
post_period <- c(1:NROW(X_sales))[X_sales$year >= 88]

### 目的変数と共変量をバインドする
CI_data <- cbind(Y,X_sales) %>% select(-year)

## CausalImpactによる分析
impact <- CausalImpact::CausalImpact(CI_data,
                                     pre.period = c(min(pre_period), max(pre_period)),
                                     post.period = c(min(post_period), max(post_period)))
## 結果のplot
plot(impact)
