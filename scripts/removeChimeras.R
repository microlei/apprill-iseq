# Input: seqtab (seqtab_withchimeras.rds)
# Output: seqtab (seqtab_nochimeras.rds)

sink(snakemake@log[[1]])

cat("Beginning output of removing chimeras \n")
library(dada2)

seqtab <- readRDS(file=snakemake@input[['seqtab']])

#may want to move the method to the config file
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)

cat("Dimensions after removing chimeras: \n")
dim(seqtab.nochim)
cat("Proportion of original: \n")
sum(seqtab.nochim)/sum(seqtab)

save(seqtab.nochim, file=snakemake@output[['seqtab']])
