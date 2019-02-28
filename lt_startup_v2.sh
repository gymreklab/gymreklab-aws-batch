MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
sleep 200

# Format /dev/xvdcz and mount
mkfs -t xfs /dev/xvdcz
mkdir -p /data
mount /dev/xvdcz /data

chmod -R 777 /data

# Persist the volume in /etc/fstab so it gets mounted again
echo '/dev/xvdcz /data xfs defaults,nofail 0 2' >> /etc/fstab

--==MYBOUNDARY==--
