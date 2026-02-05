library(GEOmetadb)
library(DBI)
library(RSQLite)
library(ggplot2)
library(dplyr)

con <- dbConnect(SQLite(), 'GEOmetadb.sqlite')
# RNA-seq series by platform technology
sql <- paste(
  "SELECT DISTINCT gse.title, gse.gse, gpl.title",
  "FROM gse JOIN gse_gpl ON gse_gpl.gse = gse.gse",
  "JOIN gpl ON gse_gpl.gpl = gpl.gpl",
  "WHERE gpl.technology = 'high-throughput sequencing'"
)
rs <- dbGetQuery(con, sql)
dim(rs)

# Add organism and recency filters
sql <- paste(
  "SELECT DISTINCT gse.title, gse.gse, gpl.title, gse.submission_date",
  "FROM gse JOIN gse_gpl ON gse_gpl.gse = gse.gse",
  "JOIN gpl ON gse_gpl.gpl = gpl.gpl",
  "WHERE gse.submission_date > '2022-01-01' AND",
  "gpl.organism LIKE '%Homo sapiens%' AND",
  "gpl.technology LIKE '%high-throughput seq%'"
)
rs <- dbGetQuery(con, sql)
dim(rs)

# Add a topic keyword (e.g., ovarian)
sql <- paste(
  "SELECT DISTINCT gse.title, gse.gse, gpl.title, gse.submission_date",
  "FROM gse JOIN gse_gpl ON gse_gpl.gse = gse.gse",
  "JOIN gpl ON gse_gpl.gpl = gpl.gpl",
  "WHERE gse.submission_date > '2022-01-01' AND",
  "gse.title LIKE '%ovarian%' AND",
  "gpl.organism LIKE '%Homo sapiens%' AND",
  "gpl.technology LIKE '%high-throughput seq%'"
)
rs <- dbGetQuery(con, sql)
dim(rs)
head(rs[, c('gse','title')])

# Heuristic: require a counts-like supplementary file
sql <- paste(
  "SELECT DISTINCT gse.title, gse.gse, gpl.title, gse.submission_date, gse.supplementary_file",
  "FROM gse JOIN gse_gpl ON gse_gpl.gse = gse.gse",
  "JOIN gpl ON gse_gpl.gpl = gpl.gpl",
  "WHERE gse.submission_date > '2022-01-01' AND",
  "gse.title LIKE '%ovarian%' AND",
  "gpl.organism LIKE '%Homo sapiens%' AND",
  "gpl.technology LIKE '%high-throughput sequencing%'",
  "ORDER BY gse.submission_date DESC"
)
rs <- dbGetQuery(con, sql)
counts_files <- rs$supplementary_file[grep("count|cnt", rs$supplementary_file, ignore.case = TRUE)]
series_of_interest <- rs$gse[grep("count|cnt", rs$supplementary_file, ignore.case = TRUE)]
# Preview filenames
shortened <- unlist(lapply(counts_files, function(x){
  x <- unlist(strsplit(x, ";"))
  x <- x[grep("count|cnt|txt|csv|xlsx", x, ignore.case = TRUE)]
  tail(unlist(strsplit(x, "/")), n = 1)
}))
head(shortened, 10)

# Require a minimum number of samples per series
# 1. Construct the query using the lightweight 'gse_gsm' table
sql_fast <- paste0(
  "SELECT gse, count(*) as sample_count ", 
  "FROM gse_gsm ", 
  "WHERE gse IN ('", paste(series_of_interest, collapse = "','"), "') ", 
  "GROUP BY gse"
)

# 2. Run query
series_counts <- dbGetQuery(con, sql_fast)

# 3. Filter for > 6 samples
subset(series_counts, sample_count > 6)

##############
num_series <- dbGetQuery(con, paste(
  "select * from gsm where series_id in ('",
  paste(series_of_interest, collapse = "','"), "')", sep = ""))

gse.count <- as.data.frame(table(num_series$series_id))
subset(gse.count, Freq > 6)