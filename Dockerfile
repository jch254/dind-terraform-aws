# syntax=docker/dockerfile:1
FROM docker:dind

# Install system dependencies, AWS CLI, and Node.js 22.x
RUN apk add --no-cache --update \
  python3 \
  py3-pip \
  py3-setuptools \
  openssl \
  groff \
  less \
  bash \
  curl \
  jq \
  git \
  wget \
  unzip \
  ca-certificates \
  aws-cli && \
  aws configure set preview.cloudfront true && \
  # Clean up package cache
  rm -rf /var/cache/apk/*

# Install Terraform
ENV TERRAFORM_VERSION=1.13.3
ENV TERRAFORM_SHA256SUM=71fc43d92ea09907be5d416d2405a6a9c2d1ceaed633f5e175c0af26e8c4b365

RUN wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
  echo "${TERRAFORM_SHA256SUM}  terraform.zip" | sha256sum -c - && \
  unzip terraform.zip -d /usr/local/bin && \
  rm -f terraform.zip && \
  chmod +x /usr/local/bin/terraform && \
  # Verify installation
  terraform --version

# Set working directory
WORKDIR /workspace

ENTRYPOINT ["/bin/bash", "-c"]
