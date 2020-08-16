## Script to plot all quality profiles in a new folder called qualityProfiles
## run and change the pathname each time

## inputs: list of files
## outputs: qualityProfiles/R1/*_R1_qual.jpg, qualityProfiles/R2/*_R2_qual.jpg

library(dada2)
library(ggplot2)

for(i in 1:length(snakemake@input)){
	jpeg(file=snakemake@output[[i]])
	p <- plotQualityProfile(snakemake@input[[i]])
	plot(p)
	dev.off()
}
