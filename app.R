if (!requireNamespace("jug")){
  install.packages("jug", lib="https://cloud.r-project.org")
}

library(jug)

jug() %>%
  get("/", function(req, res, err){
    "Hello World!"
  }) %>%
  get("/keyboard", function(req,res,err){
    body<-list(type="buttons",
               buttons= c("선택1","선택2","선택3"))
    res$json(body)
    res$set_header("Content-Type", "application/json; charset=utf-8")
  }) %>% 
  simple_error_handler_json() %>%
  serve_it()
