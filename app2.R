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
      
      miniUI::miniContentPanel(
        
        shinyauthr::loginUI(id = "login")
      
      )
      
    ),
    
    miniUI::miniTabPanel(
      
      title = "Feed",
      
      icon = shiny::icon("table"),
      
      miniUI::miniContentPanel(
        
        gt::gt_output("pals"),
        
        shiny::actionButton("reload_pals", "Refresh",
                          icon = shiny::icon("fas fa-refresh")),
        
        shiny::actionButton("story-current", "Story from current script",
                          icon = shiny::icon("far fa-file-code")),
        
        shiny::actionButton("story-clip", "Story from Clipboard",
                          icon = shiny::icon("far fa-clipboard-list")),
        
        # shiny::fileInput("story-file")
        
      )
    
    ), 
    
    miniUI::miniTabPanel(
      
      title = "Story",
      
      icon = shiny::icon("far fa-file-code"),
      
      miniUI::miniContentPanel(
                   
      )
      
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
    log_out = reactive(logout_init())
  )
  
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
  
  # Other ---------------------------------------------------------------------
  df_pals <- eventReactive(input$reload_pals, {
    
    read_pals() %>%
      dplyr::mutate(button = purrr::map(
        uname,
        .f = ~ action_button_gt(
          .x,
          "_button",
          label = fontawesome::fa("far fa-file-code", stroke = "grey", height = "30px")
        )
      ))
    
  })
  
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
  
  # Apply an onclick method to the `button` column in the pals gt -------------
  shiny::observe({
    purrr::walk(
      df_pals()$uname,
      ~ shinyjs::onclick(paste0(.x, "_button"), {
        open_user_file(paste0("# ", .x, "'s code"), .x, tempdir())
      })
    )
  })
  
}

shiny::shinyApp(ui, server)