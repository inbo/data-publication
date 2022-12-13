# Removing linebreaks from input csv file

library(dplyr)


# read input file, for every column, replace newlines: \n with spaces
dt_linebreaks_removed <- 
  here::here(
  "datasets",
  "eikenprocessierups-occurrences",
  "data",
  "processed",
  "occurrence.csv"
) %>% 
  data.table::fread() %>% 
  mutate(across(everything(),~stringr::str_replace(.x,"\n"," ")))



# write out, and count lines ----------------------------------------------

# we want the number of lines in the output file to be equal to the number of
# expected records

# file path to write to
out_path <- 
  here::here(
    "datasets",
    "eikenprocessierups-occurrences",
    "data",
    "processed",
    "occurrence_no_linebreaks.csv")

dt_linebreaks_removed %>% 
  data.table::fwrite(out_path)

# number of lines in output file should be the number of records +1 for the header
length(readLines(out_path)) - 1 == nrow(dt_linebreaks_removed)
