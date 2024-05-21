#devtools::install_github("OJWatson/McCOILR")

setwd("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/NAMRU_repool/Combined_Analysis")

library(tidyverse)
library("McCOILR")
library(ggplot2)

NAMRU <- vcfR::read.vcfR("biallelics_no_gaps.vcf.gz")

loci <- NAMRU@fix[,1:2] %>% 
  tibble::as_tibble() %>% 
  dplyr::mutate(POS = as.numeric(POS),
                Key = 1:dplyr::n()) %>% 
  dplyr::select(c("CHROM", "POS", "Key"))

NAMRU_long <- vcfR::extract_gt_tidy(NAMRU, format_fields = "GT") %>%
  dplyr::full_join(x = loci, y = ., by  = "Key") %>% 
  dplyr::select(-c("Key"))

NAMRU_long <- NAMRU_long %>% 
  # use `mutate()` to add a new column
  dplyr::mutate(
    gt = dplyr::case_when(gt_GT == "0/0" ~ 0,
                          gt_GT == "0/1" ~ 0.5,
                          gt_GT == "1/1" ~ 1)  # change `gt_GT` column to `gt`
  )

# wide format 
NAMRU_RMCL <- NAMRU_long %>% 
  dplyr::mutate(loci = paste(CHROM, POS, sep = "|")) %>% 
  dplyr::select(c("loci", "Indiv", "gt")) %>% 
  # liftover missing for RMCL 
  dplyr::mutate(gt = ifelse(is.na(gt), -1, gt)) %>% 
  tidyr::pivot_wider(names_from = "Indiv",
                     values_from = "gt")
					 
# make matrix and format for RMCL
NAMRU_RMCLmat <- as.matrix(NAMRU_RMCL[2:ncol(as.matrix(NAMRU_RMCL))])
rownames(NAMRU_RMCLmat) <- NAMRU_RMCL[["loci"]]
NAMRU_RMCLmat <- t(NAMRU_RMCLmat)
save(NAMRU_RMCLmat, file = "NAMRU_RMCLmat")
#load("NAMRU_RMCLmat")

# Prepare output directory
output_dir <- "COI_results"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

#Install THEREALMcCOIL

#git clone https://github.com/EPPIcenter/THEREALMcCOIL.git

# Source code, move into correct working direcory
#remove any .o or .so files in the /categorical_method/ directory then run:
#R CMD SHLIB McCOIL_categorical_code.c llfunction_het.c

orig_wd <- getwd()
setwd(output_dir)
#source("McCOIL_categorical.R")

#output_path <- file.path(output_dir)
invisible(McCOIL_categorical(NAMRU_RMCLmat,
                   maxCOI=25, threshold_ind=10,
                   threshold_site=10,
                   totalrun=1000, burnin=100, M0=15,
                   e1=0.05, e2=0.05,
                   err_method=3, 
                   path=getwd(),
                   output="COI.txt" # Up from THEREALMcCOIL/categorical/
))

# Return to our original working directory
setwd(orig_wd)

#Read in summary data
COI <- data.table::fread("COI_results/COI.txt_summary.txt", sep="\t", header=TRUE, data.table = FALSE) |> 
  # Subset to COI results
  dplyr::filter(CorP == "C") |>  # subset to COI information
  # select to rows we care about
  dplyr::select(-c("file", "CorP")) |> 
  dplyr::rename(Indiv = name)
COI$type <- "NAMRU"

all_plot <- COI |> 
  ggplot() +
  geom_violin(aes(x = type, y = mean, color = type)) +
  geom_jitter(aes(x = type, y = mean, color = type), 
              alpha = 0.3, size = 0.5, height=0.1) +
  theme_linedraw() +
  theme(legend.position = "none") + 
  ylim(0,5) +
  labs(y = "COI", x = "Sample Set") +
  theme(axis.title.x = element_blank(), axis.text.x = element_blank())

ggsave("COI_violin.png", all_plot, device = "png", dpi = 600, width = 5, height = 5, units = "in")

filtered_metadata <- readRDS("filtered_metadata.rds")

communities <- c("Belén", "Indiana", "Iquitos", "Punchana", "San Juan Bautista")

COI <- COI |> dplyr::rename("Sample" = "Indiv") |> dplyr::left_join(filtered_metadata) |> dplyr::filter(City %in% communities)

community_plot <- COI |>
  ggplot() +
  geom_violin(aes(x = City, y = mean, color = City)) +
  geom_jitter(aes(x = City, y = mean, color = City), alpha = 0.3, size = 0.5, height = 0.1) +
  theme_linedraw() +
  theme(legend.position = "none") +
  ylim(0,5) +
  scale_color_brewer(palette = "Set2") +
  labs(y = "COI", x = "Community")

ggsave("community_COI.png", community_plot, dpi = 600, width = 5, height = 5, units = "in")

COI <- COI |> dplyr::mutate(Year = as.factor(Collection_Year)) |> subset(Year != 2018)

year_plot <- COI |>
  ggplot() +
  geom_violin(aes(x = Year, y = mean, color = Year)) +
  geom_jitter(aes(x = Year, y = mean, color = Year), alpha = 0.3, size = 0.5, height = 0.1) +
  theme_linedraw() +
  theme(legend.position = "none") +
  ylim(0,5) +
  scale_color_brewer(palette = "Set2") +
  labs(y = "COI", x = "Year")

ggsave("year_COI.png", year_plot, dpi = 600, width = 5, height = 5, units = "in")

library(patchwork)

design <- "
AABBBB
AACCCC"

COI_fig <- all_plot + community_plot + year_plot + plot_layout(design = design) + plot_annotation(tag_levels = "A") & theme(axis.title = element_text(size = 20), axis.text = element_text(size = 14))

ggsave("COI_fig.png", COI_fig, dpi = 600, width = 12, height = 10, units = "in")

COI_aov <- aov(COI$mean ~ COI$City * COI$Year)

summary(COI_aov)
