# Snakemake workflow for Illumina iSeq 16S V4 processing using dada2

This is the workflow for the analysis and will describe what it does, how it does it, and what needs to be changed in order for you to run your own sequences using it. 

## Step 0 create your environment
Create your conda environment to have snakemake and dada2

I created an environment with snakemake using
```
conda create -c conda-forge -c bioconda -n snakemakedada snakemake
```
Check the version numbers of your software using 
```
R --version
snakemake --version
python --version
```
I had to update to the latest versions of R and snakemake
```
conda update R
conda update snakemake
```
Then, enter R and install dada2. This will take a while.
```
$ R
>> if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

>> BiocManager::install("dada2")
```

Then, any time you start up poseidon (WHOI's HPC), you must use the following commands to enter the snakemake environment:
```
module load anaconda/5.1
source activate snakemakedada #or whatever you named your environment
```

## Step 1 make sure your files are in place
By default, this workflow assumes your files are in your scratch project directory and that each sequencing run is under its own folder named Run# and each fastq.gz file named some 3 letter acronym_sample# (e.g. STT_1_junk_R1_001.fastq.gz). If this is not the case, you can edit the config file and the heading of the Snakefile to properly direct the workflow to your files. A helpful way to check your input values is to start python, load snakemake, and check what you're using for wildcards.

```
python
from snakemake.io import *
##mess with wildcards here##
```

## Step 2 configure the workflow
config.yaml: contains the global parameters that you may want to change, such as paths, dada2 function parameters and others. Some parameters you may edit after seeing results from running the makefile once, such as the trimming parameters after seeing the quality profiles

cluster.json: a json file that contains the parameters for submitting jobs to the cluster, such as memory and task allocation. You may want to edit the memory allocation if you find that your runs are terminating due to memory issues (check your slurm output). 

Snakefile: this is the snakefile that will run the whole workflow. Before running, check that the wildcards globbing is picking up all of your files (and no extra files!) correctly. Currently, this workflow is configured to only use the forward reads, R1, but with a couple of extra rules and scripts can be repurposed for handing both forward and reverse.  

## Step 3 running the pipeline on the cluster
To run snakemake on the cluster, I used the following command:
```
snakemake -j 100 --cluster-config cluster.json --cluster "sbatch --mem={cluster.mem} -t {cluster.time} -n {cluster.ntasks} -J {cluster.job-name} -o {cluster.output}"
```
-j: specifies number of jobs (max) that snakemake will submit to the cluster

--cluster: calls slurm with sbatch and names all the parameters you would normally put in your bash header. Note that this entire command must be in quotes!

## Step 4 iterate on parameters
Edit your config.yaml to change the parameters for your dada2 functions as you proceed with your analysis

