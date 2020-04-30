# STT2020

## Snakemake workflow

This is the workflow for the analysis

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

## Step 1 make necessary files
sampletable.csv: This workflow requires a csv file with three columns: 'sample', 'R1', 'R2', where sample is the sample names, and R1 and R2 are the paths to the forward and reverse reads, respectively. 

## Step 2 configure the workflow
config.yaml: contains the global parameters that you may want to change, such as paths, dada2 function parameters and others. Some parameters you may edit after seeing results from running the makefile once, such as the trimming parameters after seeing the quality profiles

cluster.json: a json file that contains the parameters for submitting jobs to the cluster, such as memory and task allocation. You may want to edit this individually for each rule, at least to edit the names of the slurm output files. 

## Step 3 running the pipeline on the cluster
To run snakemake on the cluster, I used the following command:
```
snakemake -j 100 --cluster-config cluster.json --cluster "sbatch --mem={cluster.mem} -t {cluster.time} -n {cluster.ntasks} -J {cluster.job-name} -o {cluster.output}"
```
-j: specifies number of jobs (max) that snakemake will submit to the cluster

--cluster: calls slurm with sbatch and names all the parameters you would normally put in your bash header. Note that this entire command must be in quotes!

## Step 4 iterate on parameters
Edit your config.yaml to change the parameters for your dada2 functions as needed

