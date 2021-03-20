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
  make_option("--transmission", type="integer", default="",
    help="the transmission option where 1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote")
 )   

## list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

phenotype <- opt$phenoCol
covars <- strsplit(opt$covarColList,",")[[1]]
print("reading in covars")

# Load phenotype + covars data ------
samplefile <- opt$sampleFile
#sample_phenotype <-
#data.table::fread(samplefile) %>% as.data.frame()
#print("loaded sample file")

bgenfile <- opt$bgenFile
prefix <- opt$outputPrefix
covars_collapsed = glue::glue_collapse(covars, sep = " ")
snprange <- opt$snprange
transmissionOption <- opt$transmission

cmd <- paste("plink --bgen ", {bgenfile},
" ref-unknown --sample ", {bgenfile}, ".sample ",
"--extract range ", {snprange}, "--export bgen-1.1 --out filteredSNPs", sep="")

system(cmd)

print("running snptest")
# Run SNPTEST --------------
#frequentist 1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote
cmd <- paste("snptest -data filteredSNPs.bgen ", {samplefile}, " -o ", {prefix}, 
  ".snptest-recessive.out -frequentist ", transmissionOption, " -method score -cov_names ", {covars_collapsed}, 
  " -pheno ", {phenotype}, sep="")

print(cmd)
print(covars_collapsed)
system(cmd)

print("ran snptest")