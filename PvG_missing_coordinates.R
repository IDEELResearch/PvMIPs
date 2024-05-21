library(dplyr)

setwd("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/")

mip_coords <- readxl::read_xlsx("MIP_coverage_by_gene.xlsx", sheet = "MIP Coordinates")

gene_coords <- readxl::read_xlsx("MIP_coverage_by_gene.xlsx", sheet = "Gene Coordinates") |> dplyr::select(Gene, Chrom, Start, End, Length, `Non-Overlaps`, All_MIPs_Continuous)

#mips_split <- mip_coords |> split(mip_coords$Gene)

#names(mips_split) <- paste0(names(mips_split),"_mip_coords")

#list2env(mips_split,envir=.GlobalEnv)

#gene_coords <- gene_coords |> dplyr::mutate(First_MIP_Start = case_when(mip_coords$Gene == gene_coords$Gene & mip_coords$Overlaps_Previous == "NA" ~ mip_coords$MIP_Start))

first_mip_coords <- mip_coords |> subset(Overlaps_Previous == "NA")

#gene_coords <- gene_coords |> dplyr::mutate(Range_1_Start = case_when(first_mip_coords$Gene == gene_coords$Gene ~ gene_coords$Start))

all_overlapping_mips <- gene_coords |> subset(All_MIPs_Continuous == "YES")

mip_coords_all_overlapping_mips <- mip_coords |> subset(Gene %in% all_overlapping_mips$Gene)

range_1_end_overlaps <- mip_coords_all_overlapping_mips |> dplyr::group_by(Gene) |> dplyr::mutate(Range_1_End = dplyr::first(MIP_Start)) |> dplyr::select(Gene, Range_1_End) |> distinct()

last_mip_coords_all_overlapping <- mip_coords_all_overlapping_mips |> dplyr::group_by(Gene) |> dplyr::mutate(last = dplyr::last(MIP_End)) |> dplyr::select(Gene, last) |> distinct()

all_overlapping_mips <- dplyr::left_join(all_overlapping_mips, range_1_end_overlaps)

all_overlapping_mips <- dplyr::left_join(all_overlapping_mips, last_mip_coords_all_overlapping)

all_overlapping_mips <- all_overlapping_mips |> dplyr::rename(Range_2_Start = last)

all_nonoverlapping_mips <- gene_coords |> subset(All_MIPs_Continuous == "NO")

mip_coords_nonoverlapping <- mip_coords |> subset(Gene %in% all_nonoverlapping_mips$Gene)

mip_coords_nonoverlapping <- mip_coords_nonoverlapping |> dplyr::mutate(End_Range = dplyr::case_when(dplyr::lead(Overlaps_Previous) == "NO" ~ "YES",
                                                                                                     Gene != dplyr::lead(Gene) ~ "YES",
                                                                                                      .default = "NO")) |>
  dplyr::mutate(New_Range = dplyr::case_when(dplyr::lag(End_Range) == "YES" ~ "YES",
                                             .default = "NO"))

range_limits_nonoverlapping <- mip_coords_nonoverlapping |> subset(End_Range == "YES" | New_Range == "YES") #|> subset(Overlaps_Previous != "NA")

#all_nonoverlapping_mips <- all_nonoverlapping_mips |> dplyr::mutate(Total_Ranges = dplyr::case_when(all_nonoverlapping_mips$Gene == range_limits_nonoverlapping$Gene ~ sum(range_limits_nonoverlapping$End_Range == "YES")))

range_1_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_1_end = dplyr::first(MIP_Start)) |> dplyr::select(Gene, range_1_end) |> distinct()

range_2_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_2_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,2) == "NO" ~ dplyr::nth(MIP_End,1), .default = dplyr::nth(MIP_End,2))) |> dplyr::select(Gene,range_2_start) |> distinct()

range_2_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_2_end = dplyr::case_when(dplyr::nth(Overlaps_Previous,2) == "NO" ~ dplyr::nth(MIP_Start,2),
  dplyr::nth(MIP_Start,3) != "NA"  ~ dplyr::nth(MIP_Start,3))) |> dplyr::select(Gene,range_2_end) |> distinct()

range_3_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_3_start = dplyr::case_when(is.na(dplyr::nth(MIP_Start,4)) == TRUE ~ dplyr::nth(MIP_End,3), 
                                                                                                                        dplyr::nth(Overlaps_Previous,3) == "NO" ~ dplyr::nth(MIP_End,4),
                                                                                                                        .default = dplyr::nth(MIP_End,3))) |> dplyr::select(Gene,range_3_start) |> distinct()

range_3_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_3_end = dplyr::case_when(is.na(dplyr::nth(MIP_Start,4)) == TRUE ~ 0,
                                                                                                                    dplyr::nth(Overlaps_Previous,5) == "NO" ~ dplyr::nth(MIP_Start,5),
                                                                                                                    dplyr::nth(Overlaps_Previous,4) == "YES" ~ 0,
                                                                                                                    dplyr::nth(Overlaps_Previous,3) == "NO" ~ dplyr::nth(MIP_Start,3),
                                                                                                                    dplyr::nth(MIP_Start,4) != "NA"  ~ dplyr::nth(MIP_Start,4))) |> dplyr::select(Gene,range_3_end) |> distinct()

range_4_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_4_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,4) == "NO" ~ dplyr::nth(MIP_End,5),
                                                                                                                        dplyr::nth(Overlaps_Previous,6) == "YES" ~ dplyr::nth(MIP_End,6),
                                                                                                                        dplyr::nth(Overlaps_Previous,6) == "NO" ~ dplyr::nth(MIP_End,5))) |> dplyr::select(Gene,range_4_start) |> distinct()


range_4_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_4_end = dplyr::case_when(is.na(dplyr::nth(MIP_Start,5)) == TRUE ~ 0,
                                                                                                                    dplyr::nth(Overlaps_Previous,5) == "YES" &
                                                                                                                      is.na(dplyr::nth(MIP_Start,6)) == TRUE ~ dplyr::nth(MIP_Start,6),
                                                                                                                    #dplyr::nth(Overlaps_Previous,6) == "NO" ~ dplyr::nth(MIP_End,5),
                                                                                                                    dplyr::nth(Overlaps_Previous,6) == "YES" & dplyr::nth(Overlaps_Previous,7) == "NO" ~ dplyr::nth(MIP_Start,7),
                                                                                                                    dplyr::nth(Overlaps_Previous,6) == "NO" ~ dplyr::nth(MIP_Start,6))) |> dplyr::select(Gene,range_4_end) |> distinct()

range_5_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_5_start = dplyr::case_when(#dplyr::nth(Overlaps_Previous,7) == "NO" & dplyr::nth(Overlaps_Previous,6) == "NO" ~ dplyr::nth(MIP_End,6),
                                                                                                                        dplyr::nth(Overlaps_Previous,7) == "YES" &
                                                                                                                          dplyr::nth(Overlaps_Previous,6) == "NO" ~ dplyr::nth(MIP_End,7),
                                                                                                                        dplyr::nth(Overlaps_Previous,7) == "NO" & 
                                                                                                                          dplyr::nth(Overlaps_Previous,8) == "YES" ~ dplyr::nth(MIP_End,8),
                                                                                                                        dplyr::nth(Overlaps_Previous,7) == "NO" &
                                                                                                                          dplyr::nth(Overlaps_Previous,8) == "NO" ~ dplyr::nth(MIP_End,7))) |> 
  dplyr::select(Gene,range_5_start) |> distinct()

range_5_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_5_end = dplyr::case_when(dplyr::nth(Overlaps_Previous,10) == "YES" &
                                                                                                                      dplyr::nth(Overlaps_Previous,8) == "YES" ~ dplyr::nth(MIP_Start,9),
                                                                                                                    dplyr::nth(Overlaps_Previous,10) == "YES" &
                                                                                                                      dplyr::nth(Overlaps_Previous,8) == "NO" ~ dplyr::nth(MIP_Start,8),
                                                                                                                    dplyr::nth(Overlaps_Previous,10) == "NO" ~ dplyr::nth(MIP_Start,8),
                                                                                                                    dplyr::nth(Overlaps_Previous,9) == "YES" ~ dplyr::nth(MIP_Start,8))) |> dplyr::select(Gene,range_5_end) |> distinct()

range_6_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_6_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,9) == "NO" &
                                                                                                                          dplyr::nth(Overlaps_Previous,10) == "YES" &
                                                                                                                          dplyr::nth(Overlaps_Previous,7) == "NO" ~ dplyr::nth(MIP_End,10),
                                                                                                                        dplyr::nth(Overlaps_Previous,10) == "NO" &dplyr::nth(Overlaps_Previous,9) == "YES" ~ dplyr::nth(MIP_End,9),
                                                                                                                        dplyr::nth(Overlaps_Previous,10) == "YES" &
                                                                                                                          dplyr::nth(Overlaps_Previous,7) == "YES" ~ dplyr::nth(MIP_End,8),
                                                                                                                        .default = dplyr::nth(MIP_End,9))) |>  dplyr::select(Gene,range_6_start) |> distinct()

range_6_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_6_end = dplyr::case_when(dplyr::nth(Overlaps_Previous,11) == "YES" ~ dplyr::nth(MIP_Start,10),
                                                                                                                    dplyr::nth(Overlaps_Previous,10) == "YES" &
                                                                                                                      dplyr::nth(Overlaps_Previous,12) == "YES" ~ dplyr::nth(MIP_Start,9),
                                                                                                                    dplyr::nth(Overlaps_Previous,12) == "YES" ~ dplyr::nth(MIP_Start,10),
                                                                                                                    .default = dplyr::nth(MIP_Start,11))) |> dplyr::select(Gene,range_6_end) |> distinct()

range_7_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_7_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,12) == "YES" ~ dplyr::nth(MIP_End,10),
                                                                                                                        .default = dplyr::nth(MIP_End,11))) |>  dplyr::select(Gene,range_7_start) |> distinct()

range_7_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_7_end = dplyr::case_when(dplyr::nth(Overlaps_Previous,12) == "YES" ~ dplyr::nth(MIP_Start,11),
                                                                                                                    .default = dplyr::nth(MIP_Start,12))) |> dplyr::select(Gene,range_7_end) |> distinct()

range_8_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_8_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,13) == "YES" ~ dplyr::nth(MIP_End,13),
                                                                                                                        .default = dplyr::nth(MIP_End,12))) |>  dplyr::select(Gene,range_8_start) |> distinct()

range_8_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_8_end = dplyr::case_when(dplyr::nth(Overlaps_Previous,14) == "YES" ~ dplyr::nth(MIP_Start,13),
                                                                                                                    .default = dplyr::nth(MIP_Start,14))) |> dplyr::select(Gene,range_8_end) |> distinct()

range_9_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_9_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,13) == "YES" ~ dplyr::nth(MIP_End,15),
                                                                                                                        .default = dplyr::nth(MIP_End,14))) |>  dplyr::select(Gene,range_9_start) |> distinct()

range_9_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_9_end = dplyr::case_when(dplyr::nth(Overlaps_Previous,16) == "YES" ~ dplyr::nth(MIP_Start,15),
                                                                                                                    .default = dplyr::nth(MIP_Start,16))) |> dplyr::select(Gene,range_9_end) |> distinct()

range_10_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_10_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,13) == "YES" ~ dplyr::nth(MIP_End,17),
                                                                                                                        .default = dplyr::nth(MIP_End,16))) |>  dplyr::select(Gene,range_10_start) |> distinct()

range_10_end <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_10_end = dplyr::case_when(dplyr::nth(Overlaps_Previous,16) == "YES" ~ dplyr::nth(MIP_Start,17))) |> dplyr::select(Gene,range_10_end) |> distinct()

range_11_start <- range_limits_nonoverlapping |> dplyr::group_by(Gene) |> dplyr::mutate(range_11_start = dplyr::case_when(dplyr::nth(Overlaps_Previous,16) == "YES" ~ dplyr::nth(MIP_End,17))) |> dplyr::select(Gene,range_11_start) |> distinct()


all_nonoverlapping_mips <- all_nonoverlapping_mips |> dplyr::mutate(Range_1_End = case_when(range_1_end$Gene == all_nonoverlapping_mips$Gene ~ range_1_end$range_1_end),
                                                                    Range_2_Start = case_when(range_2_start$Gene == all_nonoverlapping_mips$Gene ~ range_2_start$range_2_start),
                                                                    Range_2_End = case_when(range_2_start$Gene == all_nonoverlapping_mips$Gene ~ range_2_end$range_2_end),
                                                                    Range_3_Start = case_when(range_3_start$Gene == all_nonoverlapping_mips$Gene ~ range_3_start$range_3_start),
                                                                    Range_3_End = case_when(range_3_start$Gene == all_nonoverlapping_mips$Gene ~ range_3_end$range_3_end),
                                                                    Range_4_Start = case_when(range_4_start$Gene == all_nonoverlapping_mips$Gene ~ range_4_start$range_4_start),
                                                                    Range_4_End = case_when(range_4_start$Gene == all_nonoverlapping_mips$Gene ~ range_4_end$range_4_end),
                                                                    Range_5_Start = case_when(range_5_start$Gene == all_nonoverlapping_mips$Gene ~ range_5_start$range_5_start),
                                                                    Range_5_End = case_when(range_5_start$Gene == all_nonoverlapping_mips$Gene ~ range_5_end$range_5_end),
                                                                    Range_6_Start = case_when(range_6_start$Gene == all_nonoverlapping_mips$Gene ~ range_6_start$range_6_start),
                                                                    Range_6_End = case_when(range_6_start$Gene == all_nonoverlapping_mips$Gene ~ range_6_end$range_6_end),
                                                                    Range_7_Start = case_when(range_7_start$Gene == all_nonoverlapping_mips$Gene ~ range_7_start$range_7_start),
                                                                    Range_7_End = case_when(range_7_start$Gene == all_nonoverlapping_mips$Gene ~ range_7_end$range_7_end),
                                                                    Range_8_Start = case_when(range_8_start$Gene == all_nonoverlapping_mips$Gene ~ range_8_start$range_8_start),
                                                                    Range_8_End = case_when(range_8_start$Gene == all_nonoverlapping_mips$Gene ~ range_8_end$range_8_end),
                                                                    Range_9_Start = case_when(range_9_start$Gene == all_nonoverlapping_mips$Gene ~ range_9_start$range_9_start),
                                                                    Range_9_End = case_when(range_9_start$Gene == all_nonoverlapping_mips$Gene ~ range_9_end$range_9_end),
                                                                    Range_10_Start = case_when(range_10_start$Gene == all_nonoverlapping_mips$Gene ~ range_10_start$range_10_start),
                                                                    Range_10_End = case_when(range_10_end$Gene == all_nonoverlapping_mips$Gene ~ range_10_end$range_10_end),
                                                                    Range_11_Start = case_when(range_11_start$Gene == all_nonoverlapping_mips$Gene ~ range_11_start$range_11_start))
                                                                                                                                                
join1 <- semi_join(all_overlapping_mips, gene_coords)                                                        

join2 <- semi_join(all_nonoverlapping_mips, gene_coords)

all_ranges <- plyr::rbind.fill(join1, join2)

all_ranges[all_ranges == 0] <- NA

all_ranges |> data.table::fwrite("PvG_missing_ranges.csv")

#SOMETHING IS WRONG WITH TRAG32 - MANUALLY CORRECTED BECAUSE IT WAS EASIEST

#test <- all_ranges |> dplyr::mutate(Missing_Range)
