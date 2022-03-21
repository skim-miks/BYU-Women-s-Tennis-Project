library(shiny)
library(plotrix)
shinyUI(fluidPage(
  titlePanel("BYU Tennis Analytics"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("radio", label = h3("Select a skill"),
                   choices = c("Serve", "Ace", "Fault", "Double Fault", "Forehand Return", "Backhand Return", 
                               "Opponent Return", "Opponent Serve", "Opponent Ace", "Point Won", "Point Lost"),
                   selected = "Serve"),
      br(),
      fluidRow(
        column(3, actionButton("clear", label = "Clear")),
        column(5, downloadButton('downloadData', 'Download'))
      )
    ),
    
    mainPanel(
      fluidRow(
        column(4, textInput("opponent", "Specify Opponent")),
        column(4, selectInput("home", "Home or Away", choices = c("Home", "Away"), selected = "Home")),
        column(4, selectInput("set", "Select Set", choices = list("1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5,
                                                                  "6" = 6, "7" = 7, "8" = 8, "9" = 9, "10" = 10), selected = 1)) 
      ),
      fluidRow(
        column(4, selectInput("gender", "Men's or Womens", choices = c("Men","Women"), selected = "Women")),
        column(4, selectInput("year","Select Year", choices = c("2014","2015","2016","2017"), selected = "2017")),
        column(4, selectInput("weather","Weather Type", choices = c("Indoor","Moderate","Hot","Cold","Stormy","Cloudy","Windy"),
                              selected = "Moderate"))
      ),
      plotOutput("myplot", width="100%", height="700px", click = "myplot_click"),
      fluidRow(
        column(3, tableOutput("data")),
        column(9, 
               fluidRow(h4("If possible, fill in the following box score information")),
               fluidRow(
                 column(2, helpText("     ")),
                 column(4, h5("BYU")),
                 column(4, h5(textOutput("opponent.name")))  
               ),
               fluidRow(
                 column(2, helpText("Serves")),
                 column(4, numericInput("serves", label = "", value = 0)),
                 column(4, numericInput("opponent.serves", label = "", value = 0))
               ),
               fluidRow(
                 column(2, helpText("Points")),
                 column(4, numericInput("points.won", label = "", value = 0)),
                 column(4, numericInput("points.lost", label = "", value = 0))
               ),
               fluidRow(
                 column(2, helpText("Aces")),
                 column(4, numericInput("aces", label = "", value = 0)),
                 column(4, numericInput("opponent.aces", label = "", value = 0))
               ),
               fluidRow(
                 column(2, helpText("Faults")),
                 column(4, numericInput("faults", label = "", value = 0)),
                 column(4, numericInput("double.faults", label = "", value = 0))
               )
               
        )
      )
    )
  )
))


# more detailed opponent
# shot type

