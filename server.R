library(shiny)

draw.tennis <- function( length = 78, width = 36, main.title = "BYU Tennis", color.1 = "aquamarine3", color.2 = "white") {
  plot( NA, xlim = c(-7, length+7), ylim = c(-5, width+5), main = main.title, ylab = "", xlab = "", xaxt = "n", yaxt = "n")
  polygon(c(-7,-7, length+7, length+7), c(-5, width+5, width+5, -5), lwd = 2, col = color.1, border = color.1)
  polygon(c(0,0,length,length), c(0,width,width,0), lwd = 2, col = color.1, border = color.2)
  segments(length/2, 0, length/2, width, lwd = 5, col = color.2)
  segments(18, 9/2, 18, width - 9/2, lwd = 2, col = color.2)
  segments(length - 18, 9/2, length - 18, width - 9/2, lwd = 2, col = color.2)
  segments(0, 9/2, length, 9/2, lwd = 2, col = color.2)
  segments(0, width - 9/2, length, width - 9/2, lwd = 2, col = color.2)
  segments(18, width/2, length/2, width/2, lwd = 2, col = color.2)
  segments(length/2, width/2, length - 18, width/2, lwd = 3, col = color.2)
}


shinyServer(function(input, output, session){
  
  output$myplot <- renderPlot({ 
    draw.tennis(78, 36) # play with this til it looks right
    points(val$x,val$y,pch=ifelse(val$skill %in% c("Serve", "Forehand Return", "Backhand Return", "Ace", "Point Won", "Point Lost", "Fault",
                                                   "Double Fault","Opponent Return", "Opponent Serve", "Opponent Ace"),19,4),
           col=ifelse(val$skill %in% c("Opponent Serve","Opponent Ace","Opponent Return", "Point Lost"),'red','blue')
    )
  })
  
  val <- reactiveValues(x=NULL, y=NULL, skill=NULL, temp.value=NULL)
  
  observe({
    if (is.null(input$myplot_click)){ return() }
    isolate(val$x <- c(val$x, input$myplot_click$x))
    isolate(val$y <- c(val$y, input$myplot_click$y))
    isolate(val$skill <- c(val$skill, input$radio))
    
    isolate({
      val$temp.value <- input$radio
      if(val$temp.value == "Ace"){
        updateNumericInput(session,"aces",value=input$byu.goals + 1)
        updateNumericInput(session,"serves",value=input$byu.sog + 1)
        updateNumericInput(session,"points.won",value=input$byu.sog + 1)
      }
      if(val$temp.value == "Point Won"){
        updateNumericInput(session,"points.won",value=input$opponent.goals + 1)
        updateNumericInput(session,"points.played",value=input$opponent.goals + 1)
      }
      if(val$temp.value == "Point Lost"){
        updateNumericInput(session,"points.lost",value=input$byu.shots + 1)
      }
      if(val$temp.value == "Opponent Ace"){
        updateNumericInput(session,"opponent.aces",value=input$opponent.shots + 1)
        updateNumericInput(session,"points.lost",value=input$opponent.shots + 1)
      }
      if(val$temp.value == "Fault"){
        updateNumericInput(session,"faults",value=input$byu.shots + 1)
      }
      if(val$temp.value == "Doublt Fault"){
        updateNumericInput(session,"faults",value=input$opponent.shots + 1)
        updateNumericInput(session,"double.faults",value=input$opponent.sog + 1)
      }
      if(val$temp.value == "Point Lost"){
        updateNumericInput(session,"points.lost",value=input$byu.fouls + 1)
        updateNumericInput(session,"points.played",value=input$byu.fouls + 1)
      }
    })
      
    isolate({
      val$temp.value <- input$radio
      if(val$temp.value %in% c("Serve", "Backhand Return", "Forehand Return")){
        updateRadioButtons(session,"radio",selected="Opponent Return")
      }
    })
    isolate({
      val$temp.value <- input$radio
      if(val$temp.value %in% c("Opponent Return", "Opponent Serve")){
        updateRadioButtons(session,"radio",selected="Forehand Return")
      }
    })
    isolate({
      val$temp.value <- input$radio
      if(val$temp.value %in% c("Point Won", "Point Lost", "Ace", "Fault", "Double Fault")){
        updateRadioButtons(session,"radio",selected="Serve")
      }
    })
    isolate({
      val$temp.value <- input$radio
      if(val$temp.value %in% c("Opponent Ace")){
        updateRadioButtons(session,"radio",selected="Opponent Serve")
      }
    })
  })
  
  observe({
    if (input$clear > 0){
      val$x <- NULL
      val$y <- NULL
      val$skill <- NULL
      updateNumericInput(session,"serves",value=0)
      updateNumericInput(session,"faults",value=0)
      updateNumericInput(session,"double.faults",value=0)
      updateNumericInput(session,"aces",value=0)
      updateNumericInput(session,"points.won",value=0)
      updateNumericInput(session,"points.lost",value=0)
      updateNumericInput(session,"points.played",value=0)
      updateNumericInput(session,"opponent.serves",value=0)
      updateNumericInput(session,"opponent.aces",value=0)
      updateNumericInput(session,"points.lost",value=0)
     }
  })
  
  output$data <- renderTable({ data.frame(skill=val$skill,x=val$x,y=val$y) })
  
  output$opponent.name <- renderText({ input$opponent })
  
  output$downloadData <- downloadHandler(
    filename = function() { paste(input$opponent,input$half,'.csv',sep='') },
    content = function(file) { write.csv(data.frame(skill=val$skill,x=val$x,y=val$y,
                                                    opponent=input$opponent,
                                                    venue=input$home,
                                                    set=input$set,
                                                    gender=input$gender,
                                                    year=input$year,
                                                    weather=input$weather),
                                         file) }
  )
  
})
