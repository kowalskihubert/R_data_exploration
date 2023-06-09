library(sqldf)
library(data.table)
library(dplyr)
library(microbenchmark)

Users <- read.csv('./Users.csv')
Comments <- read.csv('./Comments.csv')
Posts <- read.csv('./Posts.csv')

source("./sqldf.R")
source("./dplyr.R")
source("./base.R")
source("./data.table.R")

View(table_1(Users))
View(table_2(Posts))
View(table_3(Posts,Users))
View(table_4(Posts,Users))
View(table_5(Posts,Comments,Users))
