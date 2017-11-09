if (!requireNamespace("devtools")){
  install.packages("devtools"
                   , repos="https://cloud.r-project.org")
}
if (!requireNamespace("rvest")){
  install.packages("rvest"
                   , repos="https://cloud.r-project.org")
}
if (!requireNamespace("stringr")){
  install.packages("stringr"
                   , repos="https://cloud.r-project.org")
}
if (!requireNamespace("dplyr")){
  install.packages("dplyr"
                   , repos="https://cloud.r-project.org")
}
if (!requireNamespace("futile.logger")){
  install.packages("futile.logger"
                   , repos="https://cloud.r-project.org")
}
if (!requireNamespace("jug")){
  devtools::install_github("Bart6114/jug")
}

library(rvest)
library(dplyr)
library(stringr)
library(jug)

jug() %>%
  cors() %>% 
  get("/", function(req, res, err){
    res$json("hello world!")
    res$set_header("Content-Type", "application/json; charset=utf-8")
  }) %>%
  get("/keyboard", function(req,res,err){
    body<-list(type="buttons",
               buttons= c("서울 날씨","강원도 날씨","날씨 알려줘"))
    res$json(body)
    res$set_header("Content-Type", "application/json; charset=utf-8")
  }) %>% 
  post("/message", function(req,res,err){
    content<-jsonlite::fromJSON(req$body)$content
    print(content)
    root <- "http://search.daum.net/search?nil_suggest=btn&w=tot&DA=SBC&q="
    content<-paste("날씨", content)
    content<-gsub(" ","+",content)
    content <- URLencode(content)
    tar <- paste0(root,content)
    wthrrecontent<-c("날씨를 물어봐주세요.",
                     "날씨가 궁금하신게 맞나요?",
                     "날씨가 아니면 잘 모릅니다.",
                     "그거 말고 날씨는 잘 대답할 수 있어요!",
                     "날씨 궁금하신게 아니군요?",
                     "날씨는 궁금하지 않으신거에요?",
                     "그걸 날씨로 대답하기는 정말 어렵네요.")
    
    root <- tar %>% 
      read_html
    
    daily <-
      root %>% 
      html_nodes("div.info_weather") %>% 
      html_text() %>%
      str_trim() %>%
      gsub("  ", " ",.)
    
    chkmulti<-
      root %>% 
      html_nodes(".tit_city") %>% 
      html_text()
    
    if(!identical(chkmulti,character(0))){
      resu<-paste0("지역이 너무 넓네요. 혹시 ",paste0(chkmulti, collapse = ", "), "중에 어디가 궁금하신가요?")
      body<-list(message=list(text=resu))
      res$json(body)
      return(res)
    }
    
    if(identical(daily,character(0))){
      resu<-sample(wthrrecontent,1)
      body<-list(message=list(text=resu))
      res$json(body)
      return(res)
    }
    
    loc <-
      root %>% 
      html_nodes("div.tab_region ul.list_tab li a span") %>% 
      html_text()
    
    dayloc <-
      root %>% 
      html_nodes("div.tab_day ul li") %>% 
      html_attr("class") %>% 
      .[-4]
    
    day <-
      root %>% 
      html_nodes("div.tab_day ul li a") %>% 
      html_text %>% 
      gsub("([0-9][0-9])\\.([0-9][0-9])\\.","\\1월\\2일",.) %>% 
      str_trim() %>% 
      .[-4]
    
    dayloc<-ifelse(is.na(dayloc),F,T)
    day<-day[dayloc]
    day<-gsub(" ","(",day)
    day<-paste0(day,")")
    
    loc<-loc[-1]
    if(any(grepl("다른",loc))){
      loc<-loc[-4]
    }
    if(any(grepl("읍·면·동",loc))){
      loc<-loc[-3]
    }
    if(any(grepl("시·군·구",loc))){
      loc<-loc[-2]
    }
    if(any(grepl("시·도",loc))){
      loc<-loc[-1]
    }  
    if(identical(loc,character(0))){
      resu<-paste0("어느 지역이 궁금하세요?")
      body<-list(message=list(text=resu))
      res$json(body)
      return(res)
    }
    locc<-length(loc)
    if(locc %in% c(1,2)){
      locm<-"더 구체적인 지역을 말해주시면 알아볼께요."
    } else {
      locm<-""
    }
    loc<-paste0(loc, collapse = " ")
    
    dayloc<-c(dayloc[1],dayloc[2],dayloc[2],dayloc[3],dayloc[3])
    if(sum(dayloc)==1){
      daily <- gsub(", (.+) ",", \\1이며 기온은 ",daily[dayloc])
    }
    if(sum(dayloc)==2){
      daily <-
        strsplit(daily[dayloc], " ") %>% 
        unlist %>% 
        .[nchar(.)>0]
      daily<-
        paste0(daily[1], "에는 ", daily[2],"이고 ",
               daily[4], "에는 ", daily[5],"일 예정입니다. 기온은 오전 ",
               daily[3], ", 오후 ", daily[6])
    }
    resu<-paste0(day, "의 " ,loc ,"(은/는) ", daily,"입니다. ",locm)
    body<-list(message=list(text=resu))
    res$json(body)
    return(res)
  }) %>% 
  logger(threshold = futile.logger::DEBUG, log_file='logfile.log', console=TRUE) %>%
  simple_error_handler_json() %>%
  # serve_it(verbose=TRUE)
  serve_it(host="0.0.0.0", port=80, verbose=TRUE)
