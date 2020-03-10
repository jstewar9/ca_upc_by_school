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
  
  # Find table nodes
  html_nodes('[class="table-responsive"]') %>%
  
  # Find rows of tables
  html_nodes('td') %>%
  
  # Find links
  html_nodes('a') %>%
  
  # Find urls
  html_attr('href') %>%
  
  # Convert to data frame for filtering
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
  
  download.file(url = df_upc_links$upc_link[i],
                destfile = df_upc_links$upc_filename[i],
                quiet = TRUE,
                mode = "wb",
                cacheOK = FALSE)
}
  
# Create list to store each file into a data frame
l_dataframes <- list()

# Import files into data frames within a list
# Exclude 13-14 and 14-15 data as its in a different format
for (i in 3:length(df_upc_links$upc_filename)) {
  
  # 13-14 data starts on row 1, other files start on row 3
  #starting_row <- ifelse(grepl("1314", df_upc_links$upc_filename[i]), 1, 3)
  
  l_dataframes[[i - 2]] <- read.xlsx2(file = df_upc_links$upc_filename[i],
                                  sheetIndex = 3,
                                  startRow = 3,
                                  as.data.frame = TRUE,
                                  header = TRUE,
                                  colClasses = c(rep("character", 14),
                                                 rep("numeric", 10),
                                                 "character"),
                                  stringsAsFactors = FALSE)
  
  gc()
  
}

# Combine data into one data frame
df_upc_data <- bind_rows(l_dataframes) 

v_headers <- names(df_upc_data) %>%
  
  str_replace_all(fixed(".."), "") %>%
  
  str_replace_all(fixed("."), "_")
  
  



