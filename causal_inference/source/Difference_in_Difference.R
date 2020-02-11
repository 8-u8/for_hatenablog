source("source/chp4_did.R")

# (3) 集計と可視化による分析
## 集計による推定
JS_grp_summary <- JS_sum %>%
  mutate(year = paste("year", year, sep = "_")) %>%
  spread(year, death) %>%
  mutate(gap = year_1854 - year_1849,
         gap_rate = year_1854/year_1849 - 1)

## 集計による推定(log)
JS_grp_summary_ln <- JS_sum %>%
  mutate(year = paste("year", year, sep = "_"),
         death = log(death)) %>%
  spread(year, death) %>%
  mutate(gap = year_1854 - year_1849)

## ggplotによる可視化
did_plot <- JS_sum %>%
  ggplot(aes(y = death, x = year, shape = company)) +
  geom_point(size = 2) +
  geom_line(aes(group = company), linetype = 1) +
  ylim(2000, 4250) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom",
        plot.margin = margin(1,1,1,1, "cm"))

## ggplotによる可視化(アノテーションを追加)
did_plot +
  annotate("text", x = 2.2, y = 2400, label = "(1)") +
  annotate("text", x = 2.2, y = 3904 + 197*0.6, label = "(2)") +
  annotate("text", x = 2.2, y = 3300, label = "(3)") +
  annotate("segment", # for common trend in treatment group
           x = 1, xend = 2,
           y = 3904, yend = 3904 + 197,
           arrow = arrow(length = unit(.2,"cm")),
           size = 0.1,
           linetype = 2) +
  annotate("segment", # for parallel trend
           x = 1, xend = 2,
           y = 2261, yend = 2261,
           size = 0.1,
           linetype = 2) +
  annotate("segment", # for parallel trend
           x = 1, xend = 2,
           y = 3904, yend = 3904,
           size = 0.1,
           linetype = 2) +
  annotate("segment", # for (1)
           x = 2.07, xend = 2.07,
           y = 2261, yend = 2458,
           arrow = arrow(ends = "both",
                         length = unit(.1,"cm"),angle = 90)) +
  annotate("segment", # for (2)
           x = 2.07, xend = 2.07,
           y = 3904, yend = 3904 + 197,
           arrow = arrow(ends = "both",
                         length = unit(.1,"cm"),angle = 90)) +
  annotate("segment", # for (3)
           x = 2.07, xend = 2.07,
           y = 3904, yend = 2547,
           arrow = arrow(ends = "both",
                         length = unit(.1,"cm"),angle = 90))

# (4) 回帰分析を用いたDID
## Difference in Difference
JS_did <- JS_sum %>%
  mutate(D1854 = if_else(year == 1854, 1, 0)) %>% # the dummy variable whether year is 1854 or not
  lm(data = ., death ~ LSV + D1854 + D1854:LSV) %>% # linear regression
  tidy()

## Difference in Difference(log)
JS_did_log <- JS_sum %>%
  mutate(D1854 = if_else(year == 1854, 1, 0)) %>%
  lm(data = ., log(death) ~ LSV + D1854 + D1854:LSV) %>%
  tidy()

## Difference in Difference(エリア単位)
JS_did_area <- JS_df %>%
  mutate(D1854 = if_else(year == 1854, 1, 0)) %>%
  lm(data = ., death ~ LSV + area + D1854 + D1854:LSV) %>%
  tidy() %>%
  filter(!str_detect(term, "area"))

## Difference in Difference(州単位、log)
JS_did_area_log <- JS_df %>%
  mutate(D1854 = if_else(year == 1854, 1, 0)) %>%
  lm(data = ., log(death) ~ LSV + area + D1854 + D1854:LSV) %>%
  tidy() %>%
  filter(!str_detect(term, "area"))

