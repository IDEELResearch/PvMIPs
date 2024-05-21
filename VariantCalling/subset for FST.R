setwd("/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/vcfstats/")

public_samples <- readxl::read_xlsx(path = "/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/VivID_Seq/scrape_pubseqs/vivid_seq_public_NGS.xlsx", sheet = "ALL samples", col_names = TRUE)

sample_regions <- as.data.frame(public_samples[c("acc", "country", "vividregion")])

new_2021_samples <- read.csv("/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/new_regions.csv", fileEncoding = "UTF-8-BOM")

Nick_acc <- c("D9U3K", "O6Y4K", "Q8J6O")

Nick_country <- c("DRC", "DRC", "DRC")

Nick_vividregion <- c("AF", "AF", "AF")

Nick_samples <- data.frame(Nick_acc, Nick_country, Nick_vividregion)

colnames(Nick_samples) <- c("acc", "country", "vividregion")

all_samples <- rbind(sample_regions, new_2021_samples, Nick_samples)

colnames(all_samples) <- c("acc", "country", "region")

all_samples[all_samples == "Gu"] <- "GU"

all_samples[all_samples == "Sas"] <- "SAs"

unique(all_samples$region)

unique(all_samples$country)

AF <- subset(all_samples, subset = region == "AF")

CAm <- subset(all_samples, subset = region == "CAm")

EAs <- subset(all_samples, subset = region == "EAs")

ME <- subset(all_samples, subset = region == "ME")

SAm <- subset(all_samples, subset = region == "SAm") h

SAs <- subset(all_samples, subset = region == "SAs")

SEA <- subset(all_samples, subset = region == "SEA")

AS <- rbind(EAs, SEA, ME)

write.table(AF$acc, file = "AFr.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)

write.table(CAm$acc, file = "CAm.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)

write.table(SAm$acc, file = "SAm.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)

write.table(SAs$acc, file = "SAs.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)

write.table(AS$acc, file = "AS.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)

for(country in unique(all_samples$country)){
  x <- subset(all_samples, country == country)
  x <- x[,1] 
  #print(country)
  write.table(x, file = paste0(country, ".txt", sep = ""), quote = FALSE, row.names = FALSE, col.names = FALSE)
}

library(tidyverse)

split_countries <- split(all_samples, all_samples$country)
split2 <- lapply(seq_along(split_countries), function(x) as.data.frame(split_countries[[x]])[,1])
names(split2) <- names(split_countries)
sapply(names(split2), function(x){
  write.table(split2[[x]], file = paste0(x, ".txt", sep = ""), quote = FALSE, row.names = FALSE, col.names = FALSE)
  })

#RUN THIS PART ON LONGLEAF:

#vcftools --gzvcf Pvivax_hard_filtered_biallelic_snps_only.vcf.gz --weir-fst-pop AS.txt --weir-fst-pop SAs.txt --weir-fst-pop AF.txt --weir-fst-pop SAm.txt --weir-fst-pop CAm.txt --out all_regions

library(tidyverse)
library(fuzzyjoin)

all_fst <- read_tsv("all_regions.weir.fst")
colnames(all_fst) <- c("CHROM", "POS", "FST")
all_fst$FST <- as.numeric(all_fst$FST)
all_fst <- all_fst[order(all_fst$FST, decreasing = TRUE),]
top400 <- subset(all_fst[1:400,])

gtf <- read_tsv("PvP01_bcftools.gtf")
bare_gtf <- subset(gtf, select = c("CHROM", "feature", "FROM", "TO", "gene_id", "gene_name"))

annotated_fst <- fuzzy_left_join(top400, bare_gtf, by = c("CHROM" = "CHROM", "POS" = "FROM", "POS" = "TO"), match_fun = list(`==`,`>`, `<`))
annotated_fst <- subset(annotated_fst[-4])
#annotated_fst <- annotated_fst %>% rename(CHROM = CHROM.x)

allele_freq <- read_tsv("all_samples_freq.frq")
annotated_fst2 <- list(annotated_fst, allele_freq) %>% reduce(left_join, by = c("CHROM", "POS"))
write.csv(annotated_fst2, file = "annotated_FST.csv", quote = FALSE, row.names = FALSE)

#annotated_fst <- list(all_fst, bare_gtf) %>% reduce(left_join, by = c("CHROM", "POS"))
#annotated_fst <- annotated_fst[order(annotated_fst$FST, decreasing = TRUE),]

setwd("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/vcfstats/")

library(tidyverse)

annotated_fst2 <- read.csv("annotated_FST.csv", header = TRUE)

fst_files <- lapply(list.files(path = "C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/vcfstats/pairwise_fst/", pattern = "*.weir.fst", full.names = TRUE, recursive = FALSE), read_tsv)
filenames <- gsub(".weir.fst", "", x = list.files(path = "C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/vcfstats/pairwise_fst/", pattern = "*.weir.fst", full.names = FALSE, recursive = FALSE))
#names(fst_files) <- filenames

library(magrittr)

for(i in 2:length(fst_files)) { #because there is a different number of rows and most other methods will use up all of the memory, we will go in an iterative process and slowly bind the files together two at a time and choose the distinct rows (by CHROM and POS) to keep only
  if(i == 2) {
    pairwise_fst <- rbind(fst_files[[1]], fst_files[[i]]) %>%
      distinct(CHROM, POS)
  } else {
    pairwise_fst <- rbind(pairwise_fst, fst_files[[i]][, 1:2]) %>%
      distinct(CHROM, POS)
  }
}

fst_join <- pairwise_fst

for(i in 1:length(fst_files)) { #use left join by our unique CHROM and POS to add all file results together
  fst_join %<>% 
    left_join(fst_files[[i]], by = c("CHROM", "POS"))
}

colnames(fst_join) <- c("CHROM", "POS", filenames)

annotated_fst3 <- list(annotated_fst2, fst_join) %>% reduce(left_join, by = c("CHROM", "POS"))
annotated_fst3 <- annotated_fst3 %>% rename(ALLELE_FREQ = X.ALLELE.FREQ.)
write.csv(annotated_fst3, file = "full_annotated_FST.csv", quote = FALSE, row.names = FALSE)
