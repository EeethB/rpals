library(magrittr)

source("utils.R")
source("read_data.R")

ui <- miniUI::miniPage(
  shinyjs::useShinyjs(),
  
  miniUI::miniTitleBar(
    title = shiny::img(src = "rpals_logo.png", height = "30px"),
    
    right = shinyauthr::logoutUI(id = "logout")
    
  ), 

  miniUI::miniTabstripPanel(
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
          "story-current",
          "Story from current script",
          icon = shiny::icon("far fa-file-code")
        ),

        shiny::actionButton(
          "story-clip",
          "Story from Clipboard",
          icon = shiny::icon("far fa-clipboard-list")
        ),

        # shiny::fileInput("story-file")

      )

    ),

    miniUI::miniTabPanel(
      title = "Story",

      icon = shiny::icon("far fa-file-code"),

      miniUI::miniContentPanel()

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
  
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = shiny::reactive(credentials()$user_auth)
  )
  
  # Other ---------------------------------------------------------------------
  df_pals <- shiny::eventReactive(input$reload_pals, {
    read_pals() %>%
      dplyr::mutate(button = purrr::map(
        uname,
        .f = ~ action_button_gt(
          .x,
          "_story",
          label = fontawesome::fa(
            "far fa-file-code",
            stroke = "grey",
            height = "30px"
          )
        )
      ))
    
  })
  
  stories_index <- 1
  
  df_stories <- shiny::eventReactive(input$refresh_stories, {
    read_stories(stories_index) %>%
      dplyr::left_join(read_pals(), by = "uname") %>% 
      dplyr::mutate(button = purrr::map2(
        .x = uname,
        .y = stringr::str_replace_all(story_time, "[[:punct:]|[:space:]]", "_"),
        .f = ~ action_button_gt(
          .x,
          "_story_",
          .y,
          label = fontawesome::fa(
            "far fa-file-code",
            stroke = "grey",
            height = "30px"
          )
        )
      ))
    
  })
  
  # df_stories <- reactive(read_stories())
  
  # Render pals gt, including subbing in PFPs ---------------------------------
  output$pals <- gt::render_gt({
    gt::gt(df_pals()) %>%
      gt::text_transform(
        locations = gt::cells_body(columns = c("pic")),
        fn = function(x) {
          paste0("<img id=", x, " src=", x, " height=30px></img>")
        }
      )
    
  })
  
  # Render pals gt, including subbing in PFPs ---------------------------------
  output$stories <- gt::render_gt({
    gt::gt(df_stories()) %>%
      gt::text_transform(
        locations = gt::cells_body(columns = c("pic")),
        fn = function(x) {
          paste0("<img id=", x, " src=", x, " height=30px></img>")
        }
      ) %>% 
      gt::cols_hide(c(story, story_time)) %>% 
      gt::cols_move(c(uname, name, button), after = pic)
    
  })
  
  # Apply an onclick method to the `button` column in the pals gt -------------
  shiny::observe({
    purrr::walk(df_pals()$uname,
                ~ shinyjs::onclick(paste0(.x, "_story"), {
                  read_user_story(.x, .y)
                  open_user_file(paste0("# ", .x, "'s code"), .x, tempdir())
                }))
    
  })
  
  shiny::observe({
    purrr::walk2(df_stories()$uname, stringr::str_replace_all(df_stories()$story_time, "[[:punct:]|[:space:]]", "_"),
                ~ shinyjs::onclick(paste0(.x, "_story_", .y), {
                  story <- read_user_story(.x, .y)
                  open_user_file(story, .x, tempdir())
                }))

  })
  
}

shiny::shinyApp(ui, server)