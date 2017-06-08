# Dind-terraform-aws

[![Dockerhub badge](http://dockeri.co/image/jch254/dind-terraform-aws)](https://hub.docker.com/r/jch254/dind-terraform-aws)

Docker-powered build/deployment environment for projects on AWS. This Docker image is intended for use with [AWS CodeBuild](https://aws.amazon.com/codebuild).

This image is based on docker:dind (Alpine-based) and has Terraform 0.9.8 and the AWS CLI installed (see [Dockerfile](./Dockerfile) for all other installed utilities).

