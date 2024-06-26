FROM docker:dind

RUN apk add --no-cache \
  python3 \
  py-pip \
  py-setuptools \
  openssl \
  groff \
  less \
  bash \
  curl \
  jq \
  git \
  aws-cli && \
  aws configure set preview.cloudfront true

ENV TERRAFORM_VERSION 1.7.5

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform.zip -d /usr/local/bin && \
  rm -f terraform.zip

ENTRYPOINT ["/bin/bash", "-c"]
