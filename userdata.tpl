#!/bin/bash

sudo yum update -y &&
sudo yum install -y \
  yum-utils \
  device-mapper-persistent-data \
  lvm2 \
  curl &&
sudo amazon-linux-extras install docker -y &&
sudo systemctl start docker &&
sudo systemctl enable docker &&
sudo usermod -aG docker ec2-user