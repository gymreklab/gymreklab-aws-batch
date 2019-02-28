#!/bin/bash

# BAMURL=ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR195/ERR1955393/e807d440-bd7c-4fbf-87cf-fd7dab0c11c7.bam
# ACC=ERR1955393
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

DATADIR=/data # This is where we have all the EBS storage space mounted
CHROM=22 # Test on this chrom

### First, download data files needed for GangSTR
mkdir -p ${DATADIR}/datafiles
mkdir -p ${DATADIR}/results

# Ref genome
wget -O ${DATADIR}/datafiles/hs37d5.fa.gz ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz || die "Could not download hs37 ref"
gunzip ${DATADIR}/datafiles/hs37d5.fa.gz #|| die "Could not unzip" file was corrupted so gzip gives non-zero error...
samtools faidx ${DATADIR}/datafiles/hs37d5.fa || die "Could not index reference fasta"

# GangSTR reference regions
aws s3 cp s3://gangstr/hs37_ver13.bed.gz ${DATADIR}/datafiles/hs37_ver13.bed.gz || die "Error copying GangSTR ref"
gunzip -f ${DATADIR}/datafiles/hs37_ver13.bed.gz || die "Could not unzip GangSTR ref"
cat ${DATADIR}/datafiles/hs37_ver13.bed | awk -v"chrom=$CHROM" '($1==chrom)' > \
    ${DATADIR}/datafiles/hs37_ver13.chrom${CHROM}.bed || die "Could not subset ref"

# ENA BAM file and index (When doing for real, use ascp or S3 if possible)
samtools view -bS ${BAMURL} ${CHROM} > ${DATADIR}/datafiles/${ACC}.bam || die "Could not fetch bam region"
samtools index ${DATADIR}/datafiles/${ACC}.bam || die "Could not index bam"

### Second, run GangSTR+DumpSTR
GangSTR \
    --bam ${DATADIR}/datafiles/${ACC}.bam \
    --regions ${DATADIR}/datafiles/hs37_ver13.chrom${CHROM}.bed \
    --ref ${DATADIR}/datafiles/hs37d5.fa \
    --out ${DATADIR}/results/${ACC} \
    --chrom ${CHROM} || die "Error running GangSTR"
bgzip ${DATADIR}/results/${ACC}.vcf || die "Error zipping GangSTR output"
tabix -p vcf ${DATADIR}/results/${ACC}.vcf.gz || die "Error indexing GangSTR output"

dumpSTR \
    --vcf ${DATADIR}/results/${ACC}.vcf.gz \
    --filter-spanbound-only \
    --filter-badCI \
    --max-call-DP 1000 \
    --filter-regions /STRTools/dumpSTR/filter_files/hs37_segmentalduplications.bed.gz \
    --filter-regions-names SEGDUP \
    --out ${DATADIR}/results/${ACC}.filtered || die "Error running DumpSTR"
bgzip ${DATADIR}/results/${ACC}.filtered.vcf || die "Error zipping DumpSTR output"
tabix -p vcf ${DATADIR}/results/${ACC}.filtered.vcf.gz || die "Error indexing DumpSTR output"

### Third, upload results to S3
aws s3 cp ${DATADIR}/results/${ACC}.filtered.vcf.gz s3://gymreklab-awsbatch/ || die "Error uploading VCF"
aws s3 cp ${DATADIR}/results/${ACC}.filtered.loclog.tab s3://gymreklab-awsbatch/ || die "Error uploading loclog"
aws s3 cp ${DATADIR}/results/${ACC}.filtered.samplog.tab s3://gymreklab-awsbatch/ || die "Error uploading samplog"

