#!/bin/bash

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0f3a1afbf0bbc7f0e

for instance in $@
do
	aws ec2 run-instances \
		--image-id "$AMI_ID" \
		--instance-type "t3.micro" \
		--security-group-ids "$SG_ID" \
		--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
	    --query 'Instances[0].InstanceId' \
		--output text
done