pacman::p_load(RefManageR, dplyr, stringr, anytime, tidyr, stringi)

mypubs   <- ReadBib("referencias/posts/ciencia-abierta.bib", check = "warn", .Encoding = "UTF-8") %>%
  as.data.frame()

View(mypubs)


mypubs   <- ReadBib("content/publication/academic-presentations.bib", check = "warn", .Encoding = "UTF-8") %>%
  as.data.frame()

names(mypubs)
