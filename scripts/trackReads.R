# Inputs: outF, dadaFs, seqtab_nochim
# Outputs: track ("output/track_reads.csv")

sink(snakemake@log[[1]])
cat("Beginning output of tracking reads \n")
library(dada2)

load(file=snakemake@input[['outF']])
cat("outF: \n")
head(outF)
load(file=snakemake@input[['dadaFs']])
cat("dadaFs: \n")
head(dadaFs)
load(file=snakemake@input[['seqtab_nochim']]) #note this object is names seqtab.nochim
cat("seqtab.nochim\n")
head(seqtab.nochim)

getN <- function(x) sum(getUniques(x))
track <- cbind(outF, sapply(dadaFs, getN), rowSums(seqtab.nochim))
colnames(track) <- c("raw", "filtered", "denoised", "nochim")
rownames(track) <- snakemake@params[['samples']]

write.csv(track, file=snakemake@output[['track']])
