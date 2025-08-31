# syntax=docker/dockerfile:1
FROM docker:dind

# Install system dependencies and AWS CLI
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
ENV TERRAFORM_VERSION=1.13.1
ENV TERRAFORM_SHA256SUM=4449e2ddc0dee283f0909dd603eaf98edeebaa950f4635cea94f2caf0ffacc5a

RUN wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
  echo "${TERRAFORM_SHA256SUM}  terraform.zip" | sha256sum -c - && \
  unzip terraform.zip -d /usr/local/bin && \
  rm -f terraform.zip && \
  chmod +x /usr/local/bin/terraform && \
  # Verify installation
  terraform --version

# Create non-root user for better security
RUN addgroup -g 1000 -S builduser && \
  adduser -u 1000 -S builduser -G builduser -s /bin/bash && \
  # Add builduser to docker group for docker access
  addgroup builduser docker

# Set working directory
WORKDIR /workspace

# Switch to non-root user
USER builduser

ENTRYPOINT ["/bin/bash", "-c"]
