# #
# # This is a Shiny web application. You can run the application by clicking
# # the 'Run App' button above.
# #
# # Find out more about building applications with Shiny here:
# #
# #    http://shiny.rstudio.com/
# #
# 
# library(shiny)
# library(DT)
# library(tidyverse)
# library(shinydashboard)
# 
# # Define UI for application that draws a histogram
# ui <- fluidPage(
#     DT::dataTableOutput("flower")
# )
# 
# # Define server logic required to draw a histogram
# server <- function(input, output) {
#     
#     output$flower <- renderDataTable({
#         dat <- tibble::tibble(file = dir("www")) %>% 
#           mutate(image = str_glue('<img src="{file}" height = "25"></img>')) %>%
#           pivot_wider(names_from = file, values_from = image)
#         
#         datatable(dat, escape = F)
#         }
#     )
# }
# 
# # Run the application 
# shinyApp(ui = ui, server = server)




library(shiny)
library(tidyverse)
library(gt)

# Here is a Shiny app (contained within
# a single file) that (1) prepares a
# gt table, (2) sets up the `ui` with
# `gt_output()`, and (3) sets up the
# `server` with a `render_gt()` that
# uses the `gt_tbl` object as the input
# expression

gt_tbl <- read_csv("mems.csv") %>% 
  gt() %>% 
  text_transform(
    locations = cells_body(columns = c("pic", "snip")),
    fn = function(x) {
      paste0("<img id=", x, " src=", x, " height=30px></img>")
      # web_image(url = x)
    }
  )

ui <- fluidPage(
  shinyjs::useShinyjs(),
  gt_output(outputId = "friends"),
  imageOutput("pic")
)

server <- function(input,
                   output,
                   session) {
    
  output$friends <-
    render_gt(
      expr = gt_tbl,
      height = px(600),
      width = px(600)
    )
  
  output$pic <-
    renderImage({list(src = "./www/ali-rose.jpg", width = "50px", height = "50px", contentType = "image/jpg")}, deleteFile = FALSE)
  
  walk(c(gt_tbl$`_data`$pic, gt_tbl$`_data`$snip),
       ~shinyjs::onclick(.x, shinyjs::info(date())))
}


shinyApp(ui, server)
