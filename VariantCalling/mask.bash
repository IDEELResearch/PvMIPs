#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=32g
#SBATCH -t 12:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

cd /pine/scr/z/p/zpopkinh/Pvivax_MIPs/vcfs_gatk_joint_raw/chunks/all/

vcftools --gzvcf firstpass.vcf.gz --out firstpass_masked-rm --exclude-bed /nas/longleaf/home/zpopkinh/Pvivax_resources/PVP01.genome.mask.sorted.bed --recode --keep-INFO-all
bgzip -c firstpass_masked-rm.recode.vcf > firstpass_masked-rm.recode.vcf.gz
bcftools index -t firstpass_masked-rm.recode.vcf.gz