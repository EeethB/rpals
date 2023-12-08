library(magrittr)

source("utils.R")
source("read_data.R")

ui <- miniUI::miniPage(
  shinyjs::useShinyjs(),
  
  miniUI::miniTitleBar(
    title = shiny::img(src = "rpals_logo.png", height = "30px"),
    
    right = shinyauthr::logoutUI(id = "logout"),
    
    left = shiny::uiOutput("welcome_user")
    
  ),
  
  miniUI::miniTabstripPanel(
    miniUI::miniTabPanel(
      title = "Sign Up",
      
      icon = shiny::icon("fas fa-user-plus"),
      
      miniUI::miniContentPanel(
        shiny::fileInput("signup_pfp", "Profile pic"),
        shiny::textInput("signup_uname", "Username"),
        shiny::passwordInput("signup_pwd", "Password")
        
      )
      
    ),
    
    miniUI::miniTabPanel(
      title = "Log In",
      
      icon = shiny::icon("fas fa-sign-in-alt"),
      
      miniUI::miniContentPanel(shinyauthr::loginUI(id = "login"))
      
    ),
    
    miniUI::miniTabPanel(
      title = "Feed",
      
      icon = shiny::icon("table"),
      
      miniUI::miniContentPanel(
        gt::gt_output("stories"),
        
        shiny::actionButton(
          "refresh_stories",
          "Refresh",
          icon = shiny::icon("fas fa-refresh")
        ),
        
        shiny::actionButton(
          "next_page",
          "Next",
          icon = shiny::icon("fas fa-arrow-right")
        )
        
      )
      
    ),
    
    miniUI::miniTabPanel(
      title = "Story",
      
      icon = shiny::icon("far fa-file-code"),
      
      miniUI::miniContentPanel(uiOutput("story_inputs"))
      
    )
    
  )
  
)

server <- function(input, output, session) {
  # Auth ----------------------------------------------------------------------
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = df_creds,
    user_col = user,
    pwd_col = password,
    log_out = shiny::reactive(logout_init())
  )
  
  logout_init <- shinyauthr::logoutServer(id = "logout",
                                          active = shiny::reactive(credentials()$user_auth))
  
  output$welcome_user <- shiny::renderUI({
    req(credentials()$user_auth)
    
    shiny::em(paste0("Welcome @", credentials()$info$user))
    
  })
  
  page_number <- shiny::reactiveVal(1)
  
  shiny::observeEvent(input$refresh_stories, page_number(1))
  shiny::observeEvent(input$next_page, page_number(page_number() + 1))
  
  # Other ---------------------------------------------------------------------
  df_stories <- shiny::reactive(read_stories(page_number()) %>%
      dplyr::left_join(read_pals(), by = "uname") %>%
      dplyr::mutate(button = purrr::map2(
        .x = uname,
        .y = stringr::str_replace_all(story_time, "[[:punct:]|[:space:]]", "_"),
        .f = ~ action_button_gt(
          .x,
          "_story_",
          .y,
          label = fontawesome::fa("far fa-file-code",
                                  stroke = "grey",
                                  height = "30px")
        )
      ))
  )
  
  # Render pals gt, including subbing in PFPs ---------------------------------
  output$stories <- gt::render_gt({
    gt::gt(df_stories()) %>%
      gt::text_transform(
        locations = gt::cells_body(columns = c("pic")),
        fn = function(x) {
          paste0("<img id=", x, " src=", x, " height=30px></img>")
        }
      ) %>%
      gt::cols_hide(c(file_type, story, story_time)) %>%
      gt::cols_move(c(uname, name, button), after = pic)
    
  })
  
  # Apply an onclick method to the `button` column in the stories gt ----------
  shiny::observe({
    purrr::pwalk(
      .l = dplyr::select(df_stories(), uname, story_time, file_type),
      .f = ~ shinyjs::onclick(
        id = paste0(
          ..1,
          "_story_",
          stringr::str_replace_all(..2, "[[:punct:]|[:space:]]", "_")
        ),
        expr = {
          story <- read_user_story(..1, ..2)
          open_user_file(story, ..1, ..3, tempdir())
        }
        
      )
      
    )
    
  })
  
  # Render story inputs only after successful auth ----------------------------
  output$story_inputs <- shiny::renderUI({
    req(credentials()$user_auth)
    
    shiny::tagList(
      shiny::selectInput(
        "file_type",
        "File Type",
        c("R", "Python", "SQL", "Markdown", "RMarkdown", "Other"),
        selected = "R"
      ),
      
      shiny::textInput(
        "file_ext_other",
        "Other File Extension",
        placeholder = ".sas"
      ),
      
      shiny::actionButton(
        "story_current",
        "Story from current script",
        icon = shiny::icon("far fa-file-code")
      ),
      
      shiny::actionButton(
        "story_clip",
        "Story from Clipboard",
        icon = shiny::icon("fas fa-clipboard-list")
      ),
      
      # shiny::fileInput("story-file")
      
    )
    
  })
  
  # Create a story actions ----------------------------------------------------
  shiny::observeEvent(
    input$story_current,
    {
      text <- rstudioapi::getSourceEditorContext() %>%
        purrr::pluck("contents") %>%
        paste(collapse = "\n")
      
      file_ext <- dplyr::if_else(
        input$file_type == "Other",
        input$file_ext_other,
        df_file_types %>%
          dplyr::filter(file_type == input$file_type) %>%
          purrr::pluck("file_ext")
      )
      
      story_entry <- tibble::tibble(
        uname = credentials()$info$user,
        story = text,
        story_time = lubridate::now("UTC"),
        file_type = file_ext
      )
      
      readr::write_csv(story_entry, "stories.csv", append = TRUE)
      
    }
  )
  
  shiny::observeEvent(
    input$story_clip,
    {
      text <- clipr::read_clip(allow_non_interactive = TRUE) %>%
        paste(collapse = "\n")
      
      file_ext <- dplyr::if_else(
        input$file_type == "Other",
        input$file_ext_other,
        df_file_types %>%
          dplyr::filter(file_type == input$file_type) %>%
          purrr::pluck("file_ext")
      )
      
      story_entry <- tibble::tibble(
        uname = credentials()$info$user,
        story = text,
        story_time = lubridate::now("UTC"),
        file_type = file_ext
      )
      
      readr::write_csv(story_entry, "stories.csv", append = TRUE)
      
    }
    
  )
  
}

shiny::shinyApp(ui, server)
