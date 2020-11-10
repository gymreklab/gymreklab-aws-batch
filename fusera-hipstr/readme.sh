#!/bin/bash

# Build docker
docker build -t mgymrek/fusera-hipstr .
docker push mgymrek/fusera-hipstr

# Upload job and params to S3
aws s3 --profile dp5 cp run_hipstr.sh s3://scz-denovos/test/run_hipstr.sh
aws s3 --profile dp5 cp params.sh s3://scz-denovos/test/params.sh
aws s3 --profile dp5 cp dummy.ngc s3://scz-denovos/test/dummy.ngc

# Test job from docker locally
AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep -A 2 dp5 | grep "_secret_" | cut -f 2 -d '=' | sed 's/^ //')
AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials | grep -A 2 dp5 | grep "_id" | cut -f 2 -d '=' | sed 's/^ //')
docker run \
    --env BATCH_FILE_TYPE="script" \
    --env BATCH_FILE_S3_URL="s3://scz-denovos/test/run_hipstr.sh" \
    --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    mgymrek/fusera-hipstr \
    run_hipstr.sh s3://scz-denovos/test/params.sh test xxx,yyy

