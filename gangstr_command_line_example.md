This tutorial goes through running a single GangSTR job on AWS. Unlike last time, we'll be doing this mostly from the command line.

The major steps are:
* Set up the compute environment (This has already been done and only needs to be done once. But the steps are included below for your reference and if you need to change something. For instance, you may want to change the instance type or EBS storage space available)
* Create a job script
* Run the job

## Set up (already done)

### Create a custom AMI with extra storage
See aws-batch-500-encrypt-v2 ami-0b8c040a668af5e3e
See https://aws.amazon.com/blogs/compute/building-high-throughput-genomic-batch-workflows-on-aws-batch-layer-part-3-of-4/ for instructions on making a custom AMI.

### Create batch compute environment and queue, register job definition
```
aws batch create-compute-environment \
    --compute-environment-name gangstr-single-core-500GB-v6 \
    --type MANAGED \
    --state ENABLED \
    --compute-resources file://gangstr-single-core-500GB.json \
    --service-role arn:aws:iam::369425333806:role/service-role/AWSBatchServiceRole
```

```
aws batch create-job-queue \
    --job-queue-name gangstr-single-core-500GB-v6 \
    --state ENABLED \
    --priority 100 \
    --compute-environment-order order=1,computeEnvironment=gangstr-single-core-500GB-v6
```

```
aws batch register-job-definition \
    --job-definition-name str-toolkit-run \
    --type container \
    --container-properties file://strtoolkit-container-properties.json
```

## Create a job script

We will create a script that takes as input an ENA accession and (1) fetches the BAM file for the genome, (2) runs GangSTR and dumpSTR, and (3) uploads the results to S3. Note for testing, the script only analyzes a small genomic region. For your real job, you'll need to change this.

An example script is provided in: `run_gangstr_ena_test.sh`. This has been uploaded to [s3://gymreklab-awsbatch/run_gangstr_ena_test.sh](s3://gymreklab-awsbatch/run_gangstr_ena_test.sh)

## Test the script locally on Docker

```
BAMURL=ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR195/ERR1955393/e807d440-bd7c-4fbf-87cf-fd7dab0c11c7.bam 
ACC=ERR1955393
AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials  | grep id | cut -f 2 -d '=' | head -n 1 | cut -f 2 -d' ')
AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials  | grep secret | cut -f 2 -d '=' | head -n 1 | cut -f 2 -d' ')
docker run \
       -v /storage/mgymrek/del:/scratch \
       --env BATCH_FILE_TYPE="script" \
       --env BATCH_FILE_S3_URL="s3://gymreklab-awsbatch/run_gangstr_ena_test.sh" \
       --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
       --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
       -it gymreklab/str-toolkit-run run_gangstr_ena_test.sh $BAMURL $ACC
```

## Run the job on the queue we created

```
BAMURL=ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR195/ERR1955393/e807d440-bd7c-4fbf-87cf-fd7dab0c11c7.bam 
ACC=ERR1955393
aws batch submit-job \
    --job-name test-ENA-${ACC} \
    --job-queue gangstr-single-core-500GB-v6 \
    --job-definition str-toolkit-run:11 \
    --container-overrides 'command=["run_gangstr_ena_test.sh",'"${BAMURL}"','"${ACC}"'],environment=[{name="BATCH_FILE_TYPE",value="script"},{name="BATCH_FILE_S3_URL",value="s3://gymreklab-awsbatch/run_gangstr_ena_test.sh"}]'

```
