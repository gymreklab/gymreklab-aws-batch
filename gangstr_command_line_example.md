This tutorial goes through running a single GangSTR job on AWS. Unlike last time, we'll be doing this mostly from the command line.

The major steps are:
* Set up the compute environment (This has already been done and only needs to be done once. But the steps are included below for your reference and if you need to change something. For instance, you may want to change the instance type or EBS storage space available)
* Create a job script
* Run the job

## Set up (already done)

### Upload launch template to add space to our instance
```
aws ec2 create-launch-template --cli-input-json file://lt-data-500.json
```

### Create batch compute environment and queue, register job definition
```
aws batch create-compute-environment \
    --compute-environment-name gangstr-single-core-500GB \
    --type MANAGED \
    --state ENABLED \
    --compute-resources file://gangstr-single-core-500GB.json \
    --service-role arn:aws:iam::369425333806:role/service-role/AWSBatchServiceRole
```

```
aws batch create-job-queue \
    --job-queue-name gangstr-single-core-500GB \
    --state ENABLED \
    --priority 100 \
    --compute-environment-order order=1,computeEnvironment=gangstr-single-core-500GB
```

```
aws batch register-job-definition \
    --job-definition-name str-toolkit-run \
    --type container \
    --container-properties file://strtoolkit-container-properties.json
```

### Test job with dummy myjob.sh
```
aws batch submit-job \
    --job-name test-mgymrek-500GB \
    --job-queue gangstr-single-core-500GB \
    --job-definition str-toolkit-run \
    --container-overrides 'command=["myjob.sh",60],environment=[{name="BATCH_FILE_TYPE",value="script"},{name="BATCH_FILE_S3_URL",value="s3://gymreklab-awsbatch/myjob.sh"}]'
```

## Create a job script

We will create a script that takes as input an ENA accession and (1) fetches the BAM file for the genome, (2) runs GangSTR and dumpSTR, and (3) uploads the results to S3. Note for testing, the script only analyzes a small genomic region. For your real job, you'll need to change this.

An example script is provided in: `run_gangstr_ena_test.sh`. This has been uploaded to [s3://gymreklab-awsbatch/run_gangstr_ena_test.sh](s3://gymreklab-awsbatch/run_gangstr_ena_test.sh)

## Test the script locally on Docker
TODO

## Run the job on the queue we created

```
ACC=TODO
aws batch submit-job \
    --job-name test-ENA-${ACC} \
    --job-queue gangstr-single-core-500GB \
    --job-definition str-toolkit-run \
    --container-overrides 'command=["run_gangstr_ena_test.sh",${ACC}],environment=[{name="BATCH_FILE_TYPE",value="script"},{name="BATCH_FILE_S3_URL",value="s3://gymreklab-awsbatch/run_gangstr_ena_test.sh"}]'

```