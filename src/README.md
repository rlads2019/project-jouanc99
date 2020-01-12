# 原始碼說明文件

## 爬中國外交部
```{r}
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
```
## 爬臺灣外交部
```{r}
library(RSelenium)
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4445L, browserName = "chrome")

# test
# remDr$open()
# remDr$navigate("https://www.mofa.gov.tw/News_M_2.aspx?n=5028B03CED127255&page=1&PageSize=95#")
# remDr$getTitle()

# title
nums <- c(0:94)
title_links <- sapply(nums, function(x) paste0('#ContentPlaceHolder1_gvIndex_lnkTitle_', x))

webElems <- sapply(title_links, function(x) remDr$findElements(using = 'css selector', x))
titles <- unlist(lapply(webElems, function(x){x$getElementText()}))

# get page links
webElems <- sapply(title_links, function(x) remDr$findElements(using = 'css selector', x))
links <- unlist(lapply(webElems, function(x){x$getElementAttribute("href")}))

# in page text
page_text <- list()
for (i in 1:length(links)){
  remDr$navigate(links[i])
  webElems <- remDr$findElements(using = 'css selector', '#base-content > div > div > div > div.data_midlle_news_box02')
  page_text[i] <- unlist(lapply(webElems, function(x){x$getElementText()}))
}
```
## 匯入及製作1-1500行資料的df
```{r}
fps1 <- list.files("GS66/15", full.names = T)
# Initialize jiebaR and the dictionary
seg1<-worker(user="keywords.txt",stop_word = "stopwords.txt")

# 空字串
contents1 <- vector("character", length(fps1))
for (i in seq_along(fps1)) {
  # Read post from file
  post1 <- readLines(fps1[i], encoding = "UTF-8")
  # Segment post
  segged1 <- segment(post1, seg1)
  contents1[i] <- paste(segged1, collapse = " ")
}
# 製作df
to1500 <- tibble::tibble(id = seq_along(contents1), content = contents1)
```
## 斷詞
```{r}
#詞頻
to1500<-to1500 %>%
  unnest_tokens(output="word",
                input="content", 
                token="regex",
                pattern = " ")  

#計算出現詞彙次數
topicword_1500<-to1500 %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```
### 製作年份最新二字+文字雲
```{r}
wordcloud2(topicword_1500, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```

## 以同樣斷詞方法製作四字+文字雲
```{r}
to1500_idiom<-to1500 %>% filter(str_detect(to1500$word, ".{4}"))

#計算出現詞彙次數
topicword_1500_idiom<-to1500_idiom %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
  ```
  
### 製作年份最新四字文字雲
```{r}
wordcloud2(topicword_1500_idiom, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```

### 以同樣匯入資料、製作df與斷詞方法製作次新、次舊、最舊文字雲

### 1500-3000行
```{r}
fps2 <- list.files("GS66/30", full.names = T)
# Initialize jiebaR and the dictionary
seg2<-worker(user="keywords.txt",stop_word = "stopwords.txt")

# Initialize empty vector to use in for loop
contents2 <- vector("character", length(fps2))

for (i in seq_along(fps2)) {
  # Read post from file
  post2 <- readLines(fps2[i], encoding = "UTF-8")
  
  # Segment post
  segged2 <- segment(post2, seg2)
  contents2[i] <- paste(segged2, collapse = " ")
}

# Combine results into a df
to4500 <- tibble::tibble(id = seq_along(contents2), content = contents2)

#詞頻
to4500<-to4500 %>%
  unnest_tokens(output="word", 
                input="content",
                token="regex",
                pattern = " ") 

#計算出現詞彙次數
topicword_4500<-to4500 %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作年份次新二字文字雲
```{r}
wordcloud2(topicword_4500, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")#顏色和背景
```

```{r}
to4500_idiom<-to4500 %>% filter(str_detect(to4500$word, ".{4}"))

#計算出現詞彙次數
topicword_4500_idiom<-to4500_idiom %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作年份次新四字文字雲
```{r}
wordcloud2(topicword_4500_idiom, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```
#### 3000-4500行
```{r}
fps3 <- list.files("GS66/45", full.names = T)
# Initialize jiebaR and the dictionary
seg3<-worker(user="keywords.txt",stop_word = "stopwords.txt")

# Initialize empty vector to use in for loop
contents3 <- vector("character", length(fps3))

for (i in seq_along(fps3)) {
  # Read post from file
  post3 <- readLines(fps3[i], encoding = "UTF-8")
  
  # Segment post
  segged3 <- segment(post3, seg3)
  contents3[i] <- paste(segged3, collapse = " ")
}

# Combine results into a df
to6000 <- tibble::tibble(id = seq_along(contents3), content = contents3)

#詞頻
to6000<-to6000 %>%
  unnest_tokens(output="word", 
                input="content", 
                token="regex",
                pattern = " ") 

#計算出現詞彙次數
topicword_6000<-to6000 %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作年份次舊二字文字雲
```{r}
wordcloud2(topicword_6000, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```

```{r}
to6000_idiom<-to6000 %>% filter(str_detect(to6000$word, ".{4}"))

#計算出現詞彙次數
topicword_6000_idiom<-to6000_idiom %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作年份次舊四字文字雲
```{r}
wordcloud2(topicword_6000_idiom, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```

### 4500-6757行
```{r}
fps4 <- list.files("GS66/end", full.names = T)
# Initialize jiebaR and the dictionary
seg4<-worker(user="keywords.txt",stop_word = "stopwords.txt")

# Initialize empty vector to use in for loop
contents4 <- vector("character", length(fps4))

for (i in seq_along(fps4)) {
  # Read post from file
  post4 <- readLines(fps4[i], encoding = "UTF-8")
  
  # Segment post
  segged4 <- segment(post4, seg4)
  contents4[i] <- paste(segged4, collapse = " ")
}

# Combine results into a df
end<- tibble::tibble(id = seq_along(contents4), content = contents4)

#詞頻
end<-end %>%
  unnest_tokens(output="word",  
                input="content",  
                token="regex",
                pattern = " ")

#計算出現詞彙次數
topicword_end<-end %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作年份最舊二字文字雲
```{r}
wordcloud2(topicword_end, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```

```{r}
end_idiom<-end%>% filter(str_detect(end$word, ".{4}"))

#計算出現詞彙次數
topicword_end_idiom<-end_idiom %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作年份最舊四字文字雲
```{r}
wordcloud2(topicword_end_idiom, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```

## 以同樣匯入資料方法製作臺灣外交部df
```{r}
fps01 <- list.files("TW", full.names = T)
# Initialize jiebaR and the dictionary
seg01<-worker(user="keywordsm.txt",stop_word = "stopwordsm.txt")

# Initialize empty vector to use in for loop
contents01 <- vector("character", length(fps01))

for (i in seq_along(fps01)) {
  # Read post from file
  post01 <- readLines(fps01[i], encoding = "UTF-8")
  
  # Segment post
  segged01 <- segment(post01, seg01)
  contents01[i] <- paste(segged01, collapse = " ")
}

# Combine results into a df
docs_df01 <- tibble::tibble(id = seq_along(contents01), content = contents01)
```

## 斷詞
```{r}
#詞頻
taiwan<-docs_df01 %>%
  unnest_tokens(output="word",  
                input="content",  
                token="regex",
                pattern = " ")

taiwan2<-taiwan %>% filter(str_detect(taiwan$word, ".{2}"))

#計算出現詞彙次數
topicword_taiwan2<-taiwan2 %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作臺灣外交部二字+文字雲
```{r}
wordcloud2(topicword_taiwan2, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```

```{r}
taiwan4<-taiwan %>% filter(str_detect(taiwan$word, ".{4}+"))

#計算出現詞彙次數
topicword_taiwan4<-taiwan4 %>% 
  group_by(word) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
```

### 製作臺灣外交部四字+文字雲
```{r}
wordcloud2(topicword_taiwan4, color = "random-light",fontFamily = "微軟正黑體", backgroundColor = "black")
```
