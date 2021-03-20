# FG-snptest

The scripts ran from this repo was used for Josep Mercader's replication for T2D and CVD using FinnGen.
Initially, we ran the replication with [SAIGE](https://github.com/weizhouUMICH/SAIGE) but due to potential incoherencies, we are rerunning it with [SNPTEST](https://mathgen.stats.ox.ac.uk/genetics_software/snptest/snptest.html).
Updated [SNPTEST](https://jmarchini.org/snptest/) documentation.
The initial run results report is in the `reports/20200720_finngenReplication_SAIGE_T2D_report/` dir.

Running this should be pretty straightforward using the Dockerfile and FinnGen refinery access to [cromwell](https://github.com/broadinstitute/cromwell) resources.

### (1) Phenotypes (Endpoints in FinnGen)
Phenotypes tested are found in the `src/replicationT2D-CVD.pheno` file.

### (2) Covariates tested
```
SEX_IMPUTED,AGE_AT_DEATH_OR_NOW,PC1,PC2,PC3,PC4,PC5,BATCH_Axiom,BATCH_DS1_BOTNIA_Dgi_norm,BATCH_DS10_FINRISK_Palotie_norm,BATCH_DS11_FINRISK_PredictCVD_COROGENE_Tarto_norm,BATCH_DS12_FINRISK_Summit_norm,BATCH_DS13_FINRISK_Bf_norm,BATCH_DS14_GENERISK_norm,BATCH_DS15_H2000_Broad_norm,BATCH_DS16_H2000_Fimm_norm,BATCH_DS17_H2000_Genmets_norm,BATCH_DS18_MIGRAINE_1_norm,BATCH_DS19_MIGRAINE_2_norm,BATCH_DS2_BOTNIA_T2dgo_norm,BATCH_DS20_SUPER_1_norm,BATCH_DS21_SUPER_2_norm,BATCH_DS22_TWINS_1_norm,BATCH_DS23_TWINS_2_norm,BATCH_DS24_SUPER_3_norm,BATCH_DS25_BOTNIA_Regeneron_norm,BATCH_DS3_COROGENE_Sanger_norm,BATCH_DS4_FINRISK_Corogene_norm,BATCH_DS5_FINRISK_Engage_norm,BATCH_DS6_FINRISK_FR02_Broad_norm,BATCH_DS7_FINRISK_FR12_norm,BATCH_DS8_FINRISK_Finpcga_norm,BATCH_DS9_FINRISK_Mrpred_norm
```

_To note_: The Axiom batches were collapsed and the number of PCs were halved (from 10 to 5). 
_Collapsed batches_:
```
BATCH_AxiomGT1_b01_V2P2.calls + BATCH_AxiomGT1_b02_V2P2.calls + BATCH_AxiomGT1_b03_V2P2.calls + BATCH_AxiomGT1_b04_V2P2.calls + BATCH_AxiomGT1_b05_V2P2.calls + BATCH_AxiomGT1_b06_V2P2.calls + BATCH_AxiomGT1_b07_V2P2.calls + BATCH_AxiomGT1_b08_V2P2.calls + BATCH_AxiomGT1_b09_V2P2.calls + BATCH_AxiomGT1_b10_V2P2.calls + BATCH_AxiomGT1_b11_V2P2.calls + BATCH_AxiomGT1_b12_V2P2.calls + BATCH_AxiomGT1_b13_V2P2.calls + BATCH_AxiomGT1_b14_V2P2.calls + BATCH_AxiomGT1_b15_V2P2.calls + BATCH_AxiomGT1_b17_V2P2.calls + BATCH_AxiomGT1_b18_V2P2.calls + BATCH_AxiomGT1_b19_V2P2.calls + BATCH_AxiomGT1_b20_V2P2.calls + BATCH_AxiomGT1_b21_V2P2.calls + BATCH_AxiomGT1_b22_V2P2.calls + BATCH_AxiomGT1_b23_V2P2.calls + BATCH_AxiomGT1_b24_V2P2.calls + BATCH_AxiomGT1_b25_V2P2.calls + BATCH_AxiomGT1_b26_V2P2.calls + BATCH_AxiomGT1_b27_V2P2.calls + BATCH_AxiomGT1_b28_V2P2.calls + BATCH_AxiomGT1_b29_V2P2.calls + BATCH_AxiomGT1_b30_V2P2.calls + BATCH_AxiomGT1_b31_V2.calls + BATCH_AxiomGT1_b3234_V2.calls + BATCH_AxiomGT1_b33_V2.calls + BATCH_AxiomGT1_b35_V2.calls + BATCH_AxiomGT1_b36_V2.calls + BATCH_AxiomGT1_b37_V2.calls + BATCH_AxiomGT1_b38_V2.calls + BATCH_AxiomGT1_b39_V2.calls + BATCH_AxiomGT1_b40_V2.calls + BATCH_AxiomGT1_b41_V2.calls + BATCH_AxiomGT1_b42_V2.calls + BATCH_AxiomGT1_b43_V2.calls + BATCH_AxiomGT1_b44_V2.calls + BATCH_AxiomGT1_b45_V2.calls + BATCH_AxiomGT1_b46_V2.calls + BATCH_AxiomGT1_b47_V2.calls + BATCH_AxiomGT1_b48_V2.calls + BATCH_AxiomGT1_b49_V2.calls + BATCH_AxiomGT1_b50_V2.calls + BATCH_AxiomGT1_b51_V2.calls
```

For the **T2D** phenotypes, we also included `covariate:BMI`


### (3) SNPs tested
_Also included in the `src` folder_

| rsID | SNP ID (hg19) | SNP ID (hg38) |
|------|--------------| --------------| 
|rs12031785	|1:219686440-219686440	|1:219513098-219513098 
|rs1537818	|1:39647038-39647038	|1:39181366-39181366 
|rs147325890	|2:208939268-208939272	|2:208074544-208074548 
|rs9826367	|3:12294202-12294202	|3:12252703-12252703 
|rs114961124	|5:162935998-162935998	|5:163508992-163508992 
|rs115018790	|5:52088271-52088271	|5:52792437-52792437 
|rs140453320	|5:64485239-64485239	|5:65189412-65189412 
|rs796708168	|6:126689667-126689667	|6:126368521-126368521 
|rs7773338	|6:133100128-133100128	|6:132778989-132778989 
|rs11553430	|6:32136771-32136771	|6:32168994-32168994 
|rs35484705	|6:32583051-32583051	|6:32615274-32615274 
|rs4713572	|6:32626952-32626952	|6:32659175-32659175 
|rs2714337	|6:7240577-7240577	|6:7240344-7240344 
|rs972283	|7:130466854-130466854	|7:130782095-130782095 
|rs143545473	|7:28077270-28077270	|7:28037651-28037651 
|rs138760676	|7:28107505-28107505	|7:28067886-28067886 
|rs755900673	|8:2008956-2008956	|8:2060836-2060836 
|rs11311906	|8:2008956-2008957	|8:2060836-2060837 
|rs139998786	|8:79662469-79662469	|8:78750234-78750234 
|rs12555274	|9:22136440-22136440	|9:22136441-22136441 
|rs75518966	|9:71045124-71045124	|9:68430208-68430208 
|rs7079711	|10:114745788-114745788	|10:112986029-112986029 
|rs74810181	|10:115080503-115080503	|10:113320744-113320744 
|rs33932777	|10:12311465-12311465	|10:12269466-12269466 
|rs12570111	|10:12325058-12325058	|10:12283059-12283059 
|rs7912748	|10:12658743-12658743	|10:12616744-12616744 
|rs2812533	|10:71452285-71452285	|10:69692529-69692529 
|rs4936409	|11:117694392-117694392	|11:117823677-117823677 
|rs757110	|11:17418477-17418477	|11:17396930-17396930 
|rs231903	|11:2729946-2729946	|11:2708716-2708716 
|rs150078842	|11:72818294-72818294	|11:73107249-73107249 
|rs2577960	|15:42028354-42028354	|15:41736156-41736156 
|rs9929462	|16:294210-294210	|16:244211-244211 
|rs35944094	|17:17400635-17400635	|17:17497321-17497321 
|rs3094515	|17:36043653-36043653	|17:37683650-37683650 
|rs35226705	|19:46301456-46301456	|19:45798198-45798198


_Requested but **not** included_ because these SNPs did not pass QC for analysis in FinnGen 

| rsID | SNP ID (hg19) | SNP ID (hg38) |
|------|--------------| --------------|
|rs147325890|	2:208939268-208939272	|2:208074544-208074548
|rs9826367	|3:12294202-12294202	|3:12252703-12252703
|rs796708168|	6:126689667-126689667	|6:126368521-126368521
|rs4713572	|6:32626952-32626952	|6:32659175-32659175
|rs150078842	|11:72818294-72818294	|11:73107249-73107249


# Usage
### Create Docker image
```
docker build -t gcr.io/finngen-refinery-dev/kv-snptest:0.1 -f docker/Dockerfile .
docker -- push gcr.io/finngen-refinery-dev/kv-snptest:0.1
```

### Edit the .json file
Note where all the files that you need to run are located.

#### Pick a transmission to analyze  
Most importantly, pick a transmission that you want to be analysed, particularly in line 19
    ```
    "snptest.test_combine.test.option": 2,
    ```
where, 

    `1`=Additive, `2`=Dominant, `3`=Recessive, `4`=General, and 5=Heterozygote

### What is being run?

#### STEP 1: Cleaning the phenotype file and sample selection
In `FG-snptest_1.R`, it is controlled by `snptest.wdl` to:

1) job is split up 1 job per phenotype
2) each phenotype is loaded in from the covariate file
3) [maximally independent phenotype](https://github.com/FINNGEN/maximally-independent-phenotypes) sample selection
4) filter for controls who are less than 55 years old
5) write out per phenotype file of samples for the next step which is per chromosome analysis

To note about the maximally independent phenotype script:

Owner: Pietro

What the pipeline [does](https://github.com/FINNGEN/FG-recessive-analysis):

* a network is built from the related couples passed
* samples are removes from the --rejected files passed
* two methods are run to return a list of unrelated samples maximixing cases. the "bridge" algorithm chops all nodes with degree > 12 (harcoded) . then it returns the cases left and removes all the controls nodes that connect them. in this way we "split" the cases and control network, burning only controls in the process. the algorithm then continues removing high degree nodes in each subgraph left until no nodes are present in the network the second mode is native to networx nx.maximal_independent_set. first the cases graph is produced and the maximal independent set is returned. then the global independent set is procuded starting from the cases independent set
the method that procudes the larger number of cases is chosen
* a list of samples to remove is output and saved to file

#### STEP 2: Running SNPTEST
In `FG-snptest_2.R`, it is controlled by `snptest_sub.wdl`. The `sub` script needs to be zipped prior to submission because `cromwell` doesn't allow for nested `scatter` functions. This script is run for:

1) job is split up 1 job per `bgen` file chunk
2) takes in the output from `STEP 1` above.
3) filters the `bgen` chunk file for SNPs that we are testing for using [plink2](https://www.cog-genomics.org/plink/2.0/)
4a) _if that chunk **doesn't** contain any of the tested SNPs_, ends the run immediately 
4b) _if that chunk **does** contain any of the tested SNPs_, continues running SNPTEST
5) spits out the output file using the prefix that we set in the R file
6) combines the files by chromosomes
