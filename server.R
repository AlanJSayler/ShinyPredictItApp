library(shiny)

#read data for Democratic primaries
D = read.csv("DNOM16.csv", header = FALSE,
             col.names = c("name", "price", "date"))
#read data for Republican primaries
R = read.csv("RNOM16.csv", header = FALSE, 
             col.names = c("name", "price", "date"))
#read data for General election
G = read.csv("USPREZ16.csv", header = FALSE,
             col.names = c("name", "price", "date"))

#make new color array.
#I tried to use colors that are different to eachother
#so it'll be easier to tell candidates apart
myColors = c("red", "mediumblue", "green",
             "gray0","gold","deeppink", 
             "orangered", "tan4", "darkmagenta",
             "cyan","chartreuse","burlywood4",
             "forestgreen","mediumorchid3")
#get an array of each party's name, to subset general election data
republicanNames = unique(as.character(R$name))
democratNames = unique(as.character(D$name))
#primary master dataset
P = rbind(D,R)


#function to match prices from primary data to general election data,
#and compute conditional price
findConditionalPrice = function(row,frame){
  subframe = frame[which(as.character(frame$name) == 
                  as.character(row$name[1])),]
  #if PredictIt takes bets on someone running in a primary,
  #but not the general, return -1
  if(nrow(subframe) == 0){
    return(-1)
  }
  closestPrice = subframe$price[
    which.min(abs(strptime(row$date,"%Y-%m-%d.%H:%M:%S")-
                  strptime(subframe$date,"%Y-%m-%d.%H:%M:%S")))]
  #A closest price of .01 almost certainly means that the last trade was months ago, 
  #and the person is out of the race, if we kept this data in, we'd get weird results
  #like Bobby Jindal having a 100% chance of winning the general if he's nominated.
  if(closestPrice == .01){
    return(-1)
  }
  return(closestPrice/row$price)
}
#return candidate name if they are competitive
#return nonsense name: Droopy McCool if they aren't
isCompetitive = function(name, data){
  if(mean(data$price[data$name == name]) < .02){
    return("Droopy McCool")
  }
  return(name)
}


#Server
shinyServer(function(input, output) {
  output$thePlot = renderPlot({
    #set the current names to the names of those in the selected parties
    currNames = c()
    if(is.element(1, input$parties)){
     currNames = c(currNames, democratNames)
    }
    if(is.element(2,input$parties)){
     currNames = c(currNames,republicanNames)
    }
    data = data.frame()
    #set data based on user's choice what data they want to see
    if(input$typeChoice == 1) {data = G}
    
    if(input$typeChoice == 2){data = P}
    if(input$typeChoice == 3) {
      data = P
      if(input$nonCompetitives == 0){
        #clean noncompetitives. We have to do this here, 
        #so noncompetitives don't end up with high probabilities 
        #in the conditional part, and then don't get deleted below.
        names = as.character(unique(data$name))
        Competitives = sapply(X = names, FUN = isCompetitive, d = data)
        data = data[sapply(X = as.character(data$name), 
                           FUN = is.element, set = Competitives),]
      }
      #set the prices to conditional price
      #This should really be rewritten with apply rather than a loop...
      for (i in 1:length(data[,1])){
        data$price[i] = findConditionalPrice(data[i,],G)
      }
    }
    #take out data that is before the minimum date
    data = data[strptime(as.character(data$date), "%Y-%m-%d.%H:%M:%S")
                >= input$dates[1],]
    #take out data that is after the maximum date
    data = data[strptime(as.character(data$date), "%Y-%m-%d.%H:%M:%S")
                <= input$dates[2],]
    #take out data that was not set to -1 by setConditionalPrice  
    data = data[data$price != -1,]
    #provided that we have data left,
    #take out any data that is not in the list of current names
    #this would take out data of the wrong party, for example
    if(nrow(data)> 0){
      data = data[sapply(X = as.character(data$name),
                         FUN = is.element,set = currNames),]
      #If the user doesn't want data of irrelevant candidates, take them out.
      if(input$nonCompetitives == 0 && nrow(data)> 0){
        names = as.character(unique(data$name))
        Competitives = sapply(X = names, FUN = isCompetitive, d = data)
        data = data[sapply(X = as.character(data$name), 
                           FUN = is.element, set = Competitives),]
      }
    }
   
    #now that we've cleansed the data of unwanted names,
    #let's make currname into just those names that actually appear
    currNames = unique(data$name)
    #set up empty plot
    plot(c(input$dates[1], input$dates[2]),c(0,1), type = 'n',
      xlab = "Time", ylab = "Probability")
    
    #draw the lines onth  plot by name.
    for (i in 1:length(currNames)){
      lines(
        x = strptime(as.character(data$date[data$name == currNames[i]]),
                     "%Y-%m-%d.%H:%M:%S"),
        y = data$price[as.character(data$name) == currNames[i]],
                      col = myColors[i])
    }
    #provided that the plot is nonempty, add a legend
    if(length(currNames)> 0){
      par(xpd = TRUE)
      legend(x = "topleft", y = NULL, currNames,col = myColors, lty = c(1,1))
    }
    
 })#end render plot
  
}) #end server