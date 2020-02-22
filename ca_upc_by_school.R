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
pacman::p_load(tidyverse, tidyr, dplyr, zip, rvest, xlsx)

# Url for UPC data files
source_url <- "https://www.cde.ca.gov/ds/sd/sd/filescupc.asp"

# Load page
page <- read_html(source_url)

df_upc_links <- page %>%
  # Finde table nodes
  html_nodes('[class="table-responsive"]') %>%
  
  # Find rows of tables
  html_nodes('td') %>%
  
  # Find links
  html_nodes('a') %>%
  
  # Find urls
  html_attr('href') %>%
  
  # Convert to tibble for filtering
  enframe(name = NULL, value = "upc_link") %>%
  
  # .asp links are not data files, keep only links without .asp
  filter(!grepl(".asp", upc_link)) %>%
  
  arrange(upc_link) %>%
  
  # Append full url, create destination file name
  mutate(upc_link = paste0("https://www.cde.ca.gov/ds/sd/sd/", upc_link),
         upc_filename = substring(upc_link,
                                  # Find starting position of file name
                                  str_locate(upc_link, "documents/")[,2] + 1,
                                  # Find ending position of string
                                  str_length(upc_link)))

# Download data files
for (i in 1:length(df_upc_links$upc_link)){
  
  download.file(df_upc_links$upc_link[i],
                df_upc_links$upc_filename[i])
}
  
# Create list to store each file into a data frame
l_dataframes <- list()

# Import each file into a data frame
for (i in 1:length(df_upc_links$upc_filename)) {
  
}