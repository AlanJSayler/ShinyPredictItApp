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
myColors = c("red", "mediumblue", "green","gray0","gold","deeppink", "orangered", "tan4", "darkmagenta",
             "cyan","chartreuse","burlywood4","forestgreen","mediumorchid3")
republicanNames = unique(as.character(R$name))
democratNames = unique(as.character(D$name))
P = rbind(D,R)

findConditionalPrice = function(row,frame){
  subframe = frame[which(as.character(frame$name) == as.character(row$name[1])),]
  if(nrow(subframe) == 0){
    return(-1)
  }
  closestPrice = subframe$price[which.min(abs(strptime(row$date,"%Y-%m-%d.%H:%M:%S")-strptime(subframe$date,"%Y-%m-%d.%H:%M:%S")))]
  if(closestPrice == .01){
    return(-1)
  }
  return(closestPrice/row$price)
}

isCompetitive = function(name, data){
  if(mean(data$price[data$name == name]) < .02){
    return("Droopy McCool")
  }
  return(name)
}


#Server
shinyServer(function(input, output) {
  output$thePlot = renderPlot({
    currNames = c()
    if(is.element(1, input$parties)){
     currNames = c(currNames, democratNames)
    }
    if(is.element(2,input$parties)){
     currNames = c(currNames,republicanNames)
    }
    data = data.frame()
    if(input$typeChoice == 1) {data = G}
    
    if(input$typeChoice == 2){data = P}
    if(input$typeChoice == 3) {
      data = P
      if(input$nonCompetitives == 0){
        names = as.character(unique(data$name))
        Competitives = sapply(X = names, FUN = isCompetitive, d = data)
        data = data[sapply(X = as.character(data$name), FUN = is.element, set = Competitives),]
      }
      for (i in 1:length(data[,1])){
        data$price[i] = findConditionalPrice(data[i,],G)
      }
    }
    
    data = data[strptime(as.character(data$date), "%Y-%m-%d.%H:%M:%S") >= input$dates[1],]
    
    data = data[strptime(as.character(data$date), "%Y-%m-%d.%H:%M:%S") <= input$dates[2],]
      
    data = data[data$price != -1,]
    if(nrow(data)> 0){
      data = data[sapply(X = as.character(data$name), FUN = is.element,set = currNames),]
      if(input$nonCompetitives == 0 && nrow(data)> 0){
        names = as.character(unique(data$name))
        Competitives = sapply(X = names, FUN = isCompetitive, d = data)
        data = data[sapply(X = as.character(data$name), FUN = is.element, set = Competitives),]
      }
    }
   
    #now that we've cleansed the data of unwanted names, let's make currname into just those names
    #that actually appear
    currNames = unique(data$name)
    
    plot(c(input$dates[1], input$dates[2]),c(0,1), type = 'n',
      xlab = "Time", ylab = "Probability")
    
    for (i in 1:length(currNames)){
      lines(
        x = strptime(as.character(data$date[data$name == currNames[i]]), "%Y-%m-%d.%H:%M:%S"),
        y = data$price[as.character(data$name) == currNames[i]], col = myColors[i])
    }
    if(length(currNames)> 0){
      par(xpd = TRUE)
      legend(x = "topleft", y = NULL, currNames,col = myColors, lty = c(1,1))
    }
    
    
 })

})