#! /bin/bash

ROOT=/nas/longleaf/home/zpopkinh/Pvivax_resources/wgs_qc_global_se/ # root directory for project (non-scratch)
WD=/pine/scr/z/p/zpopkinh/Pvivax_MIPs/wgs_qc_global_se/ # working directory for alignments (scratch)
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
