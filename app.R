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
  uiOutput("pic_path_out"),
  fluidRow(imageOutput("pic"), style = "height:510px; text-align: center;"),
  fluidRow(gt_output(outputId = "friends"))
  
)

server <- function(input,
                   output,
                   session) {
  output$pic_path_out <- renderUI({
    ui_pic_path <- textInput("pic_path", "", value = "ali-rose.jpg")
    shinyjs::hidden(ui_pic_path)
  })
  
  output$friends <-
    render_gt(expr = gt_tbl,
              height = px(600),
              width = px(600))
  
  output$pic <-
    renderImage({
      pic_path_value <-
        if_else(is.null(input$pic_path), "ali-rose.jpg", input$pic_path)
      list(
        src = str_glue("./www/{pic_path_value}"),
        height = "500px",
        contentType = "image/jpg"
      )
    }, deleteFile = FALSE)
  
  # Walk the gt table columns pic and snip and make an onclick method
  walk(c(gt_tbl$`_data`$pic, gt_tbl$`_data`$snip),
       ~ shinyjs::onclick(.x, {
         updateTextInput(inputId = "pic_path", value = .x)
       }))
}


shinyApp(ui, server)
