#!/bin/bash

##### Example batch job script to run GangSTR

die()
{
    BASE=$(basename "$0")
    echo "$BASE error: $1" >&2
    exit 1
}

# Step 1: Download data files
git clone https://github.com/gymreklab/mendelian-repeats-pipeline
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr4.fa.gz || die "Could not download chr4"
gunzip chr4.fa.gz || die "Could not unzip chr4"
samtools faidx chr4.fa

# Step 2: Run GangSTR
GangSTR \
    --bam mendelian-repeats-pipeline/examples/test.bam \
    --regions mendelian-repeats-pipeline/examples/test_regions_hg19.bed \
    --ref chr4.fa \
    --out test

# Step 3: Upload to s3 (should really zip these. make sure bgzip installed in the docker)
aws s3 cp test.vcf s3://gymreklab-awsbatch/test.vcf

exit 0
