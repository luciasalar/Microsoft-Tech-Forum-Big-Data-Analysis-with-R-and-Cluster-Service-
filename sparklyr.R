install.packages("sparklyr")
install.packages("dplyr")
install.packages(c("nycflights13", "Lahman"))
library(sparklyr)
library(dplyr)


sc <- spark_connect(master = "yarn-client")


####testing with spark
weibo_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)

flights_tbl %>% filter(dep_delay == 2)



sc <- spark_connect(master = "yarn-client")

