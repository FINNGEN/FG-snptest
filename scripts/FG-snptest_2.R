#!/usr/bin/env Rscript
options(stringsAsFactors=F)

## load libraries
library(dplyr)
library(ggplot2)
library(janitor)
library(readr)
library(knitr)
library(readr)
library(kableExtra)
library(ggmosaic)
library(data.table)
library(R.utils)
library(optparse)

print("starting R script")

## list command line options
option_list <- list(
  make_option("--plinkFile", type="character",default="",
    help="bed file used for snptest"),
  make_option("--phenoFile", type="character", default="",
    help="the phenotype file. Contains columns with phenotypes and covariates"),
  make_option("--phenoCol", type="character", default="",
    help="Coloumn name for phenotype to be tested in the phenotype file, e.g CAD"),
  make_option("--covarColList", type="character", default="",
    help="List of covariates (comma separated)"),
  make_option("--outputPrefix", type="character", default="~/",
    help="prefix of the output files"),
  make_option("--sampleFile", type="character",default="",
    help="samples .sample file. only needed for bgen files. "),
  make_option("--relatedSamples", type="character", default="",
    help="file containing unrelated sample list"),
  make_option("--bgenFile", type="character", default="",
    help="the bgen files"),
  make_option("--outputFile", type="character", default="",
    help="the output file"),
  make_option("--snprange", type="character", default="",
    help="the snp range file"),
  make_option("--transmission", type="character", default="",
    help="the transmission option where 1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote"),
  make_option("--bsampleFile", type="character", default="",
    help="the bgen sample file for all the samples")
 )   

## list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

phenotype <- opt$phenoCol
covars <- strsplit(opt$covarColList,",")[[1]]
print("reading in covars")

#read in file names and options
samplefile <- opt$sampleFile
bgenfile <- opt$bgenFile
prefix <- opt$outputPrefix
covars_collapsed = glue::glue_collapse(covars, sep = " ")
snprange <- opt$snprange
bsamplefile <- opt$bsampleFile

if(length(grep(",", opt$transmission))!=0){
  transmissionOption <- strsplit(opt$transmission,",")[[1]]
  transmissionOption = glue::glue_collapse(transmissionOption, sep = " ")
} else{
  transmissionOption <- opt$transmission}

#https://groups.google.com/g/plink2-users/c/iaQn0AC-7SU let's see if the memory isssue is a reason

temp <- strsplit(bgenfile,"/")[[1]] #split bgen name by /
temp <- temp[length(temp)] #obtain just the bgen file without the dir
bgenprefix <- substr(temp,1,nchar(temp)-5) #remove the extension .bgen from file
bgenprefix

temp <- strsplit(temp,"\\.")[[1]] #using the above, just obtaining the bgen basename
temp <- strsplit(temp, "_")[[1]] #splitting the finngen name by _ to get the final part
chrID <- temp[length(temp)] #the final part of the base name without the "." is the chr ID
chrID

varIncluded <- read.table(snprange, sep="\t")
varIncluded <- varIncluded[varIncluded$V1 == chrID,]
varIncluded <- glue::glue_collapse(varIncluded$V2, sep = " ")
varIncluded

list.files(pattern="*.bgen")
#file.size("filteredSNPs.bgen")

print("running snptest")
# Run SNPTEST --------------
#frequentist options 1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote
if(length(varIncluded) == 0){
  print("no var to run")
}else{
  cmd <- paste("snptest -data ", bgenfile, " ", samplefile, " -o ", prefix, bgenprefix, 
    ".snptest.out -frequentist ", transmissionOption ," -method em -cov_names ", {covars_collapsed}, 
    " -pheno ", phenotype, " -snpid ", varIncluded, sep="")
    print(cmd)
    print(covars_collapsed)
    system(cmd)
    print("ran snptest")
    list.files(pattern="*.snptest.out")
}

## To sex stratify, use this flag! 
  #-stratify_on SEX_IMPUTED

#print("cleaning snptest output for output lines that we want")
#OR sed '/^#/d'
#prefix, bgenprefix, ".snptest.out"
#temp <- readLines(paste(prefix, ".snptest.out", sep="") ) 
#temp <- t(as.data.frame(strsplit(temp[c(grep('alternate_ids', temp), grep('alternate_ids', temp)+1) ], " " ) ) )
#rownames(temp) <- NULL

#write.table(temp, paste(prefix, ".snptest.out", sep=""), sep="\t", quote = F, col.names = F, row.names = F)