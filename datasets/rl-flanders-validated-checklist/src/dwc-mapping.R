# Set libPaths.
.libPaths("C:\\Users\\dimitri_brosens\\.exploratory\\R\\3.4")

# Load required packages.
library(janitor)
library(lubridate)
library(hms)
library(tidyr)
library(stringr)
library(readr)
library(forcats)
library(RcppRoll)
library(dplyr)
library(tibble)
library(exploratory)

# Steps to produce the output
exploratory::read_delim_file("C:\\Users\\dimitri_brosens\\Documents\\GitHub\\data-publication\\datasets\\rl-flanders-checklist\\data\\ValidatedRedListsSource.csv" , ";", quote = "\"", skip = 0 , col_names = TRUE , na = c("","NA") , locale=readr::locale(encoding = "ISO-8859-1", decimal_mark = "."), trim_ws = FALSE , progress = FALSE) %>% exploratory::clean_data_frame()