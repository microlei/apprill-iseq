# Input: seqtab (seqtab_withchimeras.rds)
# Output: seqtab (seqtab_nochimeras.rds)

sink(snakemake@log[[1]])

cat("Beginning output of removing chimeras \n")
library(dada2)

seqtab <- readRDS(file=snakemake@input[['seqtab']])

seqtab.nochim <- removeBimeraDenovo(seqtab, method=snakemake@config[['method']], multithread=TRUE, verbose=TRUE)

cat("Dimensions after removing chimeras: \n")
dim(seqtab.nochim)
cat("Proportion of original: \n")
sum(seqtab.nochim)/sum(seqtab)

saveRDS(seqtab.nochim, file=snakemake@output[['seqtab']])
