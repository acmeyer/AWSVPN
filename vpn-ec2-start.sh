#!/bin/bash -x
#to be run on my laptop


# create and start an instance
#AMI = AMZN Linux 64 Bits
#EBS backed US-east: ami-1ccae774

AMI_ID=ami-5ccae734 #US-east instance store
KEY_ID=PEM_FILE_NAME
SEC_ID=SECURITY_GROUP_NAME
BOOTSTRAP_SCRIPT=vpn-ec2-install.sh

echo "Starting Instance..."
INSTANCE_DETAILS=`aws ec2 run-instances --image-id $AMI_ID --key-name $KEY_ID --security-groups $SEC_ID --instance-type t1.micro --user-data file://./$BOOTSTRAP_SCRIPT --output text | grep INSTANCES`

INSTANCE_ID=`echo $INSTANCE_DETAILS | awk '{print $8}'`
echo $INSTANCE_ID > $HOME/vpn-ec2.id

# wait for instance to be started
STATUS=`aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --output text | grep INSTANCESTATUS | grep -v INSTANCESTATUSES | awk '{print $2}'`

while [ "$STATUS" != "ok" ]
do
    echo "Waiting for instance to start...."
    sleep 5
    STATUS=`aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --output text | grep INSTANCESTATUS | grep -v INSTANCESTATUSES | awk '{print $2}'`
done

echo "Instance started"

echo "Instance ID = " $INSTANCE_ID
DNS_NAME=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text | grep INSTANCES | awk '{print $15}'`
AVAILABILITY_ZONE=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text | grep PLACEMENT | awk '{print $2}'`
echo "DNS = " $DNS_NAME " in availability zone " $AVAILABILITY_ZONE
