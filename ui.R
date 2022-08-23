library(magrittr)

# Define UI for application that draws a histogram
miniUI::miniPage(
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
