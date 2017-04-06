library(stringi)
library(lda)
library(dplyr)
library(magrittr)
library(RTextTools)
library(text2vec)
library(jiebaR)
library(plyr)


all_weibo <- readRDS("weibo.rds")

#read depression weibo
dep_weibo <- read.csv("all_data2.csv",header = F, quote = "", sep = "," ,fill=TRUE,row.names=NULL)
colnames(dep_weibo) <- c('name','gender','location','intro','num_weibo','num_follow','num_fan','like','repost','comment','time','phone','weibo')

all_weibo <- rbind(dep_weibo,all_weibo)

all_weibo <- all_weibo[!duplicated(all_weibo$weibo),]
#clean all the non original data  grep: select string with certain pattern

all_weibo2 <- all_weibo[- grep("映客iOS|微博等级|网易云音乐|荔枝FM|明星势力榜|QQ音乐|Feelapp
                               |手机NBA中文官网|微博红包|粉丝红包|微卡券|一直播|LOFTER|微博会员中心
                               |微博活动|百词斩图背单词|让红包飞手机版|天下3|微博等级|分享按钮|背单词
                               |微博头条|MIUI|领年终奖|一个|蘑菇街|扇贝网|手游|微城市|德克萨斯扑克
                               |Q将三国|小小战争|美拍|百度分享|新浪新闻中心|优酷土豆|今日头条|虾米音乐
                               |新浪视频|淘宝|阴阳师|人人客户端|推兔|人人小站|伊蒂之屋甜心派对|美丽说|热门微博
                               |新版微博|摆渡人|推荐|UC浏览器|大码男装|我参与了|围观世界杯领现金|围观世界杯|微博踢球
                               |微话题|天天果园|保卫萝卜|忍将OL|蚂蜂窝分享|蜻蜓.fm收音机|尚听FM|新浪微博活動專頁
                               |91问问调查网|虎扑体育网|掘图志|你画我猜欢乐版|天下3|分享按钮|微盘|投票|微博电视雷达
                               |疯狂开宝箱|知命|全民K歌|唱吧|微博之夜|勋章馆|专题|微专题|测试|多推|新浪博客|啪啪
                               |樱桃小丸子|多推|Nikepluschina|腾讯新闻客户端|滴滴出行|微博品牌活动|哔哩哔哩|人人素材社区
                               |同步iPhone助手|扇贝单词|粉丝服务平台|趣拿|微视|小影", all_weibo$phone),]

all_weibo3 <- all_weibo2[- grep("新版微博|剧情|微博桌面|我正在听|推荐资源链接|UIC校园|分享视频|抢到了|下载APP|我参与了
                                |分享图片|打卡|doge|秒拍视频|送魏晨去EMA|客户端|我正在使用|你也赶紧试试|一起来|全场折起
                                |红包|滴滴出行|分享圖片|张杰|App Store|代购|综合运势|发货实拍|细节如图|特惠活动|淘宝客服
                                |微博随时随地|手机壁纸|上海连锁经营协会|咕咚网|推荐大家去|我刚刚获得了|快来跟我一起|测试题 
                                |好消息话筒|限时折扣|直邮|快来定制|新版|新歌榜|Kitty美瞳猫|活动开始|订货|中秋活动|优惠活动
                                |圣诞活动|我参与了|投票|QQ音乐|亚洲新歌榜|分享微博音乐|百度音乐|包邮|代理|补水|心理测试|特惠
                                |情感好文|淘宝关注了|特价|请加微信|bbwshop|moussy|博世达|实拍图|玻尿酸|无尽模式|为您播报
                                |租房信息|随时随地发现新鲜事|发布了
                                |我分享了|我点评了|问问调查网|http|李宇春|exo", all_weibo2$weibo),]

all_weibo3 <- all_weibo3[- grep("淘宝|批发|零售|诚招代理|找房小能手|护肤达人|Nancy韩国皮肤", all_weibo3$intro),]


#remove LOCATION, BRAKETS, PUNCUTATION, NUMBERS AND ENGLISH  gusb: replace patterns in a string with another pattern
all_weibo3$weibo %>% gsub("我在:\\S+ *", "", .) %>%
        gsub("我在这里:\\S+ *", "", .) %>%
        gsub("我在这里:\\s+ *", "", .)%>%
        gsub("\\S+·\\S+", "", .)%>%            #remove location
        gsub("\\S+.街区", "", .)%>%
        gsub("[阴险]|随手拍|美图秀秀iPhone版|美图秀秀Android版|达人生日祝福", "", .)%>%
        gsub("\\s*\\《[^\\)]+\\》", "", .) %>%
        gsub("[[:punct:]]", "", .) %>%
        gsub("[[:digit:]]", "", .) %>%
        gsub("\\s+"," ",.) -> all_weibo3$weibo  #remove extra space


#remove empty rows
all_weibo4  <- all_weibo3[-which(all_weibo3$weibo == "" | all_weibo3$weibo == " " | all_weibo3$weibo == "  "), ]
all_weibo5 <- all_weibo4
all_weibo5[is.na(all_weibo5)] <- 0

#select weibo column
weibo <- all_weibo5[,c("name","weibo")]



#set up jiebaR worker
# c <- mixseg <= weibo$weibo
# set dictionary
mixseg = worker(type  = "mix",
                dict = "jieba_weibo2.dict.utf8",
                stop_word = "weibo_stop_words.utf8"
)

#apply worker to the list 
c <- apply_list(as.list(weibo$weibo), mixseg)%>% 
        gsub("[[:punct:]]", "", .) %>% #remove "" from jiebar
        gsub("\\s+t\\s+|\\s+m\\s+|\\s+d\\s+|\\s+b\\s+|\\s+o\\s+", "", .) %>%  #remove single letter
        substring(.,2)    #remove the first letter'c'


#lexicalize 
lex <- lexicalize(c, sep = " ", lower = TRUE, count = 1L, vocab = NULL)

#lda model 
LDA <- lda.collapsed.gibbs.sampler(lex$documents,300,lex$vocab, 30, 0.1,0.1, initial = NULL, burnin = NULL, compute.log.likelihood = T)

#extract topic words
topic_words <- top.topic.words(LDA$topics, num.words = 20, by.score = FALSE)

write.csv(topic_words, "weibo_30.csv")       


