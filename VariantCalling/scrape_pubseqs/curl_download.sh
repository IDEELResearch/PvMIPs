#! /bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mem=10g
#SBATCH -t 02-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=zpopkinh@email.unc.edu

cd /pine/scr/z/p/zpopkinh/Pvivax_MIPs/fastqs/SE/

while read CSV;
do
URL=$(echo $CSV | cut -d"," -f2);
curl -O -J -L ${URL};
done < /nas/longleaf/home/zpopkinh/Pvivax_resources/scrape_pubseqs/curl_download_se.csv

cd /pine/scr/z/p/zpopkinh/Pvivax_MIPs/fastqs/PE/

while read CSV;
do
URL_R1=$(echo $CSV | cut -d"," -f2);
URL_R2=$(echo $CSV | cut -d"," -f3);
curl -O -J -L ${URL_R1};
curl -O -J -L ${URL_R2};
done < /nas/longleaf/home/zpopkinh/Pvivax_resources/scrape_pubseqs/curl_download_pe.csv