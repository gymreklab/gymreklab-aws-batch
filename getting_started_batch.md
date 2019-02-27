
The general steps described below are:

1. Build a docker image with all the required software for each job
2. Putting the image in Docker hub
3. Creating a job script
4. Create a batch setup (compute environment, queue, and job definition) and run!

## Prereqs

You need to create an initial job queue here: http://docs.aws.amazon.com/batch/latest/userguide/Batch_GetStarted.html
You'll need to have installed: docker, aws (these should be on snorlax already)
You should have an AWS account configured on snorlax and ideally a docker hub account.

## Step 1: Build a docker image with required software

The example Dockerfile in this repo installs GangSTR and the `fetch_and_run.sh` script that our Batch job will use. This script will simply fetch a job and run it. To build the docker, run (from this directory):

```
docker build -t awsbatch/gangstr_example .
```

## Step 2: Put the docker image in Docker hub

I have linked this github example to mgymrek/gangstr_example on dockerhub
https://hub.docker.com/r/mgymrek/gangstr_example
It automatically builds from the dockerfile
You can also push your own copy to your own Dockerhub account

## Step 3: Create a simple job script and upload to S3

We'll use the example test job (which just prints out some stuff) `myjob.sh` in this repository.
We can modify later to make this more complicated

Now upload this job to s3

```
aws s3 cp myjob.sh s3://gymreklab-awsbatch/myjob.sh # Note you don't need to run this, it's already there
```

We can actually test out an example job before submitting to AWS. Note if we're running this outside of AWS we'll have to set the environment variables for our AWS credentials. Try:

```
docker run \
       --env BATCH_FILE_TYPE="script" \
       --env BATCH_FILE_S3_URL="s3://gymreklab-awsbatch/myjob.sh" \
       --env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
       --env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
       awsbatch/gangstr_example myjob.sh 60
```

## Step 4a: Submit a job from the console

Now we need to set up a compute environment, job queue and job definition at: https://console.aws.amazon.com/batch

Compute environment:
* Managed
* Name: gangstr-example
* AWSBatchServiceRole
* ecsInstanceRole
* micro_key
* On-Demand (for the real deal we'll use Spot, much cheaper)
* m4.large instance type (for the real deal, we'll need to modify based on our needs)
* Later we'll need to set launch template to add space

Job Queue: 
* Name: gangstr-example
* Compute environment: gangstr-example

Job definition:
* Name: gangstr-example
* batchJobRole
* container image: mgymrek/gangstr_example:latest

Submit job
* Name: gangstr-example
* Command: myjob.sh,60
* env variables
Key=BATCH_FILE_TYPE, Value=script
Key=BATCH_FILE_S3_URL, Value=s3:///myjob.sh. Don’t forget to use the correct URL for your file.

## Step 4b: submit a job from the command line
```
aws batch submit-job \
    --job-name test-mgymrek \
    --job-queue gangstr-example \
    --job-definition gangstr-example \
    --container-overrides 'command=["myjob.sh",60],environment=[{name="BATCH_FILE_TYPE",value="script"},{name="BATCH_FILE_S3_URL",value="s3://gymreklab-awsbatch/myjob.sh"}]'

```


# Coming next:

* Command line job submission
* Configuring an instance to have enough space
* Example actually running GangSTR