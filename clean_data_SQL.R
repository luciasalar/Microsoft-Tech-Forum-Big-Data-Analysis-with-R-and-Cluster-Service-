install.packages("RSQLite")
install.packages("DBI")
# 
library(RSQLite)
library(DBI)
library(tidyverse)


#read data
all_weibo <- read.csv("weibo_data_1.csv",header = T, quote = "", sep = "," ,fill=TRUE,row.names=NULL)

#clean data with SQL

all_weibo <- weibo_data_1

#create SQL database
con <- dbConnect(SQLite())  #An existing SQLiteConnection
weibo.db<- dbWriteTable(con, "all_weibo", all_weibo)

#Execute A Query On A Given Database Connection
remove <- dbSendQuery(con, "delete from all_weibo where [phone] = '微博等级' 
            OR [phone] = '映客iOS'
            OR [phone] = '网易云音乐'" )
dbClearResult(remove)


#return database
b1 <- dbGetQuery(con, "select * from all_weibo")




