#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=10g
#SBATCH -t 02-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

module load sratoolkit

for i in /pine/scr/z/p/zpopkinh/Pvivax_MIPs/SRA_download/sra/*.sra; do fasterq-dump ${i} --outdir /pine/scr/z/p/zpopkinh/Pvivax_MIPs/fastqs/ &> /nas/longleaf/home/zpopkinh/Pvivax_resources/scrape_pubseqs/fasterq-dump.out; done
