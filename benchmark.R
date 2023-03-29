library(microbenchmark)

source("./sqldf.R")
source("./dplyr.R")
source("./base.R")
source("./data.table.R")


Users <- read.csv("./data/Users.csv")
Comments <- read.csv("./data/Comments.csv")
Posts <- read.csv("./data/Posts.csv")

# 1st query
microbenchmark(
  sqldf = sql_1(Users),
  base = base_1(Users),
  dplyr = dplyr_1(Users),
  data.table = table_1(Users),
  times=5L
)

# 2nd query
microbenchmark(
  sqldf = sql_2(Posts),
  base = base_2(Posts),
  dplyr = dplyr_2(Posts),
  data.table = table_2(Posts),
  times=5L
)

# 3rd query
microbenchmark(
  sqldf = sql_3(Posts),
  base = base_3(Posts),
  dplyr = dplyr_3(Posts),
  data.table = table_3(Posts),
  times=5L
)

# 4th query
microbenchmark(
  sqldf = sql_4(Posts,Users),
  base = base_4(Posts,Users),
  dplyr = dplyr_4(Posts,Users),
  data.table = table_4(Posts, Users),
  times=5L
)

# 5th query
microbenchmark(
  # sqldf = sql_5(Posts,Comments, Users),
  base = base_5(Posts,Comments, Users),
  dplyr = dplyr_5(Posts,Comments, Users),
  data.table = table_5(Posts,Comments, Users),
  times=5L
)

# sqldf function in 5th query is too slow to use
# data.table function seems to be around 24000 times faster

