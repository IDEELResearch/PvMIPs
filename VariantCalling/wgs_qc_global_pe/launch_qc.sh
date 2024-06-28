#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=32g
#SBATCH -t 6:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

ROOT=/nas/longleaf/home/zpopkinh/Pvivax_resources/wgs_qc_global_pe/ # root directory for project (non-scratch)
WD=/pine/scr/z/p/zpopkinh/Pvivax_MIPs/wgs_qc_global_pe/ # working directory for alignments (scratch)
NODES=1028 # max number of cluster nodes
WAIT=30 # number of seconds to wait for files to appear, absorbing some file system latency

snakemake \
	--snakefile $ROOT/qc_wgs.snake \
	--configfile config_qc.yaml \
	--printshellcmds \
	--directory $WD \
	--cluster $ROOT/launch.py \
	-j $NODES \
	--rerun-incomplete \
	--keep-going \
	--latency-wait $WAIT \
#	--dryrun -p 
