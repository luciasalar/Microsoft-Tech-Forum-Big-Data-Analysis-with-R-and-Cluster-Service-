install.packages("sparklyr")
install.packages("dplyr")
install.packages(c("nycflights13", "Lahman"))
library(sparklyr)
library(dplyr)


sc <- spark_connect(master = "yarn-client")

# weibo <- file.path("adl://weibo033adls.azuredatalakestore.net")
# 
# weibo1 <- spark_read_csv(sc,
#                          path = weibo,
#                          name = 'weibo_data_1',
#                          header = FALSE,
#                          delimiter = ","
# )
# 
# adl://weibo033adls.azuredatalakestore.net/weibo_data_1.csv
# 
# 
# https://weibo22.blob.core.windows.net/demolda-2017-04-04t11-39-24-415z/user/weibo_data_1.csv
# 
# myNameNode <- "adl://weibo033adls.azuredatalakestore.net"
# myPort <- 0
# 
# mySparkCluster <- RxSpark(consoleOutput=TRUE, nameNode=myNameNode, port=myPort)
# rxSetComputeContext(mySparkCluster)
# hdfsFS <- RxHdfsFileSystem(hostName=myNameNode, port=myPort)
# 
# dep_weibo <- read.csv("weibo_data_1.csv",header = F, quote = "", sep = "," ,fill=TRUE,row.names=NULL)

####testing with spark
weibo_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)

flights_tbl %>% filter(dep_delay == 2)



sc <- spark_connect(master = "yarn-client")

