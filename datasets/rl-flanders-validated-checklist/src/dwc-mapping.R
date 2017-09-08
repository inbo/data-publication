# Set libPaths.
.libPaths(CUsersdimitri_brosens.exploratoryR3.4)

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
exploratoryread_delim_file(CUsersdimitri_brosensDocumentsGitHubdata-publicationdatasetsrl-flanders-checklistdataValidatedRedListsSource.csv , ;, quote = , skip = 0 , col_names = TRUE , na = c(,NA) , locale=readrlocale(encoding = ISO-8859-1, decimal_mark = .), trim_ws = FALSE , progress = FALSE) %% exploratoryclean_data_frame() %%
  rename(taxonID = UniqueID) %%
  mutate(license = httpcreativecommons.orgpublicdomainzero1.0, rightsHolder = INBO, accessRights = httpwww.inbo.beennorms-for-data-use, datasetName = Validated Red Lists of Flanders, locationID = httpmarineregions.orgmrgid2469, locality = Flanders, countryCode = BE, occurrencestatus = present, threadStatus = str_replace(RLCAsPublished,Bedreigd,Endangered (EN) ), threadStatus = str_replace(threadStatus, Kwetsbaar, Vulnerable (VU))
, threadStatus = str_replace(threadStatus, Ernstig bedreigd,Critically Endangered (CR)), threadStatus = str_replace(threadStatus, Momenteel niet bedreigd,Least Concern (LC))) %%
  select(-RLCAsPublished, everything(), -RLC, everything()) %%
  
  # Translate Criteria Dutch - IUCN Creteria
  mutate(threadStatus = str_replace(threadStatus,Momenteel niet in gevaar,Least Concern (LC) ), threadStatus = str_replace(threadStatus,	Met uitsterven bedreigd,Critically Endangered (CR) ), threadStatus = str_replace(threadStatus,Bijna in gevaar,Near Threatened (NT) ), threadStatus = str_replace(threadStatus,Met uitsterven bedreigd,Critically Endangered (CR) ), threadStatus = str_replace(threadStatus,Zeldzaam,Near Threatened (NT) ), threadStatus = str_replace(threadStatus, Uitgestorven,Regionally Extinct (REX)), threadStatus = str_replace(threadStatus, Achteruitgaand,Near Threatened (NT)), threadStatus = str_replace(threadStatus,Onvoldoende gekend,Data Deficient (DD) ), threadStatus = str_replace(threadStatus, Onvoldoende data , Data Deficient (DD)	), threadStatus = str_replace(threadStatus, Regionaal uitgestorven,Regionally Extinct (EX)))