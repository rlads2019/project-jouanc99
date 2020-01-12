library(httr)
library(rvest)
library(xml2)
library(stringr)

url <- vector("character", 66) #空向量
text_ans <- c("")

#### 抓一到十頁一分半
for (i in 1:66) { 
    url[i] <- paste0("https://www.fmprc.gov.cn/web/wjdt_674879/fyrbt_674889/default_", i, ".shtml")
    
    ## 一頁
    req <- GET(url[i])
    #req[["status_code"]]
    onepage <- content(req)
    onehref <- onepage %>% html_nodes(".rebox_news > ul > li > a") %>% html_attr("href") #一頁href
    onetitle <- onepage %>% html_nodes(".rebox_news > ul > li > a") %>% html_text() #一頁的標題
    
    if (is.na(grep(TRUE,grepl("耿爽", onetitle))[1])) { #排除都沒有耿爽
        next()
    } else {
        righthref <- onehref[grepl("耿爽", onetitle)] #有耿爽的標題
        onep_length <- length(righthref) #一頁符合個數
        href_go <- substring(righthref, 3, 16) #把href切掉./ 好像是固定長度
        href_vec <- vector("character", onep_length) #空向量
        desired_length <- 10
        text_list <- vector(mode = "list", length = desired_length)
        
        for (i in 1:onep_length) { #把有耿爽的網址黏起來
            href_vec[i] <- paste0("https://www.fmprc.gov.cn/web/wjdt_674879/fyrbt_674889/", href_go[i])    
        }
        
        for (i in 1:onep_length) { #把每篇內文拿出來
            req2 <- GET(href_vec[i])
            article <- content(req2)
            text_p <- article %>% html_nodes("#News_Body_Txt_A > p") %>% html_text() #分段提出
            text_noquestion <- str_trim(text_p[!grepl("问：",text_p)]) #去除問的P
            text_ans1 <- grep(TRUE,grepl("答：", text_noquestion))[1] #第一個有答的P
            if (is.na(text_ans1)){ #排除沒有問答
                next()
            } else {
                if (text_ans1 != 1 ) { #排除沒主題
                    text_ans2 <- text_noquestion[-1:-(text_ans1-1)] #把答前面去掉
                } else {
                    text_ans2 <- text_noquestion
                }
            }
            text_ans <- c(text_ans, text_ans2) #黏上
        }
    }
}

write.table(text_ans, file = "C:/Users/Jouan/Desktop/R.txt", sep = " ", quote = FALSE, na = "NA", row.names = F)

#read_html可直接用網址讀
#str_trim刪除前後空白
#grep傳回位置,grepl單純boolean


