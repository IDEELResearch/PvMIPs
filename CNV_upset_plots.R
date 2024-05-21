library(ggplot2)

library(ComplexUpset)

setwd("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/NAMRU_repool/Combined_Analysis")

CNV <- data.table::fread("CNV_upset.csv")

#CNV <- CNV |> replace(CNV == 0, 1)

CNV <- CNV |> tibble::column_to_rownames(var = "Sample")

colnames(CNV) <- colnames(CNV) |> stringr::str_remove_all("_CNV")

genes <- colnames(CNV)

CNV[genes] = CNV[genes] > 1

pca_metadata_filtered <- readRDS("filtered_metadata.rds")

CNV_metadata <- CNV |> tibble::rownames_to_column(var = "Sample")

CNV_metadata <- dplyr::left_join(CNV_metadata, pca_metadata_filtered) |> subset(RBP2b == TRUE)

COI <-  data.table::fread("COI.txt_summary.txt", sep="\t", header=TRUE, data.table = FALSE) %>% 
  # Subset to COI results
  dplyr::filter(CorP == "C") %>%  # subset to COI information
  # select to rows we care about
  dplyr::select(-c("file", "CorP")) %>% 
  dplyr::rename(Sample = name)

CNV_metadata <- dplyr::left_join(CNV_metadata, COI)

#CNV <- t(CNV)

upset(CNV, genes, set_sizes = FALSE, name = "Gene",
      base_annotations=list(
        'Intersection size'=intersection_size()
        + ylab('Samples')))

ggsave("CNV_upset.png", width = 5, height = 6, units = "in", dpi = 600)
