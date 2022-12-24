#!/bin/bash

# install docker
apt-get update
apt-get install -y unzip docker.io

# enable docker and add perms
usermod -G docker jenkins
systemctl enable docker
service docker start

# install pip
wget -q https://bootstrap.pypa.io/get-pip.py
python get-pip.py
python3 get-pip.py
rm -f get-pip.py
# install awscli
pip install awscli

# install terraform
TERRAFORM_VERSION="1.3.6"
wget -q https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_$${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_$${TERRAFORM_VERSION}_linux_amd64.zip

# clean up
apt-get clean
rm terraform_0.12.18_linux_amd64.zip

# Run node application on ec2 instalce
docker pull sachinmgaikwad185/jaguar-test-repo:v1.0
docker stop jaguar-test-repo
docker rm jaguar-test-repo
docker rmi sachinmgaikwad185/jaguar-test-repo:current
docker tag sachinmgaikwad185/jaguar-test-repo:master sachinmgaikwad185/jaguar-test-repo:current
docker run -d --name node-demo -p 80:3000 sachinmgaikwad185/jaguar-test-repo:current
