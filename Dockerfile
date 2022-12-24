FROM ubuntu:18.04

ARG AWS_CLI_VERSION=1.16.86

RUN apt-get update -y && \
    apt-get install python-dev python-pip wget unzip openssh-client -y && \
    pip install --upgrade awscli==${AWS_CLI_VERSION}

COPY ./app /app

ENV AWS_ACCESS_KEY_ID=my-key-id \
    AWS_SECRET_ACCESS_KEY=my-secret-access-key \
    AWS_DEFAULT_REGION=eu-west-1 \
    AWS_BASE_AMI_ID=Base-AMI-Id \
    AWS_PUBLIC_SUBNET_ID=subnet-id \
	
WORKDIR /app

CMD /usr/local/bin/packer build -var subnet_id=$AWS_PUBLIC_SUBNET_ID /packer/xl-ami.json

#docker run -e AWS_ACCESS_KEY_ID=my-key-id -e AWS_SECRET_ACCESS_KEY=my-secret-access-key -e AWS_PUBLIC_SUBNET_ID=subnet-id malaka:latest