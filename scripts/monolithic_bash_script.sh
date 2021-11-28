#!/bin/bash
#SBATCH --job-name analysis
#SBATCH --mem 1G
#SBATCH --ntasks 1 --cpus-per-task 1
#SBATCH --time 00:10:00

# Use a conda software environment for this script
source "${MINICONDA_DIR}/miniconda3/etc/profile.d/conda.sh"
conda activate \
  mbs2smk

# Define an array of samples to process
#####
SAMPLES=(
  "ACBarrie"
  "Alsen"
  "Baxter"
  "Chara"
  "Drysdale"
)

# Index reference genome
#####
bwa index -a bwtsw references/reference.fasta.gz

for SAMPLE in "${SAMPLES[@]}"; do
  # FastQC the raw reads
  #####
  fastqc --threads 1 \
    "raw_reads/${SAMPLE}_R1.fastq.gz" \
    "raw_reads/${SAMPLE}_R2.fastq.gz"

  # Adapter/quality trim raw reads
  #####
  mkdir -p qc_reads
  fastp \
    --thread 1 \
    --in1 "raw_reads/${SAMPLE}_R1.fastq.gz" \
    --in2 "raw_reads/${SAMPLE}_R2.fastq.gz" \
    --out1 "qc_reads/${SAMPLE}_R1.fastq.gz" \
    --out2 "qc_reads/${SAMPLE}_R2.fastq.gz" \
    --unpaired1 "qc_reads/${SAMPLE}_R1.unpaired.fastq.gz" \
    --unpaired2 "qc_reads/${SAMPLE}_R2.unpaired.fastq.gz" \
    --html "qc_reads/${SAMPLE}_fastp.html" \
    --json "qc_reads/${SAMPLE}_fastp.json"

  # Map QC'd reads to the reference genome
  #####
  mkdir -p mapped
  bwa mem -t 1 \
    references/reference.fasta.gz \
    "qc_reads/${SAMPLE}_R1.fastq.gz qc_reads/${SAMPLE}_R2.fastq.gz" \
  | samtools view -b \
  > "mapped/${SAMPLE}.bam"
done

# Aggregate FastQC results from raw reads
#####
mkdir -p reports
multiqc --force \
  --filename reports/raw_reads_multiqc.html \
  raw_reads/*_R?_fastqc.zip
