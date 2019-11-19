# Dind-terraform-aws

[![Dockerhub badge](http://dockeri.co/image/jch254/dind-terraform-aws)](https://hub.docker.com/r/jch254/dind-terraform-aws)

Docker-powered build/deployment environment for Docker projects on AWS. This Docker image is intended for use with [AWS CodeBuild](https://aws.amazon.com/codebuild).

This image is based on docker:dind (Alpine-based) and has Terraform 0.12.16 and the AWS CLI installed (see [Dockerfile](./Dockerfile) for all other installed utilities).

All CodeBuild projects that use this image to build Docker images must have privileged mode set to true, otherwise associated builds that attempt to interact with the Docker daemon will fail. The Docker daemon must be started so that builds can interact with it as needed. One way to do this is to initialize the Docker daemon in the install phase of your CodeBuild buildspec.yml by running the following build commands:
```
- nohup /usr/local/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay&
- timeout 15 sh -c "until docker info; do echo .; sleep 1; done"
```
See: https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html for further info.