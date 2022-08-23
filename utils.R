action_button_gt <- function(value, inputid, ts, ...) {
  as.character(shiny::actionLink(paste0(value, inputid, ts),
                                   ...)) %>%
    gt::html()
}

read_user_story <- function(uname, ts) {
  readr::read_csv("stories.csv") %>% 
    dplyr::filter(uname == uname, story_time == lubridate::ymd_hms(ts)) %>% 
    purrr::pluck("story")
}

open_user_file <- function(text, user, file_ext, session_temp_dir) {
  file_path <- stringr::str_glue("{session_temp_dir}\\\\@{user}{file_ext}")
  
  readr::write_file(text, file_path)
  
  rstudioapi::navigateToFile(file_path)
}

read_pals <- function() {
  readr::read_csv("pals.csv")
}

read_stories <- function(story_index) {
  readr::read_csv("stories.csv") %>%
    dplyr::arrange(desc(story_time)) %>% 
    dplyr::slice((story_index * 5 - 4):(story_index * 5))
}

read_creds <- function() {
  readr::read_csv("creds.csv")
}
