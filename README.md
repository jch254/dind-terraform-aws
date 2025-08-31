# dind-terraform-aws

[![Docker Hub](https://img.shields.io/docker/pulls/jch254/dind-terraform-aws)](https://hub.docker.com/r/jch254/dind-terraform-aws) [![Docker Image Size](https://img.shields.io/docker/image-size/jch254/dind-terraform-aws/latest)](https://hub.docker.com/r/jch254/dind-terraform-aws) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Docker-in-Docker (+ Terraform + AWS CLI) build/deployment environment for use with [AWS CodeBuild](https://aws.amazon.com/codebuild) or local CI workflows.

> Why this exists: Official AWS CodeBuild images include Docker and the AWS CLI but **do not bundle Terraform**. This image adds a pinned, checksum-verified Terraform version so you get reproducible infra + container builds in one environment.

## What's included

| Tool | Version (at build time) | Notes |
| ---- | ----------------------- | ----- |
| Docker (daemon + CLI) | From `docker:dind` base | Privileged mode required in CodeBuild |
| Terraform | 1.13.1 | SHA256 verified during image build |
| AWS CLI v2 | Alpine package | Region & credential config done at runtime |
| Python 3 + pip | Alpine packages | Enables helper scripting / terraform tooling |
| jq, curl, git, bash, unzip, wget, less, groff, openssl | Latest Alpine | Common build / scripting utilities |

Non-root user: A `builduser` (UID/GID 1000) is created and added to the `docker` group; workdir is `/workspace`.

## Usage (AWS CodeBuild)

1. Push (or pull) the image from Docker Hub: `jch254/dind-terraform-aws:latest` (or a tagged digest you trust).
2. In your CodeBuild project:
	* Environment type: Linux / Standard (custom image)
	* Privileged mode: **Enable** (needed for Docker-in-Docker)
	* Image registry: Docker Hub
	* Image: `jch254/dind-terraform-aws:latest`
3. (Optional) Set environment variables for Terraform backend / AWS region.

### Sample `buildspec.yml`

```yaml
version: 0.2
phases:
	install:
		commands:
			- echo "Starting Docker daemon"
			- nohup /usr/local/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay &
			- timeout 30 sh -c "until docker info; do echo .; sleep 1; done"
			- terraform --version
	pre_build:
		commands:
			- aws sts get-caller-identity
			- terraform init -input=false
	build:
		commands:
			- terraform validate
			- terraform plan -out tfplan
	post_build:
		commands:
			- terraform show -no-color tfplan | head -100
artifacts:
	files:
		- tfplan
```

## Local build & test

```bash
docker build -t dind-tf .
docker run --rm -it --privileged -v /var/run/docker.sock:/var/run/docker.sock dind-tf "terraform --version && aws --version && docker --version"
```

To start an interactive shell:

```bash
docker run --rm -it --privileged dind-tf bash
```

## Updating Terraform

Edit the `ENV TERRAFORM_VERSION` and associated `TERRAFORM_SHA256SUM` in the [`Dockerfile`](./Dockerfile). Obtain the checksum from the official release page (the `SHA256SUMS` file) to retain supply-chain verification.

After updating:

```bash
docker build -t dind-tf:terraform-<newversion> .
terraform --version
```

## Security notes

* Terraform binary integrity is verified with SHA256.
* Non-root user reduces risk; privileged mode in CodeBuild is still required specifically for Docker-in-Docker.
* Consider pinning the base image digest (e.g. `FROM docker:dind@sha256:<digest>`) for fully reproducible builds.
* Scan the image: `docker scout quickview jch254/dind-terraform-aws:latest` or use `trivy image ...`.

## Troubleshooting

| Symptom | Likely cause | Fix |
| ------- | ------------ | --- |
| `Cannot connect to the Docker daemon` | Docker daemon not yet ready | Increase timeout / ensure privileged mode enabled |
| `terraform: not found` | PATH or failed download | Rebuild; verify checksum variable matches release |
| AWS auth failures | Missing credentials / role | Attach proper IAM role to CodeBuild project |

## Contributing

Small repo—open an issue or PR with version bumps or lightweight tooling additions only (keep scope minimal to reduce attack surface / build time).

## License

MIT (see LICENSE if added; otherwise treat as MIT by convention—add an explicit license file for clarity if distributing widely).

## Reference links

* Terraform releases: https://releases.hashicorp.com/terraform/
* CodeBuild Docker images docs: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
* CodeBuild buildspec reference: https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html

