#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=10g
#SBATCH -t 02-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

module add sratoolkit

prefetch --option-file /nas/longleaf/home/zpopkinh/Pvivax_resources/scrape_pubseqs/SRA_accession_list.txt
