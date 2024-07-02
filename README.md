This repository contains three kinds of scripts:

1. Code used to download, align, and detect variants in publicly available Plasmodium vivax sequences, then to identify both geographically discriminating and neutral SNPs (as described in the methods of the paper).

2. Code used to design Plasmodium vivax molecular inversion probes as well as the resulting project resources needed to use MIPTools.

3. Code used to analyze the resulting sequences and generate figures for publication.

In addition to these three categories, the scripts go back and forth between Bash, R, and Python/Snakemake. I have tried to make this explicit as much as possible, but please reach out if anything is unclear.

In order to run this analysis, you will need a working installation of R and RStudio. Code was optimized to run in R 4.2.2 and RStudio 2022.07.2.

Shell scripts rely on functioning installations of bcftools, vcftools, and vcf-kit. Code was optimized using bcftools 1.16, vcftools 0.1.16, and vcf-kit 0.2.9.

To design MIPs and analyze MIP sequencing data, you will need a working installation of MIPTools (v0.4.0), which can be installed from https://github.com/bailey-lab/MIPTools.
