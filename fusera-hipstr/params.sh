# Testing params. don't upload to github

REFFA=s3://broad-references/hg19/v0/Homo_sapiens_assembly19.fasta
HIPREF=https://github.com/HipSTR-Tool/HipSTR-references/raw/master/human/GRCh37.hipstr_reference.bed.gz
FILETYPES="bam,bai"
OUTBUCKET=s3://scz-denovos/test/
NGCFILE=s3://scz-denovos/test/dummy.ngc # store once we have permission
HIPPARAMS="--min-reads 10 --def-stutter-model --output-gls"

