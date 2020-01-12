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
