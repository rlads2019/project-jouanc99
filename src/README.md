# 原始碼說明文件

## 爬中國外交部
### 中國外交部.r
一開始先爬15頁產出GS15.txt，再完整爬全部66頁GS66.txt後，手動切為三份比較時期，分別為「1500to3000.txt」、「3001to4500.txt」、「4500to6757.txt」，加上原本GS15.txt時期去比較。
之後手動去除txt檔的「答：」及「記者問」、「中國外交部日程說明」。

## 爬臺灣外交部
### mofa_text.r
產出所有臺灣外交部對外的csv檔「mofa_texts.csv」。
臺灣外交部只有95條檔案，因此全部一起比較。

## 斷詞、文字雲
### wordscloud.Rmd
包含所有中國外交部及臺灣外交部的資料。

## keyword、stopword
### keywords.txt/ keywordsm.txt、stopwords.txt/ stopwordsm.txt
第一個為簡體中文，第二個為繁體中文，
keywords為梗爽模擬器github上的文字手動切關鍵詞加上日常常見用語。
stopwords為網路上下載的「中文停用词表.txt」、「四川大学机器智能实验室停用词库.txt」、「百度停用词表.txt」、「哈工大停用词表.txt」合併加上一些爬出來發現的贅字。
