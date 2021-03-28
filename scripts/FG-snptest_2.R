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



#bgenfile <- "finngen_R6_19.3.bgen"
#samplefile <- "R6_full_samples_T2D.sample"
#transmissionOption <- 1
#prefix <- ""
#phenotype <- "T2D"
#snprange <- "20210323_var_T2D_CVD.txt"
#bsamplefile <- "../r6/R6_271341_samples.sample"

cmd <- paste("plink --bgen ", bgenfile,
" ref-unknown --sample ", bsamplefile,
" --extract range ", snprange, " --allow-extra-chr --export bgen-1.3 --out filteredSNPs",
 sep="")

#run plink command to filter for snps within the range 
system(cmd)

#transmissionOption <- 1
#prefix <- ""

list.files(pattern="*.bgen")
file.size("filteredSNPs.bgen")

print("running snptest")
# Run SNPTEST --------------
#frequentist options 1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote
cmd <- paste("snptest -data filteredSNPs.bgen ", samplefile, " -o ", prefix, 
  ".snptest.out -frequentist ", transmissionOption ," -method newml -cov_names ", {covars_collapsed}, 
  " -pheno ", phenotype, sep="")
## To sex stratify, use this flag! 
  #-stratify_on SEX_IMPUTED

print(cmd)
print(covars_collapsed)
system(cmd)

print("ran snptest")

#print("cleaning snptest output for output lines that we want")
#temp <- readLines(paste(prefix, ".snptest.out", sep="") ) 
#temp <- t(as.data.frame(strsplit(temp[c(grep('alternate_ids', temp), grep('alternate_ids', temp)+1) ], " " ) ) )
#rownames(temp) <- NULL

#write.table(temp, paste(prefix, ".snptest.out", sep=""), sep="\t", quote = F, col.names = F, row.names = F)
