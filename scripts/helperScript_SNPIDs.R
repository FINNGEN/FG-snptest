#helper script to obtain snp IDs
#download bim file to vm from gs://r6_data/plink/finngen_R6.bim

mainBim <- "finngen_R6.bim" #replace this string with the bim file name
snprange <- "20210323_var_T2D_CVD.txt" #replace this string with the snprange
test_bim <- read.table(mainBim, sep="\t")
inclusion <- read.table(snprange, sep="\t", header=F)
test_bim$V7 <- paste(test_bim$V1, "_", test_bim$V4, sep="")
inclusion$V4 <- paste(inclusion$V1, "_", inclusion$V3, sep="")

test_bim <- test_bim[test_bim$V7 %in% inclusion$V4,]

write.table(test_bim, "20210402_var_T2D_CVD.txt", sep="\t", col.names=F, row.names=F, quote=F)
test_bim
