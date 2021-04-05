task test {
    String docker #from workflow
    String pheno #from workflow
    File bedfile #from json #### DO I REALLY NEED THIS?!?!?
    File bimfile = sub(bedfile, "\\.bed$", ".bim")
    File famfile = sub(bedfile, "\\.bed$", ".fam")
    String prefix = basename(bedfile, ".bed") + "-" + pheno
    String covariates #string of cov from json
    File samplefile #from null run
    File varList
    File bsamplefile
    String option #1=Additive, 2=Dominant, 3=Recessive, 4=General and 5=Heterozygote
    Array[File] bgenfiles #bgen file name from workflow

    command {
        
        python3.8 <<EOF
        import os
        import subprocess
        import time
            
        processes = set()
        # continuous traits don't have this file and optional outputs are not currently supported
        cmd_prefix = 'export MKL_NUM_THREADS=1; export MKL_DYNAMIC=false; export OMP_NUM_THREADS=1; export OMP_DYNAMIC=false; \
            FG-snptest_2.R \
                --plinkFile=${bedfile} \
                --phenoCol=${pheno} \
                --covarColList=${covariates} \
                --outputPrefix=${prefix} \
                --sampleFile=${samplefile} \
                --snprange=${varList} \
                --transmission=${option} \
                --bsampleFile=${bsamplefile} '
        for file in '${sep=" " bgenfiles}'.split(' '):
            cmd = cmd_prefix + '--bgenFile=' + file
            cmd = cmd + ' --outputFile=${prefix}' + os.path.basename(file) + '.snptest.out'
            logfile = open('snptest_log_${prefix}' + os.path.basename(file) + '.txt', 'w')
            processes.add(subprocess.Popen(cmd, shell=True, stdout=logfile))
        print(time.strftime("%Y/%m/%d %H:%M:%S") + ' ' + str(len(processes)) + ' processes started', flush=True)
        n_rc0 = 0
        while n_rc0 < len(processes):
            time.sleep(60)
            n_rc0 = 0
            for p in processes:
                p_poll = p.poll()
                if p_poll is not None and p_poll > 0:
                    raise Exception('subprocess returned ' + str(p_poll))
                if p_poll == 0:
                    n_rc0 = n_rc0 + 1
            print(time.strftime("%Y/%m/%d %H:%M:%S") + ' ' + str(n_rc0) + ' processes finished', flush=True)
        EOF

    }

    output {
        Array[File] out = glob("*.snptest.out")
        Array[File] logs = glob("snptest_log_*.txt")
    }

  runtime {
        docker: "${docker}"
        cpu: length(bgenfiles)
        memory: (6 * length(bgenfiles)) + " GB"
        disks: "local-disk " + (length(bgenfiles) * ceil(size(bgenfiles[0], "G")) + 20) + " HDD"
        zones: "europe-west1-b"
        preemptible: 2
        noAddress: true
    }

}

task combine {

    String pheno
    Array[Array[File]] results2D
    Array[File] results = flatten(results2D)
    String docker
    File bedfile #from json
    String prefix = basename(bedfile, ".bed") + "-" + pheno
    
    command <<<

        set -e

        echo "`date` concatenating results to ${prefix}${pheno}.snptest.out"
        cat \
        <(head -n 1 ${results[0]}) \
        <(for file in ${sep=" " results}; do tail -n+2 $file; done) \
        | bgzip > ${prefix}${pheno}.snptest.out.gz

    >>>

    output {
        
        File out = prefix + pheno + ".snptest.out.gz"

    }

    runtime {
        docker: "${docker}"
        cpu: 1
        memory: "16 GB"
        disks: "local-disk 200 HDD"
        zones: "europe-west1-b"
        preemptible: 2
        noAddress: true
    }
}

workflow test_combine {

    String docker
    String pheno
    String samplefile #from snptest wdl
    File bedfile
    String covariates
    File bgenlistfile
    File varList
    File bsamplefile
    Array[Array[String]] bgenfiles2D = read_tsv(bgenlistfile)
    String option

    scatter (bgenfiles in bgenfiles2D) {
        call test {
            input: docker=docker, pheno=pheno, varList=varList, samplefile=samplefile,
             bgenfiles=bgenfiles, bedfile=bedfile, covariates=covariates, option=option, bsamplefile=bsamplefile        }
    }

    call combine {
        input: pheno=pheno, results2D=test.out, docker=docker, bedfile=bedfile 
    }

    output {
        File out = combine.out
    }
}
