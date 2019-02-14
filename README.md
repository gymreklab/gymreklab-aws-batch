# gymreklab-aws-batch
Framework for running jobs on AWS batch
Based on https://aws.amazon.com/blogs/compute/creating-a-simple-fetch-and-run-aws-batch-job/

The general steps described below are:

1. Build a docker image with all the required software for each job
2. Putting the image in Docker hub
3. Creating a job script
4. Create a job definition
5. Submit and run the job

## Prereqs

You need to create an initial job queue here: http://docs.aws.amazon.com/batch/latest/userguide/Batch_GetStarted.html
You'll need to have installed: docker, aws (these should be on snorlax already)

## Step 1: Build a docker image with required software

The example Dockerfile in this repo installs GangSTR and the `fetch_and_run.sh` script that our Batch job will use. This script will simply fetch a job and run it. To build the docker, run (from this directory):

```
docker build -t awsbatch/gangstr_example .
```

## Step 2: Put the docker image in Docker hub


## Step 3: Create a simple job script and upload to S3

We'll use the example test job (which just prints out some stuff) `myjob.sh` in this repository. We can modify later to make this more complicated
Now upload this job to s3

```
aws s3 cp myjob.sh s3://gymreklab-awsbatch/myjob.sh # Note you don't need to run this, it's already there
```

## Step 4: Create a job definition

Fill out a new job definition at https://console.aws.amazon.com/batch.

## Step 5: Submit and run the job