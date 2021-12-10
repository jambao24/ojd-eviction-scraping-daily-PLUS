library(DBI)
library(stringr)
library(dplyr)
library(anytime)

today <- format(Sys.Date(), "%m_%d_%Y")
#today <- "10_25_2021"

getCaseOverviesFlat <- function() {
  db_name <- paste("daily", today, sep = "_")
  #db_name <- "daily_10_24_2021"
    
  con <- dbConnect(RPostgres::Postgres(),dbname = db_name,
                   host = 'localhost',
                   port = '5432',
                   user = 'postgres',
                   password = 'admin')
  
  dbListTables(con)
  
  # case-overviews
  query <- dbSendQuery(con, 'SELECT * FROM "case-overviews"')
  case_overviews <- dbFetch(query)
  dbClearResult(query)
  
  
  # case-parties
  query <- dbSendQuery(con, 'SELECT * FROM "case-parties"')
  case_parties <- dbFetch(query)
  dbClearResult(query)
  
  
  # events
  query <- dbSendQuery(con, 'SELECT * FROM "events"')
  events <- dbFetch(query)
  dbClearResult(query)
  
  
  # files
  query <- dbSendQuery(con, 'SELECT * FROM "files"')
  files <- dbFetch(query)
  dbClearResult(query)
  
  
  # judgments
  query <- dbSendQuery(con, 'SELECT * FROM "judgments"')
  judgments <- dbFetch(query)
  dbClearResult(query)
  
  
  # lawyers
  query <- dbSendQuery(con, 'SELECT * FROM "lawyers"')
  lawyers <- dbFetch(query)
  dbClearResult(query)
  
  case_overviews$style <- str_replace_all(case_overviews$style, "\n", " ")
  
  defendant <- case_parties %>% 
    filter(party_side == "Defendant") %>% 
    group_by(case_code) %>% 
    summarize(defendant_names = paste(name, collapse = "; "), 
              defendant_addr = paste(unique(addr), collapse = "; "))
  
  case_overviews_flat <- case_overviews %>% 
    full_join(defendant, by = 'case_code')
  
  case_overviews_flat$date <- as.Date(case_overviews_flat$date, "%m/%d/%Y")
  
  return(case_overviews_flat)
}

case_overviews_flat <- getCaseOverviesFlat()

# getDates <- format(seq(as.Date("2021-09-10"), as.Date("2021-09-13"), by="days"), "%m_%d_%Y")
# getDates <- format(seq(as.Date("09/20/2021", "%m/%d/%Y")-29, length.out = 30, by="days"), "%m_%d_%Y")


getDates <- format(seq(Sys.Date()-10, length.out = 10, by="days"), "%m_%d_%Y")

getDates <- paste("Daily_Cases", getDates, sep = "_")

# getDates <- c(getDates, dir("G:/Shared drives/DAILY_SCRAPE_OJD", recursive = FALSE, pattern = "PLUS"))

#getDates <- getDates[-length(getDates)]



getOLCData <- function(i) {
  setwd(paste("G:/Shared drives/DAILY_SCRAPE_OJD/", i, sep = ""))
  cases <- read.csv("case_overviews_flat.csv")
  return(cases)
}

OLCData <- Reduce("rbind", lapply(getDates, getOLCData))

# getDates

OLCData$date <- anydate(OLCData$date)

OLCData <- OLCData %>% 
  filter(date >= Sys.Date()-10)

missingCases <- case_overviews_flat %>%
  anti_join(OLCData, by = "case_code")


setwd(paste("G:/Shared drives/DAILY_SCRAPE_OJD/Daily_Cases_", today, sep = ""))
write.csv(missingCases, "case_overviews_flat.csv")

# write.csv(case_overviews, "case_overviews.csv")
# write.csv(case_parties, "case_parties.csv")
# write.csv(events, "events.csv")
# write.csv(files, "files.csv")
# write.csv(judgments, "judgments.csv")
# write.csv(lawyers, "lawyers.csv")

getFiles <- function() {
  db_name <- paste("daily", today, sep = "_")
  #db_name <- "daily_09_21_2021"
  
  con <- dbConnect(RPostgres::Postgres(),dbname = db_name,
                   host = 'localhost',
                   port = '5432',
                   user = 'postgres',
                   password = 'admin')
  
  dbListTables(con)
  
  # files
  query <- dbSendQuery(con, 'SELECT * FROM "files"')
  files <- dbFetch(query)
  dbClearResult(query)
  return(files)
}


files <- getFiles()

setwd(paste("G:/Shared drives/DAILY_SCRAPE_OJD/Daily_Cases_", today, "/Court_Documents_", today, sep = ""))

filteredFiles <- files %>%
  filter(case_code %in% missingCases$case_code)

file.exists(filteredFiles$path)

file.rename(files$path, paste("full/", files$case_code, "_", files$id, sep = ""))

file.copy(paste("full/", filteredFiles$case_code, "_", filteredFiles$id, sep = ""), getwd())

# unlink(list.files("full"), recursive = TRUE)
# 
# unlink("full", recursive = TRUE)


