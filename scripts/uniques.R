# Inputs: R1 (filtered R1), errR1 (error model for R1)
# Outputs: seqtab ("output/seqtab_withchimeras.rds"), uniques ("output/dadaFs.rds")

sink(snakemake@log[[1]])
library(dada2)

cat("Beginning output for getting uniques \n")

# errR1 is an .rds file so it must be loaded first
load(file=snakemake@input[['errR1']])

dadaFs <- dada(snakemake@input[['R1']], errF, multithread=TRUE)
seqtab <- makeSequenceTable(dadaFs)

cat("Dimensions of sequence table: \n")
dim(seqtab)

cat("Sequences are of length: \n")
table(nchar(getSequences(seqtab)))

save(seqtab, file=snakemake@output[['seqtab']])
save(dadaFs, file=snakemake@output[['uniques']])
