library(shiny)
library(miniUI)
library(leaflet)
library(ggplot2)
library(shinyjs)
library(gt)

ui <- miniPage(
  
  useShinyjs(),
  
  miniTitleBar(img(src = "rpals_logo.png", height = "30px")),
  
  miniTabstripPanel(
    
    miniTabPanel("Parameters", icon = icon("sliders"),
                 miniContentPanel(
                   sliderInput("year", "Year", 1978, 2010, c(2000, 2010), sep = "")
                 )
    ),
    
    miniTabPanel("Visualize", icon = icon("area-chart"),
                 miniContentPanel(
                   plotOutput("cars", height = "100%")
                 )
    ),
    
    miniTabPanel(NULL, icon = miniButtonBlock(actionButton("logoff", "Log Off")),
                 miniContentPanel(padding = 0,
                                  leafletOutput("map", height = "100%")
                 ),
                 miniButtonBlock(
                   actionButton("resetMap", "Reset")
                 )
    ),
    
    miniTabPanel("Feed", icon = icon("table"),
                 miniContentPanel(
                   gt_output(outputId = "friends")
                 )
    )
    
  )
  
)

server <- function(input, output, session) {
  output$cars <- renderPlot({
    require(ggplot2)
    ggplot(cars, aes(speed, dist)) + geom_point()
  })
  
  output$map <- renderLeaflet({
    force(input$resetMap)
    
    leaflet(quakes, height = "100%") %>% addTiles() %>%
      addMarkers(lng = ~long, lat = ~lat)
  })
  
  observeEvent(input$logoff, stopApp(TRUE))
  
  output$table <- DT::renderDataTable({
    diamonds
  })
  
  observeEvent(input$done, {
    stopApp(TRUE)
  })
}

shinyApp(ui, server)