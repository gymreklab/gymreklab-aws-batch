#!/bin/bash

BAMURL=$1
ACC=$2

die()
{
    BASE=$(basename "$0")
    echo "$BASE error: $1" >&2
    exit 1
}

usage () {
  if [ "${#@}" -ne 0 ]; then
    echo "* ${*}"
    echo
  fi
  cat <<ENDUSAGE
Usage:
${BASENAME} BAMURL ACC
ENDUSAGE
  exit 2
}

if [ -z "${BAMURL}" ]; then
    usage "BAMURL not given"
fi
if [ -z "${ACC}" ]; then
    usage "ACC not given"
fi

DATADIR=/dev/xvdcz/ # This is where we have all the EBS storage space
CHROM=22 # Test on this chrom

### First, download data files needed for GangSTR
mkdir -p ${DATADIR}/datafiles

# Ref genome
wget -O ${DATADIR}/datafiles/chr${CHROM}.fa.gz http://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr${CHROM}.fa.gz || die "Could not download chr4"
gunzip ${DATADIR}/datafiles/chr${CHROM}.fa.gz || die "Could not unzip chr4"
samtools faidx chr${CHROM}.fa || die "Could not index reference fasta"

# GangSTR reference regions
aws s3 cp s3://gangstr/hg19_ver13.bed.gz ${DATADIR}/datafiles/hg19_ver13.bed.gz || die "Error copying GangSTR ref"
gunzip ${DATADIR}/datafiles/hg19_ver13.bed.gz || die "Could not unzip GangSTR ref"

# ENA BAM file and index (When doing for real, use ascp or S3 if possible)
samtools view -bS ${BAMURL} chr${CHROM} > ${DATADIR}/datafiles/${ACC}.bam
samtools index ${DATADIR}/datafiles/${ACC}.bam

### Second, run GangSTR+DumpSTR
# TODO

### Third, upload results to S3
# TODO
