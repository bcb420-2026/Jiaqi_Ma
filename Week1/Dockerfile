FROM risserlin/bcb420-base-image:winter2026
RUN R -e 'BiocManager::install(c("DESeq2", "enrichplot"))' 
RUN install2.r -d TRUE -r "https://cran.rstudio.com" pheatmap