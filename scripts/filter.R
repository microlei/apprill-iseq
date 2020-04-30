# Inputs: R1 (list of file paths to raw R1 data), R2 (list of file paths to raw R2 data)
# Outputs: R1 and R2 (config['path']/filtered/{samples}_{R1,R2}.fastq.gz), filtered = "stats/filtered.rds" (outF as a rds)
# Params: samples (list of sample names)

sink(snakemake@log[[1]]) # starts the log

cat("Beginning of output for filter.R \n")
library(dada2) # load dada2

outF <- filterAndTrim(fwd = snakemake@input[['R1']], filt = snakemake@output[['R1']],
		rev = snakemake@input[['R2']], filt.rev = snakemake@output[['R2']],
		trimLeft = snakemake@config[['trimLeft']],
		truncLen = snakemake@config[['truncLen']],
		maxN = snakemake@config[['maxN']],
		maxEE = snakemake@config[['maxEE']],
		rm.phix = TRUE,
		compress = TRUE,
		multithread = snakemake@config[['multithread']],
		verbose = TRUE)
row.names(outF) <- snakemake@params[['samples']]
print(outF)

save(outF, file=snakemake@output[['filtered']])		
