action_button_gt <- function(value, inputid, ...) {
  as.character(shiny::actionLink(paste0(value, inputid),
                                   ...)) %>%
    gt::html()
}

open_user_file <- function(text, user, session_temp_dir) {
  file_path <- str_glue("{session_temp_dir}\\\\@{user}.R")
  
  write_file(text, file_path)
  
  rstudioapi::navigateToFile(file_path)
}