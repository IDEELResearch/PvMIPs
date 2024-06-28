#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=32g
#SBATCH -t 02-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

cd /pine/scr/z/p/zpopkinh/Pvivax_MIPs/wgs_pe_improved_global/

java -jar -Xmx8g -XX:-UseGCOverheadLimit -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar MergeSamFiles SORT_ORDER=coordinate INPUT=aln/lanes_raw/ERS333055/ERR351948.aligned.bam INPUT=aln/lanes_raw/ERS333055/ERR351959.aligned.bam INPUT=aln/lanes_raw/ERS333055/ERR562993.aligned.bam INPUT=aln/lanes_raw/ERS333055/ERR562999.aligned.bam OUTPUT=aln/merged/ERS333055.bam TMP_DIR=.tmp MAX_RECORDS_IN_RAM=1000000

java -jar -Xmx4g -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar BuildBamIndex \
INPUT=aln/merged/ERS333055.bam \
OUTPUT=aln/merged/ERS333055.bam.bai \
TMP_DIR=.tmp \
VALIDATION_STRINGENCY=LENIENT

#rm -rf aln/lanes_raw/ERS333055/*

java -jar -Xmx8g -XX:-UseGCOverheadLimit -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar MergeSamFiles SORT_ORDER=coordinate INPUT=aln/lanes_raw/ERS333077/ERR351956.aligned.bam INPUT=aln/lanes_raw/ERS333077/ERR351967.aligned.bam INPUT=aln/lanes_raw/ERS333077/ERR562998.aligned.bam INPUT=aln/lanes_raw/ERS333077/ERR563004.aligned.bam OUTPUT=aln/merged/ERS333077.bam TMP_DIR=.tmp MAX_RECORDS_IN_RAM=1000000

java -jar -Xmx4g -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar BuildBamIndex \
INPUT=aln/merged/ERS333077.bam \
OUTPUT=aln/merged/ERS333077.bam.bai \
TMP_DIR=.tmp \
VALIDATION_STRINGENCY=LENIENT

#rm -rf aln/lanes_raw/ERS333077/*

java -jar -Xmx8g -XX:-UseGCOverheadLimit -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar MergeSamFiles SORT_ORDER=coordinate INPUT=aln/lanes_raw/SRS2745892/SRR6361463.aligned.bam INPUT=aln/lanes_raw/SRS2745892/SRR6361550.aligned.bam OUTPUT=aln/merged/SRS2745892.bam TMP_DIR=.tmp MAX_RECORDS_IN_RAM=1000000

java -jar -Xmx4g -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar BuildBamIndex \
INPUT=aln/merged/SRS2745892.bam \
OUTPUT=aln/merged/SRS2745892.bam.bai \
TMP_DIR=.tmp \
VALIDATION_STRINGENCY=LENIENT

#rm -rf aln/lanes_raw/SRS2745892/*

java -jar -Xmx8g -XX:-UseGCOverheadLimit -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar MergeSamFiles SORT_ORDER=coordinate INPUT=aln/lanes_raw/SRS2746073/SRR6361692.aligned.bam INPUT=aln/lanes_raw/SRS2746073/SRR6361763.aligned.bam OUTPUT=aln/merged/SRS2746073.bam TMP_DIR=.tmp MAX_RECORDS_IN_RAM=1000000

java -jar -Xmx4g -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar BuildBamIndex \
INPUT=aln/merged/SRS2746073.bam \
OUTPUT=aln/merged/SRS2746073.bam.bai \
TMP_DIR=.tmp \
VALIDATION_STRINGENCY=LENIENT

#rm -rf aln/lanes_raw/SRS2746073/*

java -jar -Xmx8g -XX:-UseGCOverheadLimit -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar MergeSamFiles SORT_ORDER=coordinate INPUT=aln/lanes_raw/SRS2745842/SRR6361513.aligned.bam INPUT=aln/lanes_raw/SRS2745842/SRR6361699.aligned.bam OUTPUT=aln/merged/SRS2745842.bam TMP_DIR=.tmp MAX_RECORDS_IN_RAM=1000000

java -jar -Xmx4g -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar BuildBamIndex \
INPUT=aln/merged/SRS2745842.bam \
OUTPUT=aln/merged/SRS2745842.bam.bai \
TMP_DIR=.tmp \
VALIDATION_STRINGENCY=LENIENT

#rm -rf aln/lanes_raw/SRS2745842/*

java -jar -Xmx8g -XX:-UseGCOverheadLimit -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar MergeSamFiles SORT_ORDER=coordinate INPUT=aln/lanes_raw/ERS2593850/ERR2678991.aligned.bam  OUTPUT=aln/merged/ERS2593850.bam TMP_DIR=.tmp MAX_RECORDS_IN_RAM=1000000

java -jar -Xmx4g -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar BuildBamIndex \
INPUT=aln/merged/ERS2593850.bam \
OUTPUT=aln/merged/ERS2593850.bam.bai \
TMP_DIR=.tmp \
VALIDATION_STRINGENCY=LENIENT

#rm -rf aln/lanes_raw/ERS2593850/*
