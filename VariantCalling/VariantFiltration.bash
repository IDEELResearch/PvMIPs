#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=50g
#SBATCH -t 02-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

cd /pine/scr/z/p/zpopkinh/Pvivax_MIPs/vcfs_gatk_joint_raw/chunks/all/

#	gatk VariantFiltration \
	-R /proj/ideel/resources/genomes/Pvivax/genomes/PvP01.fasta \
	-V firstpass_masked-rm.recode.vcf.gz \
	-O Pvivax_hard_filtered.vcf.gz \
	--filter-name "lowQD" \
	--filter-expression "QD<4.0" \
	--filter-name "highFS" \
	--filter-expression "FS>10.0" \
	--filter-name "lowMQ" \
	--filter-expression "MQ<50.0" \
	--filter-name "lowMQRankSum" \
	--filter-expression "MQRankSum<-2.5" \
	--filter-name "lowReadPosRankSum" \
	--filter-expression "ReadPosRankSum<-5.0"

bcftools view -m2 -M2 -v snps Pvivax_hard_filtered.vcf.gz -O z -o Pvivax_hard_filtered_biallelic_snps_only.vcf.gz
