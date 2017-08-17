FROM docker:dind

RUN apk add --no-cache \
    python \
    py-pip \
    openssl \
    groff \
    less \
    bash \
    curl \
    jq \
    git \
  && pip install --no-cache-dir --upgrade pip awscli \
  && aws configure set preview.cloudfront true

ENV TERRAFORM_VERSION 0.10.2

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip -d /usr/local/bin && \
    rm -f terraform.zip

ENTRYPOINT ["/bin/bash", "-c"]
