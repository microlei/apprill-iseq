#configurations for running the code
#Anything you would normally "hardcode" like paths, variables for the dada2 pipeline, etc go here
configfile: "config.yaml" 

#Gets sample names of forward reads
WC = glob_wildcards(config['path']+"{run}/{names, ([A-Z]{3}_[^_]+)}{other}{dir, R1_001}.fastq.gz")
#makes the sample names + run number in case of duplicate samples across runs
SAMPLES = expand("{names}_{run}", zip, names=WC.names, run=WC.run)
#if there are no duplicate names across runs, use this instead
#SAMPLES = WC.names
#paths to the fastq files, specifically the R1
RAW = expand(config['path']+'{run}/{names}.fastq.gz', zip, run=WC.run, names=[i + j + k for i, j, k in zip(WC.names, WC.other, WC.dir)])

#local rules marks a rule as local and does not need to be submitted as a job to the cluster
localrules: all, plotQP, trackReads, learnError

#this rule specifies all things you want generated
rule all:
	input:
		"output/filtered.rds",
		"output/errorRates_R1.rds",
		"output/figures/errorRates_R1.pdf",
		"output/seqtab_withchimeras.rds",
		"output/seqtab_nochimeras.rds",
		"output/track_reads.csv",
		"output/ASVs.txt",
		"output/taxonomy.txt",
		"output/ASVseqs.txt"

#clears all outputs (except for plotted quality profiles)
rule clean:
    shell:
        '''
        rm output/*.rds
        rm output/*.txt
        rm output/*.csv
	rm logs/*
        '''

#plots quality profiles
rule plotQP:
	input: RAW
	output: expand('output/figures/qualityProfiles/{direction}/{sample}_{direction}_qual.jpg',sample=SAMPLES, direction = 'R1')
	script: 'scripts/plotQP.R'

#quality filters R1 and R2 (forward and reverse reads)
rule filter:
	input:
		R1 = RAW
	output:
		R1 = expand(config['path']+"filtered/{sample}_R1.fastq.gz", sample=SAMPLES), 
		filtered = "output/filtered.rds"
	params:
		samples = SAMPLES
	log:
		"logs/filter.txt" #I always have the logs go to one place so I can easily see what went wrong
	script:
		"scripts/filter.R"

#error modeling and plotting the errors
rule learnError:
	input:
		R1 = rules.filter.output.R1 #note you can declare the output of another rule as a dependency
	output:
		errR1 = "output/errorRates_R1.rds",
		plotErrR1 = "output/figures/errorRates_R1.pdf", #need to figure out how to save variable number of pdfs
	log:
		"logs/learnError.txt"
	script:
		"scripts/learnError.R"

#this is where we would demux and denoise if we were doing both F and R, but for now we're just getting uniques from R1
rule uniques:
	input:
		R1 = rules.filter.output.R1,
		errR1 = rules.learnError.output.errR1
	output:
		seqtab = "output/seqtab_withchimeras.rds",
		uniques = "output/dadaFs.rds"
	log:
		"logs/uniques.txt"
	script:
		"scripts/uniques.R"

#this is where the chimeras get removed
rule removeChimeras:
	input:
		seqtab = rules.uniques.output.seqtab,
	output:
		seqtab = "output/seqtab_nochimeras.rds",
	log:
		"logs/removeChimeras.txt"
	script:
		"scripts/removeChimeras.R"

#this is where the results are tracked
#I moved it into its own script in case I wanted to format it differently
rule trackReads:
	input:
		outF = rules.filter.output.filtered,
		dadaFs = rules.uniques.output.uniques,
		seqtab_nochim = rules.removeChimeras.output.seqtab
	output:
		track = "output/track_reads.csv"
		
	params:
		samples = SAMPLES
	log:
		"logs/trackReads.txt"
	script:
		"scripts/trackReads.R"

#this is where the taxonomy is assigned
rule taxonomy:
	input:
		seqtab = rules.removeChimeras.output.seqtab,
	output:
		otus = "output/ASVs.txt",
		taxonomy = "output/taxonomy.txt",
		ASVseqs = "output/ASVseqs.txt"
	params:
		samples = SAMPLES
	log:
		"logs/taxonomy.txt"
	script:
		"scripts/taxonomy.R"




