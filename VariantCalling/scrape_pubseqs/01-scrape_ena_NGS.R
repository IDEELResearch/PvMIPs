## .................................................................................
## Purpose: Scrape Sequences from ENA to download by sample accession
##
## Notes: Parsing on the ENA site not tidy, here a very customized function
## .................................................................................
library(tidyverse)
library(RSelenium)
library(rvest)

# functions
get_accessions <- function(x){
  # assign the client to a new variable
  remDr$navigate(paste0("https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=",
                        x,
                        "&result=read_run&fields=fastq_ftp"))

  webElem <- remDr$findElement(using = "xpath", "/html/body/pre")
  fstqtabletxt <- XML::htmlTreeParse(webElem$getElementAttribute("outerHTML")[[1]], useInternalNodes = F)
  ret <- capture.output(fstqtabletxt$children[[1]][[1]][[1]][[1]])
  ret <- as.data.frame( stringr::str_split_fixed(ret, "\t", n = 2) )[2:length(ret),]
  colnames(ret) <- c("acc", "runs")
  ret <- ret %>%
    dplyr::mutate(acc = x,
                  R1 = stringr::str_split_fixed(runs, ";", n = 2)[,1],
                  R2 = stringr::str_split_fixed(runs, ";", n = 2)[,2]) %>%
    dplyr::select(-c("runs"))
  # sleep to not overwhelm server and out
  Sys.sleep(2)
  return(ret)
}

# valid(?!) alternative with multiple functions
##only use this code if you need to debug small issues - it will not reproduce the full output of the original code above

#get_url <- function(x){
         paste0("https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=",
                                     x,
                                     "&result=read_run&fields=fastq_ftp")
#}




#get_text <- function(x){
       html_list <- read_html(x)
       html_text2(html_list)
       fstqtabletxt <- XML::htmlTreeParse(WebElem$getElementAttribute("outerHTML")[[1]], useInternalNodes = F)
       ret <- capture.output(fstqtabletxt$children[[1]][[1]][[1]][[1]])
       ret <- as.data.frame( stringr::str_split_fixed(ret, "\t", n = 2) )[2:length(ret),]
       colnames(ret) <- c("acc", "runs")
       ret <- ret %>%
         dplyr::mutate(acc = x,
                       R1 = stringr::str_split_fixed(runs, ";", n = 2)[,1],
                       R2 = stringr::str_split_fixed(runs, ";", n = 2)[,2]) %>%
         dplyr::select(-c("runs"))
       # sleep to not overwhelm server and out
       Sys.sleep(2)
       return(ret)
#}



# read in metadata
smpls <- readxl::read_excel("vivid_seq_public_NGS.xlsx") %>%
  dplyr::filter(acc != "from_authors")
accessions <- smpls$acc
# spin up local docker machine for firefox driver
# https://docs.ropensci.org/RSelenium/articles/docker.html
# for this to work, you need to a) install Docker
# b) pull the relevant Docker package in terminal (docker pull selenium/standalone-firefox) and
# c) start the server in terminal (docker run -d -p 4445:4444 selenium/standalone-firefox)
remDr <- RSelenium::remoteDriver(port = 4445L)
remDr$open()

# run through accessions

##only use this code if you need to debug small issues - it will not reproduce the full output of the original code above

#url_list <- lapply(accessions, get_url)

#metadata <- lapply(url_list,get_text)

enadf <- lapply(accessions, get_accessions) %>%
  dplyr::bind_rows()

RD$close()
remDr$closeServer


#...............
# Single End
#...............
enadf.se <- enadf %>%
  dplyr::filter(R2 == "") %>%
  dplyr::select(-c("R2"))

#...............
# Paired End
#...............
enadf.pe <- enadf %>%
  dplyr::filter(R2 != "")

# note PMC6032790 has an extra fastq (extra file) that isn't PE ? Going to subset just to R1/R2
enadf.pe.norm <- enadf.pe %>%
  dplyr::filter(!grepl(";", R2))

enadf.pe.extra <- enadf.pe %>%
  dplyr::filter(grepl(";", R2)) %>%
  dplyr::mutate(temp = R2,
                R1 = NA,
                R2 = NA,
                R1 = stringr::str_split_fixed(temp, ";", n=2)[,1],
                R2 = stringr::str_split_fixed(temp, ";", n=2)[,2]
  ) %>%
  dplyr::select(-c("temp"))

enadf.pe.cleaned <- rbind.data.frame(enadf.pe.norm, enadf.pe.extra)

readr::write_tsv(x=enadf.pe.cleaned,
                 path = "ENA_master_acc_download_map_PE.tab.txt")

readr::write_tsv(x=enadf.se,
                 path = "ENA_master_acc_download_map_SE.tab.txt")

