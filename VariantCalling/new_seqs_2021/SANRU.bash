#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=32g
#SBATCH -t 02-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

cd /pine/scr/z/p/zpopkinh/Pvivax_MIPs/wgs_pe_IDEEL_samples/

cutadapt --interleaved \
-a file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa \
-A file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa \
-m 30 \
/nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L1_1.fastq.gz /nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L1_2.fastq.gz \
2>/nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L1_trimming.log | \
bwa mem -t 6 -YK100000000 \
-H '@PG\tID:cutadapt\tCL:cutadapt -a file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa -A file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa -m 30 --interleaved /nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L1_1.fastq.gz /nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L1_2.fastq.gz 2>/nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L1_trimming.log' \
-R '@RG\tLB:SANRU_L1\tID:SANRU_L1\tSM:SANRU_L1\tPL:illumina' -p \
/proj/ideel/resources/genomes/Pvivax/genomes/PvP01.fasta - | \
samblaster --addMateTags | \
samtools view -bhS - >aln/lanes_raw/SANRU/SANRU_L1.aligned.bam

cutadapt --interleaved \
-a file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa \
-A file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa \
-m 30 \
/nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L2_1.fastq.gz /nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L2_2.fastq.gz \
2>/nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L2_trimming.log | \
bwa mem -t 6 -YK100000000 \
-H '@PG\tID:cutadapt\tCL:cutadapt -a file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa -A file:/nas02/apps/trimmomatic-0.36/Trimmomatic-0.36/adapters/TruSeq3-PE.fa -m 30 --interleaved /nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L2_1.fastq.gz /nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L2_2.fastq.gz 2>/nas/longleaf/home/zpopkinh/Pvivax_resources/new_seqs_2021/fastq/SANRU/SANRU_L2_trimming.log' \
-R '@RG\tLB:SANRU_L2\tID:SANRU_L2\tSM:SANRU_L2\tPL:illumina' -p \
/proj/ideel/resources/genomes/Pvivax/genomes/PvP01.fasta - | \
samblaster --addMateTags | \
samtools view -bhS - >aln/lanes_raw/SANRU/SANRU_L2.aligned.bam

java -jar -Xmx8g -XX:-UseGCOverheadLimit -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar MergeSamFiles SORT_ORDER=coordinate INPUT=aln/lanes_raw/SANRU/SANRU_L1.aligned.bam INPUT=aln/lanes_raw/SANRU/SANRU_L2.aligned.bam OUTPUT=aln/merged/SANRU.bam TMP_DIR=.tmp MAX_RECORDS_IN_RAM=1000000

java -jar -Xmx4g -XX:ParallelGCThreads=5 /nas02/apps/picard-2.10.3/picard-2.10.3/picard.jar BuildBamIndex \
INPUT=aln/merged/SANRU.bam \
OUTPUT=aln/merged/SANRU.bam.bai \
TMP_DIR=.tmp \
VALIDATION_STRINGENCY=LENIENT

