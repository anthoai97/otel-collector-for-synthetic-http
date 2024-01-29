#!/bin/bash
sudo mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
sudo su
sudo yum install -y docker
sudo service docker start
sudo yum -y install wget systemctl
sudo wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.91.0/otelcol-contrib_0.91.0_linux_amd64.rpm
sudo rpm -ivh otelcol-contrib_0.91.0_linux_amd64.rpm
sudo wget https://widget-cdn.example.com/otel-connector-configs/eu-central-1-external-health-config.yaml -O config.yaml

cp -f /tmp/ssm/config.yaml /etc/otelcol-contrib/config.yaml
systemctl restart otelcol-contrib.service

rm amazon-ssm-agent.deb