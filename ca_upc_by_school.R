# Import California Department of Education (CDE) unduplicated pupil count (UPC) files
# 
# Date files and file specification available here: https://www.cde.ca.gov/ds/sd/sd/filescupc.asp
# 
# This script imports UPC data files from individual school years and combines them into a tidy data set

#Clear console
cat("\014") 

#Clear memory
rm(list=ls())
gc()

# Install/load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, tidyr, dplyr, zip, rvest)

# Url for UPC data files
upc_url <- "https://www.cde.ca.gov/ds/sd/sd/filescupc.asp"

# Load page
page <- read_html(upc_url)


page_data <- page %>%
  
  html_nodes('.centeredText') %>%
  
  html_text