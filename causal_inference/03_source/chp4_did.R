###################################################################
#####                Data creation process                    #####
##### from https://github.com/ghmagazine/cibook/tree/master/R #####
##### Since there are no Official Cholera data,               #####
##### We use Yasui's sample data on github.                   #####
##### This script makes data for DiD analysis,                #####
##### and analytics part and Causal impact part               #####
##### is moved to other script (Difference_in_Difference.R)   #####
###################################################################

# (1) tidyverseとbroomの読み込み
library("tidyverse")
library("broom")

# (2) John Snowデータの読み込み
## Data from Table.12 in Snow(1855)
## http://www.ph.ucla.edu/epi/snow/table12a.html

## 1849年におけるエリア毎のコレラによる死者数
### Southwark and Vauxhall Company
sv1849 <- c(283,157,192,249,259,226,352,97,111,8,235,92)

### Lambeth Company & Southwark and Vauxhall Company
lsv1849 <- c(256,267,312,257,318,446,143,193,243,215,544,187,153,81,113,176)

## 1849年におけるエリア毎のコレラによる死者数
### Southwark and Vauxhall Company
sv1854 <- c(371, 161, 148, 362, 244, 237, 282, 59, 171, 9, 240, 174)

### Lambeth Company & Southwark and Vauxhall Company
lsv1854 <- c(113,174,270,93,210,388,92,58,117,49,193,303,142,48,165,132)

## コレラの死者数を会社ごとにまとめる
sv_death <- c(sv1849, sv1854)
lsv_death <- c(lsv1849, lsv1854)

## どのデータがどのエリアのものか
sv_area <- paste0("sv_",c(1:length(sv1849), 1:length(sv1854)))
lsv_area <- paste0("lsv_", c(1:length(lsv1849), 1:length(lsv1854)))

## どのデータがどの年のものか
sv_year <- c(rep("1849",length(sv1849)), rep("1854", length(sv1854)))
lsv_year <- c(rep("1849",length(lsv1849)), rep("1854", length(lsv1854)))

## Southwark & Vauxhallのデータフレームを作成
sv <- data.frame(area = sv_area,
                 year = sv_year,
                 death = sv_death,
                 LSV = "0",
                 company = "Southwark and Vauxhall")

## Lambeth & Southwark and Vauxhallのデータフレームを作成
lsv <- data.frame(area = lsv_area,
                  year = lsv_year,
                  death = lsv_death,
                  LSV = "1",
                  company = "Lambeth & Southwark and Vauxhall")

## 地域・年別のデータセットの作成
JS_df <- rbind(sv, lsv) %>%
  mutate(LSV =
           if_else(company == "Lambeth & Southwark and Vauxhall", 1, 0))

## 会社別のデータセットを作成
JS_sum <- JS_df %>%
  group_by(company, LSV, year) %>%
  summarise(death = sum(death))

