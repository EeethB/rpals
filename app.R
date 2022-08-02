library(shiny)
library(miniUI)
library(shinyjs)
library(tidyverse)
library(gt)
library(gtExtras)
library(shinyauthr)
library(rstudioapi)

# Here is a Shiny app (contained within
# a single file) that (1) prepares a
# gt table, (2) sets up the `ui` with
# `gt_output()`, and (3) sets up the
# `server` with a `render_gt()` that
# uses the `gt_tbl` object as the input
# expression

action_button_gt <- function(value, inputid, ...){
  as.character(
    shiny::actionButton(
      paste0(value, inputid),
      ...
    )
  ) %>% 
    gt::html()
}

open_user_file <- function(text, user, session_temp_dir) {
  file_path <- str_glue("{session_temp_dir}\\\\@{user}.R")
  
  write_file(text, file_path)
  
  rstudioapi::navigateToFile(file_path)
}

df_mems <- read_csv("mems.csv")

df_creds <- read_csv("creds.csv")

ui <- fluidPage(
  useShinyjs(),
  
  miniTitleBar(img(src = "rpals_logo.png", height="30px")),
  
  fluidRow(
    loginUI(id = "login"),
    uiOutput("pic_path_out", value = "rpals_logo.png"),
    fluidRow(imageOutput("pic"), style = "height:260px; text-align: center;")
  ),
  
  sidebarLayout(
    sidebarPanel(
      logoutUI(id = "logout"),
      width = 3
    ),
    
    mainPanel(
      gt_output(outputId = "friends"),
      textOutput(outputId = "uname_pwd"),
      width = 9
    )
    
  ),
  
)

server <- function(input,
                   output,
                   session) {
  output$pic_path_out <- renderUI({
    req(credentials()$user_auth)
    ui_pic_path <-
      textInput("pic_path", "", value = "rpals_logo.png")
    shinyjs::hidden(ui_pic_path)
  })
  
  gt_tbl <- shiny::reactive({
    df_mems %>%
      mutate(
        snip = "far fa-file-code",
        button = map(uname, .f = ~action_button_gt(.x, "_button",label = fontawesome::fa("far fa-file-code", stroke = "grey")))
      ) %>%
      gt() %>%
      gt_fa_column(snip, palette = "grey") %>% 
      text_transform(
        locations = cells_body(columns = c("pic")),
        fn = function(x) {
          paste0("<img id=", x, " src=", x, " height=30px></img>")
          # web_image(url = x)
        }
      )
  })
  
  output$friends <-
    render_gt({
      req(credentials()$user_auth)
      
      gt_tbl()
    },
    height = px(600),
    width = px(600))
  
  output$pic <-
    renderImage({
      req(credentials()$user_auth)
      pic_path_value <- input$pic_path
      list(
        src = str_glue("./www/{pic_path_value}"),
        height = "250px",
        contentType = "image/jpg"
      )
    }, deleteFile = FALSE)
  
  # Walk the gt table columns pic and snip and make an onclick method
  reactive({walk(c(gt_tbl()$`_data`$pic),
       ~ shinyjs::onclick(.x, {
         updateTextInput(inputId = "pic_path", value = .x)
         # open_user_file(.x, ".x", tempdir())
       }))})
  # 
  # walk(c(gt_tbl$`_data`$snip),
  #      ~ shinyjs::onclick(.x, {
  #        open_user_file(".x", ".x", tempdir())
  #      }))

  shinyjs::onclick("pic", {
    req(credentials()$user_auth)
    updateTextInput(inputId = "pic_path", value = "rpals_logo.png")
  })

  shinyjs::onclick("td.gt_row.gt_left", {
    open_user_file(.x, "text_cols", tempdir())
  })
  
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = df_creds,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init())
  )
  
  logout_init <- shinyauthr::logoutServer(id = "logout",
                                          active = reactive(credentials()$user_auth))
}


shinyApp(ui, server)
