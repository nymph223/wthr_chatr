if (!requireNamespace("jug")){
  install.packages("jug"
                   , repos="https://cloud.r-project.org")
}

library(jug)

jug() %>%
  cors() %>% 
  get("/", function(req, res, err){
    res$json("hello world!")
    res$set_header("Content-Type", "application/json; charset=utf-8")
  }) %>%
  get("/keyboard", function(req,res,err){
    body<-list(type="buttons",
               buttons= c("선택1","선택2","선택3"))
    res$json(body)
    res$set_header("Content-Type", "application/json; charset=utf-8")
  }) %>% 
  simple_error_handler_json() %>%
  serve_it("0.0.0.0")
