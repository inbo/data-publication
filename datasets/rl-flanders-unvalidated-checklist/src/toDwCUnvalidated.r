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
exploratory::read_delim_file("C:\\Users\\dimitri_brosens\\Documents\\GitHub\\data-publication\\datasets\\rl-flanders-unvalidated-checklist\\data\\raw\\NonValidatedRedListsSource.csv" , ";", quote = "\"", skip = 0 , col_names = TRUE , na = c("","NA") , locale=readr::locale(encoding = "ISO-8859-1", decimal_mark = "."), trim_ws = FALSE , progress = FALSE) %>% exploratory::clean_data_frame() %>%
  mutate(license = "http://creativecommons.org/publicdomain/zero/1.0/", rightsHolder = "INBO", accessRights = "http://www.inbo.be/en/norms-for-data-use", datasetName = "UnValidated Red Lists of Flanders", locationID = "http://marineregions.org/mrgid/2469", locality = "Flanders", countryCode = "BE", occurrencestatus = "present" )  %>%
  rename(scientificName = SpeciesnameAsPublished) %>%
  
  # add column threadStatus
  mutate(threadStatus = str_replace(RLCAsPublished,"Bedreigd","Endangered (EN)" )) %>%
  
  # List Code translation
  mutate(threadStatus = str_replace(threadStatus,"Bedreigd","Endangered (EN)" ), threadStatus = str_replace(threadStatus, "Kwetsbaar", "Vulnerable (VU)"),threadStatus = str_replace(threadStatus, "Ernstig bedreigd","Critically Endangered (CR)") , threadStatus = str_replace(threadStatus, "Momenteel niet bedreigd","Least Concern (LC)"), threadStatus = str_replace(threadStatus,"Momenteel niet in gevaar","Least Concern (LC)" ), threadStatus = str_replace(threadStatus," Met uitsterven bedreigd","Critically Endangered (CR)" ), threadStatus = str_replace(threadStatus,"Bijna in gevaar","Near Threatened (NT)" ), threadStatus = str_replace(threadStatus,"Met uitsterven bedreigd","Critically Endangered (CR)" ), threadStatus = str_replace(threadStatus,"Zeldzaam","Near Threatened (NT)" ), threadStatus = str_replace(threadStatus, "Uitgestorven","Regionally Extinct (REX)"), threadStatus = str_replace(threadStatus, "Achteruitgaand","Near Threatened (NT)"), threadStatus = str_replace(threadStatus,"Onvoldoende gekend","Data Deficient (DD)" ), threadStatus = str_replace(threadStatus, "Onvoldoende data ", "Data Deficient (DD)"	), threadStatus = str_replace(threadStatus, "Regionaal uitgestorven","Regionally Extinct (EX)"), threadStatus = str_replace(threadStatus, "maar mate waarin ongekend","uncertain rate"), threadStatus = str_replace(threadStatus, "in Vlaanderen","in Flanders"))      