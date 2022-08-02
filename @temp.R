library(tidyverse)

mems <- tribble(
  ~name, ~uname, ~pic, ~status, ~snip,
  "Jacquelyn Nolis", "skyetetra", "ali-rose.jpg", "stats before cool", "mt-hood-flower.jpg",
  "Hadley Wickham", "hadley", "crater-lake.jpg", "make a package", "lichen-1.jpg",
  "Ryan Timpe", "ryantimpe", "kernave-1.jpg", "LEGO! Golden Girls!", "kernave-2.jpg"
)

write_csv(mems, "mems.csv")
