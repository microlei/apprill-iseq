import os #this allows python to read file names and access other aspects of the operating system
import pandas as pd #pandas is a python package that reads and writes data tables

#configurations for running the code
#Anything you would normally "hardcode" like paths, variables for the dada2 pipeline, etc go here
configfile: "config/config.yaml" 

#Reads in the sample table and gets list of sample names
SampleTable = pd.read_table(config['sampletable'], index_col=0, sep=",")
SAMPLES = list(SampleTable.index)

#local rules marks a rule as local and does not need to be submitted as a job to the cluster
localrules: all, all_profile, plotQP, trackReads, learnError

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

#Not sure if this rule is necessary
rule all_profile:
	input: expand("output/figures/qualityProfiles/{direction}/{sample}_{direction}_qual.jpg", direction = ['R1','R2'], sample=SAMPLES)

#plots quality profiles
rule plotQP:
	input: list(SampleTable.R1.values) + list(SampleTable.R2.values)
	output: expand('output/figures/qualityProfiles/{direction}/{sample}_{direction}_qual.jpg',sample=SAMPLES, direction=["R1","R2"])
	script: 'scripts/plotQP.R'

#quality filters R1 and R2 (forward and reverse reads)
rule filter:
	input:
		R1 = SampleTable.R1.values,
		R2 = SampleTable.R2.values
	output:
		R1 = expand(config['path']+"/filtered/{sample}_R1.fastq.gz", sample=SAMPLES), 
		R2 = expand(config['path']+"/filtered/{sample}_R2.fastq.gz", sample=SAMPLES),
		filtered = "output/filtered.rds"
	params:
		samples = SAMPLES
	log:
		"logs/filter.txt" #I always have the logs go to one place so I can easily see what went wrong
	script:
		"scripts/filter.R"

# a function to return the paths to the R1 and R2 of each run
# where the first index is R1 or R2 and the second index is which run

def sampletable(df):
	df2 = df.groupby('Run').apply(lambda x: x['R1filtered'].unique())
	df3 = df.groupby('Run').apply(lambda x: x['R2filtered'].unique())
	r1 = df2.values.tolist()
	r2 = df3.values.tolist()
	return r1,r2

#error modeling and plotting the errors
rule learnError:
	input:
		R1 = sampletable(SampleTable)[0],
		R2 = sampletable(SampleTable)
		#R1 = rules.filter.output.R1 #note you can declare the output of another rule as a dependency
	output:
		errR1 = "output/debug.RData"
		#errR1 = "output/errR1.RData",
		#errR2 = temp("output/errR2.RData")
		#plotErrR1 = "figures/errorRates_R1.pdf", #need to figure out how to save variable number of pdfs
		#plotErrR2 = "figures/errorRates_R2.pdf"
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




