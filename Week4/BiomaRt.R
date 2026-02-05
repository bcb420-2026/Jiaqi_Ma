library(biomaRt)
library(dplyr)

# List marts
listMarts()

# List datasets and select human
ensembl <- useMart("ensembl")
datasets <- listDatasets(ensembl)

# filter for human
human <- datasets[grep(datasets$dataset, pattern = "hsapiens"), ]
human
ensembl <- useDataset("hsapiens_gene_ensembl", mart = ensembl)

# Identify the correct filter
all_filters <- listFilters(ensembl)
dim(all_filters)
# search for Ensembl gene filters
all_filters[grep(all_filters$name, pattern = "ensembl_gene"), ]

# Identify the correct attributes
all_attr <- listAttributes(ensembl)
all_attr[1:10,]
# search for HGNC
searchAttributes(ensembl, "hgnc")

# Strip version suffix
strip_ensembl_version <- function(x) sub("\\..*$", "", x)
ids <- c("ENSG00000141510.17", "ENSG00000157764.2")
ids_clean <- strip_ensembl_version(ids)
ids_clean

# Run the query with getBM()
map <- getBM(
  attributes = c("ensembl_gene_id", "hgnc_symbol"),
  filters = "ensembl_gene_id",
  values = ids_clean,
  mart = ensembl
)
map

# Cache the mapping
cache_file <- "id_conversion.rds"

if (file.exists(cache_file)) {
  map <- readRDS(cache_file)
} else {
  map <- getBM(
    attributes = c("ensembl_gene_id", "hgnc_symbol"),
    filters = "ensembl_gene_id",
    values = ids_clean,
    mart = ensembl
  )
  saveRDS(map, cache_file)
}

# Merge back into your data
df <- tibble(ensembl_gene_id = ids_clean, value = c(1, 2))
df_annot <- left_join(df, map, by = "ensembl_gene_id")
df_annot
