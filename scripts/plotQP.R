## Script to plot all quality profiles in a new folder called qualityProfiles
## run and change the pathname each time

## inputs: list of files
## outputs: qualityProfiles/R1/*_R1_qual.jpg, qualityProfiles/R2/*_R2_qual.jpg

library(dada2)
library(ggplot2)

path = dirname(snakemake@input[[1]])

PQP <- function(x){
	sample.name <- sapply(strsplit(basename(x), "_"), `[`, 1)
	R1_R2 <- sapply(strsplit(basename(x),"_"), `[`, 4)
	imagepath <- file.path(path, "qualityProfiles", R1_R2, paste(sample.name, R1_R2, "qual.jpg", sep="_"))
	jpeg(file=imagepath)
	print(imagepath)
	p <- plotQualityProfile(x)
	plot(p)
	dev.off()
}

lapply(snakemake@input, PQP)
