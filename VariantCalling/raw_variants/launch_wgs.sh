#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=10g
#SBATCH -t 10-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

module add gatk

ROOT=/nas/longleaf/home/zpopkinh/Pvivax_resources/raw_variants
WD=/pine/scr/z/p/zpopkinh/Pvivax_MIPs/vcfs_gatk_joint_raw/
NODES=1028 # max number of cluster nodes
WAIT=30 # number of seconds to wait for files to appear, absorbing some file system latency

snakemake \
	--snakefile $ROOT/call_gatk4.snake \
	--configfile $ROOT/config.yaml \
	--printshellcmds \
	--directory $WD \
	--cluster $ROOT/launch.py \
	-j $NODES \
	--rerun-incomplete \
	--keep-going \
	--latency-wait $WAIT \
#	--dryrun -p
