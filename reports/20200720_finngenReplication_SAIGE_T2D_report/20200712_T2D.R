##----------------------------##
# T2D Analysis for Txema       #
##----------------------------##

setwd("/mnt/disks/workDir")
load("20200627.RData")

 table(phenos.cov$T2D)
 #T2D_WIDE|E4_DM2         !E4_DM1
#0      1
#182573  29193
 table(phenos.cov$T2D_WIDE)
 #!PANCREATITIS                           E1
#0      1
#184778  17268
table(phenos.cov$T2D_INCLAVO)
#inpatient HILMO
#T2D_WIDE|E4_DM2         !E4_DM1 E11
#0      1
#180722  28717


summary(phenos.cov[!is.na(phenos.cov$T2D),]$AGE_AT_DEATH_OR_NOW)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#1.50   48.20   62.80   60.02   73.30  120.30

summary(phenos.cov[phenos.cov$T2D==0,]$AGE_AT_DEATH_OR_NOW)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's
#1.50   45.40   60.60   58.33   71.90  120.30    7026

summary(phenos.cov[phenos.cov$T2D==0,]$AGE_AT_DEATH_OR_NOW>55)
#Mode   FALSE    TRUE    NA's
#logical   71540  111033    7026

summary(phenos.cov[phenos.cov$T2D==1,]$AGE_AT_DEATH_OR_NOW)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's
#18.10   64.09   72.00   70.58   78.70  102.81    7026

#control selection
phenos.cov$T2D_Tx <- phenos.cov$T2D
phenos.cov$T2D_Tx <- ifelse(phenos.cov$T2D_Tx==0 & phenos.cov$AGE_AT_DEATH_OR_NOW>55, 0, 
                            ifelse(phenos.cov$T2D_Tx==1, 1, NA) )
table(phenos.cov$T2D_Tx)
#0      1
#111033  29193


phenos.cov$T2D_WIDE_Tx <- phenos.cov$T2D_WIDE
phenos.cov$T2D_WIDE_Tx <- ifelse(phenos.cov$T2D_WIDE_Tx==0 & phenos.cov$AGE_AT_DEATH_OR_NOW>55, 0, 
                            ifelse(phenos.cov$T2D_WIDE_Tx==1, 1, NA) )
table(phenos.cov$T2D_WIDE_Tx)
#     0      1
#110994  17268

phenos.cov$T2D_INCLAVO_Tx <- phenos.cov$T2D_INCLAVO
phenos.cov$T2D_INCLAVO_Tx <- ifelse(phenos.cov$T2D_INCLAVO_Tx==0 & phenos.cov$AGE_AT_DEATH_OR_NOW>55, 0, 
                                 ifelse(phenos.cov$T2D_INCLAVO_Tx==1, 1, NA) )
table(phenos.cov$T2D_INCLAVO_Tx)
#     0      1
#109462  28717


todaysDate <- format.Date(Sys.Date(), "20%y%m%d")
write.table(phenos.cov, paste(todaysDate, "_R5_COV_PHENO_KV.txt", sep=""), sep="\t", quote = F, 
            col.names = T, row.names = F)
command<- paste("gzip -9 -v ", paste(todaysDate, "_R5_COV_PHENO_KV.txt", sep=""), sep="")
system(command)

phenos.list <- colnames(phenos.cov[grep("T2D", colnames(phenos.cov))] )
phenos.list
write.table(phenos.list, paste(todaysDate, "phenoList.txt", sep="_"), sep="\t", quote=F, col.names = F, row.names = F)
save.image(file=paste(todaysDate,"RData", sep=".") )


#python3 pheno_independent.py \
#--related-couples finngen_R5_related_couples_2.txt \
#-o ../../ \
#-p ../../20200713_phenoList.txt \
#--cases test.c.txt \ 
#--rejected test.r.txt
