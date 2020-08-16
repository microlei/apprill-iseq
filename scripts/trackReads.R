# Inputs: outF, dadaFs, seqtab_nochim
# Outputs: track ("output/track_reads.csv")

sink(snakemake@log[[1]])
cat("Beginning output of tracking reads \n")

outF <- readRDS(file=snakemake@input[['outF']])
cat("outF: \n")
head(outF)
dadaFs <- readRDS(file=snakemake@input[['dadaFs']])
cat("dadaFs: \n")
head(dadaFs)
seqtab.nochim <- readRDS(file=snakemake@input[['seqtab_nochim']])
cat("seqtab.nochim\n")
head(seqtab.nochim)

getN <- function(x) sum(getUniques(x))
#need to use leftjoin from tidyverse here in case samples got dropped
track <- cbind(outF, sapply(dadaFs, getN), rowSums(seqtab.nochim))
colnames(track) <- c("raw", "filtered", "denoised", "nochim")
rownames(track) <- snakemake@params[['samples']]

write.csv(track, file=snakemake@output[['track']])
