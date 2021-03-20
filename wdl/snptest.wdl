import "snptest_sub.wdl" as sub

task null {

    String docker #from workflow
    String pheno #from workflow
    File phenofile #cov file with IDs
    File bedfile #from json
    File bimfile = sub(bedfile, "\\.bed$", ".bim")
    File famfile = sub(bedfile, "\\.bed$", ".fam")
    String prefix = basename(bedfile, ".bed") + "-" + pheno
    String covariates #string of cov from json
    File samplefile #all the samples .sample file
    File relatedfile #kinship generated file of unrelated ind
    Int cpu = 32

    command {

        FG-snptest_1.R \
            --phenoFile=${phenofile} \
            --phenoCol=${pheno} \
            --covarColList=${covariates} \
            --outputPrefix=${prefix} \
            --sampleFile=${samplefile} \
            --relatedSamples=${relatedfile} 
    }

    output {

        File sample = "R6_full_samples_" + pheno + ".sample"
        File exclusion = "samples_exclude_" + pheno + ".list"

    }

    runtime {

        docker: "${docker}"
        cpu: "${cpu}"
        memory: "7 GB"
        disks: "local-disk 20 HDD"
        zones: "europe-west1-b"
        preemptible: 2
        noAddress: true
    }
}


workflow snptest {

    String docker
    File phenolistfile
    Array[String] phenos = read_lines(phenolistfile)
    File bedfile 
    String covariates 

    scatter (pheno in phenos) {
            call null {
                input: docker=docker, pheno=pheno, bedfile=bedfile, covariates=covariates 
            }

            call sub.test_combine {
           
                input: docker=docker, pheno=pheno, samplefile=null.sample, bedfile=bedfile, covariates=covariates

    }
    }
  
}