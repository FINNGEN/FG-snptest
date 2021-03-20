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
    help="the bgen files")
 ) 

## list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

covars <- strsplit(opt$covarColList,",")[[1]]

# Load phenotype + covars data ------
phenofile <- opt$phenoFile
#phenofile <- "20210313_R6_COV_PHENO_KV.txt.gz"
dat_pheno_ <-
data.table::fread(phenofile) %>% as.data.frame()
print("loaded phenofile")
 
# Prepare data for SNPTEST ---------
## sample file should contain all phenotype and covariates
samplefile <- opt$sampleFile
#samplefile <- "R6_271341_samples.sample"
sample <-
    data.table::fread(samplefile, skip = 2, header = FALSE)
    names(sample) <- c("ID_1", "ID_2", "missing")
print("loaded sample file")

## use all phenotype data, then remove samples from snptest

#covars <- "SEX_IMPUTED,AGE_AT_DEATH_OR_NOW,PC1,PC2,PC3,PC4,PC5,BATCH_Axiom,BATCH_DS1_BOTNIA_Dgi_norm,BATCH_DS10_FINRISK_Palotie_norm,BATCH_DS11_FINRISK_PredictCVD_COROGENE_Tarto_norm,BATCH_DS12_FINRISK_Summit_norm,BATCH_DS13_FINRISK_Bf_norm,BATCH_DS14_GENERISK_norm,BATCH_DS15_H2000_Broad_norm,BATCH_DS16_H2000_Fimm_norm,BATCH_DS17_H2000_Genmets_norm,BATCH_DS18_MIGRAINE_1_norm,BATCH_DS19_MIGRAINE_2_norm,BATCH_DS2_BOTNIA_T2dgo_norm,BATCH_DS20_SUPER_1_norm,BATCH_DS21_SUPER_2_norm,BATCH_DS22_TWINS_1_norm,BATCH_DS23_TWINS_2_norm,BATCH_DS24_SUPER_3_norm,BATCH_DS25_BOTNIA_Regeneron_norm,BATCH_DS3_COROGENE_Sanger_norm,BATCH_DS4_FINRISK_Corogene_norm,BATCH_DS5_FINRISK_Engage_norm,BATCH_DS6_FINRISK_FR02_Broad_norm,BATCH_DS7_FINRISK_FR12_norm,BATCH_DS8_FINRISK_Finpcga_norm,BATCH_DS9_FINRISK_Mrpred_norm"
#covars <- strsplit(covars,",")[[1]]
#i <- 1
#phenotype <- "I9_HYPERTENSION"
phenotype <- opt$phenoCol
sample_phenotype <- sample %>% 
  left_join(dat_pheno_[,c("FINNGENID", phenotype, covars)], by = c("ID_1" = "FINNGENID"))
print("merged phenotype and sample file with covars")
#error catching    
#stopifnot(identical(sample$ID_1, sample_phenotype$ID_1))

## id, id, missing, phenotype, sex, age, 10 PCs, batches
## https://jmarchini.org/file-formats/
second_header <- c("0", "0", "0", "B", "D", rep("C", 11), rep("D", length(covars) - 12))
second_header <- (as.matrix(t(second_header)))
colnames(second_header) <- colnames(sample_phenotype)
sample_phenotype <- rbind(second_header, sample_phenotype)
print("merged phenotype file with second header")


## samples to exclude
#samples_related <- read.table("../r6_plinkKinship/finngen_R6_kinship_couples.kin0", header=T, sep="\t")
samples_related <- opt$relatedSamples
#samples_related <- read.table(samples_related, header=F)
#samples_related <- dat_pheno_[!(samples_related$FID1 %in% dat_pheno_$FINNGENID),]$FINNGENID
#age for controls is including people >55 years old
samples_young_controls <- dat_pheno_[dat_pheno_$AGE_AT_DEATH_OR_NOW <= 55 & dat_pheno_[[phenotype]]==0, ]$FINNGENID
print("filter created for young controls")
write.table(samples_young_controls, paste(phenotype, "_controls.txt", sep="") , sep="\t", quote = F, col.names = F, row.names = F)

###Using maximal independent script
cases <- dat_pheno_[dat_pheno_[[phenotype]]==1 & !is.na(dat_pheno_[[phenotype]]),]$FINNGENID
write.table(cases, paste(phenotype, "_cases.txt", sep="") , sep="\t", quote = F, col.names = F, row.names = F)

cmd <- paste("python3.8 /usr/local/bin/pheno_independent.py --related-couples ", {samples_related}, 
  " -o . -p ", {phenotype}, " --cases ", {phenotype},"_cases.txt ", "--rejected ", 
  {phenotype}, "_controls.txt", sep="")
print(cmd)
system(cmd)

print("running pheno_independent.py")

samples_related <- readLines(paste("results/", {phenotype}, "_related_samples.txt", sep=""))
samples_exclude <- data.frame(c(samples_young_controls, samples_related))
samples_exclude <- samples_exclude[order(samples_exclude),]
samples_exclude <- as.data.frame(unique(samples_exclude))
   data.table::fwrite(samples_exclude, glue::glue("samples_exclude_{phenotype}.list"), sep = " ", na = "NA", quote = FALSE)
print("excluded sample file created")

#removing samples from the data
sample_phenotype <- sample_phenotype[order(sample_phenotype$ID_1),]
samples_exclude <- samples_exclude[,1]
sample_phenotype[[phenotype]] <- 
    ifelse(as.character(sample_phenotype$ID_1) %in% samples_exclude, NA, sample_phenotype[[phenotype]])
#sample_phenotype[[phenotype]] <- 
#    ifelse(is.na(sample_phenotype[[phenotype]]), -9, sample_phenotype[[phenotype]])

#sample_phenotype <- sample_phenotype[!(sample_phenotype$ID_1 %in% samples_exclude ),]
data.table::fwrite(sample_phenotype, glue::glue("R6_full_samples_{phenotype}.sample"), sep = " ", na = "NA", quote = FALSE)
print("cleaned sample file created with all samples, but cleaned for phenotype")