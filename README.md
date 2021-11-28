


# Snakemake is Like Making Sunday Dinner

The way Snakemake approaches running workflows is a bit like the way you prepare for dinner/tea.
First, you think about what you want for dinner/tea, say a Sunday roast.
To create the Sunday roast, you need meat and vegetables, all of which need preparing (e.g. peeling and seasoning).
If you haven’t got an ingredient, you go out to the shop and buy it.

With Snakemake, you decide what output files you want to create, say some BAM files.
To create the BAM files, you need FASTQ files and a reference genome, all of which need preparing (e.g. quality/adapter trimming and indexing).
If you haven’t got those files, you need to create them.

# Prerequisites

## Miniconda3

```bash
# Setup some convenient system-specific environmental variables
export SNAKEMAKE_WORKSHOP_SHARED_DIR="/group/courses01/amsi/snakemake"
export SNAKEMAKE_WORKSHOP_USER_DIR="/scratch/courses01/amsi/${USER}/snakemake"

# One-time Miniconda3 setup
source "${SNAKEMAKE_WORKSHOP_SHARED_DIR}/miniconda3/etc/profile.d/conda.sh"
conda init bash
. "${HOME}/.bashrc"

# Change the default channels used for finding software and
# resolving dependencies
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# System-specific locations for conda packages and environments
conda config --prepend pkgs_dirs "${SNAKEMAKE_WORKSHOP_USER_DIR}/miniconda3/pkgs"
conda config --prepend envs_dirs "${SNAKEMAKE_WORKSHOP_USER_DIR}/miniconda3/envs"
```

## Installing Snakemake

Once you have conda setup, installing Snakemake is simple.

**However, this can take quite some time to complete.
especially if lots of users are doing this at the same time.
Instead, we'll copy a local conda environment to save time.**

```bash
#####
# Normal installation method
#####
#conda create \
#  --name snakemake \
#  --yes \
#  snakemake=6.11.1

#####
# AMSI Workshop installation method
#####
# Copy the Snakemake conda environment
# TODO - Check ownership/permissions are correct
mkdir --parents "${SNAKEMAKE_WORKSHOP_USER_DIR}/miniconda3/envs/"
rsync --archive --info=progress2 \
  "${SNAKEMAKE_WORKSHOP_SHARED_DIR}/miniconda3/envs/snakemake" \
  "${SNAKEMAKE_WORKSHOP_USER_DIR}/miniconda3/envs/snakemake"
```

# Hello, world! Example

Lets look at how we run Snakemake by taking a look at a Hello, world! example.

Fist, lets get the code:

```bash
cd "${SNAKEMAKE_WORKSHOP_USER_DIR}"
git clone https://github.com/nathanhaigh/snakemake-hello-world
cd snakemake-hello-world
```

We can execute Snakemake and ask it to make the target file `Hello/world.txt`:

```bash
snakemake --cores 1 Hello/world.txt
```

Run the same command, what happens?

```bash
snakemake --cores 1 Hello/world.txt
```

Lets try asking for a couple of target files, but this time doing a dry-run to see what would happen:

```bash
snakemake --cores 1 Hello/world.txt Bonjour/world.txt --dry-run
```

Why is Snakemake only going to run rules to create `Bonjour/world.txt`?
What happend to creating `Hello/world.txt`?

By default, Snakemake runs the first rule defined in the `Snakefile`.
By convention this should be called `all`:

```bash
# This call:
snakemake --cores 2

# Is the same as this one:
snakemake --cores 2 all
```

What difference do you think `--cores 2` had over `--cores 1` we used before?

Now clean up after yourself:

```bash
snakemake --cores 1 --delete-all-output
```

# From Monolithic Bash Script to Snakemake Workflow

Lets first get our data:

```bash
cd "${SNAKEMAKE_WORKSHOP_USER_DIR}"
git clone --recursive https://github.com/sagc-bioinformatics/monolithic_bash_script_to_snakemake
cd monolithic_bash_script_to_snakemake
```

The monolithic bash script ([scripts/monolithic_bash_script.sh]) performs the following tasks:

 1. BWA indexes the reference genome
 2. Loops over 5 samples performing the following tasks:
    1. FastQC of the read pairs
    2. fastp trimming of read pairs
    3. Alignes read pairs to the reference genome using BWA-mem
 3. Aggregates FastQC results

## Step-1

Switch to the `step-1` branch:

```bash
git checkout step-1
```

Create a file called `Snakefile`(capitalisation is important) and write a rule called `bwa_index` for performing the BWA indexing step.
Once complete, you can execute the workflow using something like:

```bash
snakemake --profile profiles/zeus bwa_index
```
