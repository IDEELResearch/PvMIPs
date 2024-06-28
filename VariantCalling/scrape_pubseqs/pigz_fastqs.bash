#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --mem=20g
#SBATCH -t 02-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

module load pigz

for i in /pine/scr/z/p/zpopkinh/Pvivax_MIPs/fastqs/*.fastq; do pigz ${i}; done
