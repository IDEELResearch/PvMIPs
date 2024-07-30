This repository contains three kinds of scripts:

1. Code used to download, align, and detect variants in publicly available Plasmodium vivax sequences, then to identify both geographically discriminating and neutral SNPs (as described in the methods of the paper).

2. Code used to design Plasmodium vivax molecular inversion probes as well as the resulting project resources needed to use MIPTools.

3. Code used to analyze the resulting sequences and generate figures for publication.

In addition to these three categories, the scripts go back and forth between Bash, R, and Python/Snakemake. I have tried to make this explicit as much as possible, but please reach out if anything is unclear.

In order to run this analysis, you will need a working installation of R and RStudio. Code was optimized to run in R 4.2.2 and RStudio 2022.07.2. Individual R packages are detailed within each respective script.

Shell scripts rely on functioning installations of bcftools, vcftools, and vcf-kit. Code was optimized using bcftools 1.16, vcftools 0.1.16, and vcf-kit 0.2.9.

To design MIPs and analyze MIP sequencing data, you will need a working installation of MIPTools (v0.4.0), which can be installed from https://github.com/bailey-lab/MIPTools.

Fastq files used in this study are available through SRA (BioProject ID PRJNA1117913), while a list of publicly available genomes used to design the MIP panels is available in the VariantCalling directory. Downloading these files may take a long time and is only recommended on a high-performance cluster. All scripts necessary for analysis download quickly and run relatively quickly, with the notable exception of the initial parts of the main R analysis script, which reads and analyzes large VCF files.

This repository also contains sequences for the MIPs, which can be found within the vivax_project_resources directory and the respective "mip_ids" subdirectory for each probe set. The easiest way to find them without cloning the entire repository is to navigate to "probe_info.csv" in the "Go to file" box. However, if you are interested in actually using the MIPs, the more useful files can be found by searching for "probe_order.xlsx" within vivax_project_resources and the associated probe set subdirectory. Should you intend to use MIPTools with these panels, you will need to clone the full repository, as the project resources are necessary for MIPTools to run effectively.
