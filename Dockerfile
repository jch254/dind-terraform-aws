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
ENV TERRAFORM_VERSION=1.14.8
ARG TARGETARCH

RUN case "${TARGETARCH}" in \
      amd64) TERRAFORM_SHA256="56a5d12f47cbc1c6bedb8f5426ae7d5df984d1929572c24b56f4c82e9f9bf709" ;; \
      arm64) TERRAFORM_SHA256="c953171cde6b25ca0448c3b29a90d2f46c0310121e18742ec8f89631768e770c" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip" && \
    echo "${TERRAFORM_SHA256}  terraform.zip" | sha256sum -c - && \
    unzip terraform.zip -d /usr/local/bin && \
    rm -f terraform.zip && \
    chmod +x /usr/local/bin/terraform && \
    terraform --version

# Set working directory
WORKDIR /workspace

ENTRYPOINT ["/bin/bash", "-c"]
