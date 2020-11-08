#!/bin/bash

############
# Usage: ./run_hipstr.sh <s3://paramsfile.sh> <outprefix> <sraids>

# Params file must have:
# REFFA: s3 path to ref genome
# HIPREF: s3 path to hipstr regions file (.gz)
# FILETYPES: string to use for -f for fusera mount. e.g. "cram,crai"
# OUTBUCKET: s3 bucket to put results in
# NGCFILE: s3 path to dbgap .ngc file
# HIPPARAMS: any extra params to hipstr
############

PARAMSFILE=$1
OUTPREFIX=$2
SRAIDS=$3

die()
{
    BASE=$(basename "$0")
    echo "$BASE error: $1" >&2
    exit 1
}

##############
# Set up and download necessary files
DATADIR=/data
RESULTSDIR=/results
mkdir -p ${DATADIR}/${OUTPREFIX} || die "Could not make directory ${DATADIR}/${OUTPREFIX}"
mkdir -p ${RESULTSDIR}/${OUTPREFIX} || die "Could not make directory ${RESULTSDIR}/${OUTPREFIX}"

# Load params
aws s3 cp $PARAMSFILE ${DATADIR}/${OUTPREFIX}/params.sh || die "Could not download params file $PARAMSFILE"
source ${DATADIR}/${OUTPREFIX}/params.sh || die "Could not load params"

# Copy files we need
aws s3 cp $REFFA ${DATADIR}/${OUTPREFIX}/ref.fa || die "Could not download $REFFA"
samtools faidx ${DATADIR}/${OUTPREFIX}/ref.fa || die "Could not index ref fasta"
aws s3 cp $HIPREF ${DATADIR}/${OUTPREFIX}/hipref.bed.gz || die "Could not download HipSTR ref"
gunzip ${DATADIR}/${OUTPREFIX}/hipref.bed.gz || die "Could not unzip ${DATADIR}/${OUTPREFIX}/hipref.bed.gz"
aws s3 cp $NGCFILE ${DATADIR}/${OUTPREFIX}/dbgap.ngc || die "Could not download dbgap key"

##############
# Mount SRA data
mkdir -p ${DATADIR}/${OUTPREFIX}/fusera || die "Could not make directory ${DATADIR}/${OUTPREFIX}/fusera"
fusera mount \
    -a ${SRAIDS} \
    --token ${DATADIR}/${OUTPREFIX}/dbgap.ngc \
    -f ${FILETYPES} \
    ${DATADIR}/${OUTPREFIX}/fusera & || die "Could not start fusera"

# Get list of bam files
BAMFILES=""
for sra in $(echo $SRAIDS | sed 's/,/ /g')
do
    bamfile=$(ls ${DATADIR}/${OUTPREFIX}/fusera/${sra}/ | grep ".bam$\|.cram$")
    BAMFILES="${BAMFILES},${DATADIR}/${OUTPREFIX}/fusera/${sra}/${bamfile}"
done
BAMFILES=$(echo $BAMFILES | sed 's/^,//')

echo "Running on ${BAMFILES}"

##############
# Run HipSTR
HipSTR \
    --bams ${BAMFILES} \
    --fasta ${DATADIR}/${OUTPREFIX}/ref.fa \
    --regions ${DATADIR}/${OUTPREFIX}/hipref.bed \
    --str-vcf ${RESULTSDIR}/${OUTPREFIX}/${OUTPREFIX}.vcf.gz ${HIPPARAMS} 2> /dev/null || die "Error running HipSTR"

##############
# Upload output to s3
aws s3 cp ${RESULTSDIR}/${OUTPREFIX}/${OUTPREFIX}.vcf.gz ${OUTBUCKET}/${OUTPREFIX}.vcf.gz || die "Error uploading results"



