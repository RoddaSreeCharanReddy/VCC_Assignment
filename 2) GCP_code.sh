#!/bin/bash

REGION="asia-south1"
INSTANCE_TEMPLATE="monitoring-template"
MIG_NAME="monitoring-mig"

gcloud compute instance-templates create $INSTANCE_TEMPLATE \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-size=20GB \
  --tags=http-server \
  --metadata=startup-script='#! /bin/bash
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    docker run -d --name prometheus --network host prom/prometheus
    docker run -d --name grafana --network host grafana/grafana'

gcloud compute instance-groups managed create $MIG_NAME \
  --base-instance-name monitoring-instance \
  --template $INSTANCE_TEMPLATE \
  --size 1 \
  --region $REGION \
  --update-policy-type=proactive

gcloud compute instance-groups managed set-autoscaling $MIG_NAME \
  --max-num-replicas 5 \
  --target-cpu-utilization 0.75 \
  --region $REGION \
  --cool-down-period 90

echo "GCP Auto-scaling setup complete!"
