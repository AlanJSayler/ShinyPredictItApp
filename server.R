library(shiny)
D = read.csv("DNOM16.csv", header = FALSE)
D$name = D$V1
D$V1 = NULL
D$price = D$V2
D$V2 = NULL
D$date = D$V3
D$V3 = NULL
R = read.csv("RNOM16.csv", header = FALSE)
R$name = R$V1
R$V1 = NULL
R$price = R$V2
R$V2 = NULL
R$date = R$V3
R$V3 = NULL
G = read.csv("USPREZ16.csv", header = FALSE)
G$name = G$V1
G$V1 = NULL
G$price = G$V2
G$V2 = NULL
G$date = G$V3
G$V3 = NULL
#Server
shinyServer(function(input, output) {
  

  
  output$first <- renderText({
    paste(D$date[1])   
  })
  output$last <- renderText({
    paste(D$date[length(D$date)])
  })
})
