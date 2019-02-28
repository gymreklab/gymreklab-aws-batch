MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

# See: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html

#EC2_INSTANCE_ID=$(curl -s http://instance-data/latest/meta-data/instance-id)

#yum update -y
#yum install -y awscli

#DATA_STATE="unknown"
#until [ "${!DATA_STATE}" == "attached" ]; do
#    DATA_STATE=$(aws ec2 describe-volumes \
#        --filters \
#        Name=attachment.instance-id,Values=${EC2_INSTANCE_ID} \
#        Name=attachment.device,Values=/dev/xvdcz \
#        --query Volumes[].Attachments[].State \
#        --output text)    
#    sleep 5
#done

sleep 100

# Format /dev/xvdcz and mount
mkfs -t xfs /dev/xvdcz
mkdir -p /data
mount /dev/xvdcz /data

chmod -R 777 /data

# Persist the volume in /etc/fstab so it gets mounted again
echo '/dev/xvdcz /data xfs defaults,nofail 0 2' >> /etc/fstab

--==MYBOUNDARY==--
