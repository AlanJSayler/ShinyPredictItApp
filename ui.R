library(shiny)
range = read.csv('dateRange.csv', header = FALSE)
first = strptime(as.character(range[1,]), format = "%Y-%m-%d.%H:%M:%S")
last = strptime(as.character(range[2,]), format =  "%Y-%m-%d.%H:%M:%S")
shinyUI(fluidPage(
  
  #Title
  titlePanel(title = "U.S. Presidential Election, 
              According to Gamblers at PredictIt.org"),
  
 
  sidebarLayout(
    sidebarPanel(
      #get input about what the user wants to see - general election
      #probabilities, nomination probability,
      #or electability/conditional probability
      radioButtons("typeChoice", label = "Mode",  choices = list(
        "Probability of General Election Win" = 1,
        "Probability of Party Nomination" = 2,
        "Electability*" = 3), 
        selected = 1),
      #get data about which party the user wants to see
      checkboxGroupInput("parties", label = "Parties", choices = list(
        "Democrats" = 1,
        "Republicans" = 2),
        selected = c(1,2)),
      #get data from user about the time range they want
      sliderInput("dates", label = "Time Range", 
        min = first,
        max = last,
        value = c(first,last) 
        ),
      #get input for if the user wants only competitive candidates
      checkboxInput("nonCompetitives",
        label = "Show dropped out and non-competitive candidates",
        value = 0),
      em("* Electibility is defined here as the probability of a general
          election win, assuming party nomination.
          PredictIt does not take bets on this, instead, 
          it is calculated in the app. Note that this is working under the 
          assumption that no candidate can win without
          their party nomination,which may or may not be true")
    ), #end sidebar
    
    
    # Show the lineplot
    mainPanel(
      plotOutput("thePlot"),
      
      helpText(h4("Overview"), 
        div("This app displays the estimated probabilities of candidates 
              winning their party's nomination, the general election, 
              and winning the general election, provdided that they are nominated. 
              Probabilities are estimated by the ", 
        a("prediction market", 
          href="https://en.wikipedia.org/wiki/Prediction_market"), 
        a("PredictIt.org.", href='https://www.predictit.org/'),
        br(), br(),
        p("A prediction market functions as an indicator of what 
          'the crowd' thinks is the probability of an event - 
          `as any person who believes that the current price 
          overestimates or underestimates the probability of an event
          can buy or sell shares, expecting to make money.")
        ),
        h4("Why are the range of explorable dates so small?"),
        div("PredictIt's API acts like a stock ticker,
            giving only current price information. As such,
            the app only has historical price information from when this 
            project began."),
        h4("Can I modify and redistribute this app?"),
        a("Yes", href='https://github.com/AlanJSayler/ShinyPredictItApp')
      )
    )
  )
))
