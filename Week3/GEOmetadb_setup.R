# Install packages
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!requireNamespace("GEOmetadb", quietly = TRUE))
  BiocManager::install("GEOmetadb")
if (!requireNamespace("DBI", quietly = TRUE))
  install.packages("DBI")
if (!requireNamespace("RSQLite", quietly = TRUE))
  install.packages("RSQLite")
if (!requireNamespace("dplyr", quietly = TRUE))
  install.packages("dplyr")
if (!requireNamespace("ggplot2", quietly = TRUE))
  install.packages("ggplot2")

# Get the SQLite database
library(GEOmetadb)
if (!file.exists('GEOmetadb.sqlite')) getSQLiteFile()
file.info('GEOmetadb.sqlite')

# Connect to the database
library(DBI)
library(RSQLite)
con <- dbConnect(SQLite(), 'GEOmetadb.sqlite')

# Explore tables and fields
# dbListTables(con)
# dbListFields(con, 'gse')
