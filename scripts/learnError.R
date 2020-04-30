# Input: R1 (filtered forward reads)
# Output: errR1 = "stats/errorRate_R1.rds", plotErrR1 = "figures/errorRate_R1.pdf"

sink(snakemake@log[[1]])

cat("Beginning learning error rates \n")
library(dada2)
library(ggplot2)

#for specifying a set number of bases
#errF <- learnErrors(snakemake@input[['R1']], nbases = snakemake@config[['nbases']], multithread=TRUE, randomize=TRUE)

#for the default option
#errF <- learnErrors(snakemake@input[['R1']],  multithread=TRUE, randomize=TRUE)

save.image(file=snakemake@output[[1]])

#save(errF, file=snakemake@output[['errR1']])
#save(errR, file=snakemake@output[['errR2']])
# plotErrors(errF, nominalQ=TRUE)
# ggsave(snakemake@output[['plotErrR1']])
