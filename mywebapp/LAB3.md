# Laboratory work №3 — CI/CD

## Goal

The goal of this laboratory work is to configure a full CI/CD pipeline for the application from Laboratory work №1.

The pipeline includes:

- continuous integration
- automated testing
- Docker image build
- Docker image publishing
- deployment to a remote VM
- deployment verification

---

# Infrastructure

## Runner VM

Self-hosted GitHub Actions runner:

- Ubuntu 24.04.3 LTS
- ARM64
- UTM virtual machine
- GitHub Actions self-hosted runner

## Target VM

Deployment target server:

- Ubuntu 24.04.3 LTS
- ARM64
- Docker
- nginx

---

# CI Pipeline

The CI workflow performs:

- Python dependency installation
- flake8 static analysis
- pytest execution

Workflow file:

```text
.github/workflows/ci.yml
```

---

# Docker Build Pipeline

The build workflow:

- builds Docker images
- pushes images to GitHub Container Registry
- supports ARM64 platform

Published image:

```text
ghcr.io/valmai12/devops-labs/mywebapp
```

Workflow file:

```text
.github/workflows/build.yml
```

---

# Deployment Pipeline

The deployment workflow:

- copies deployment scripts to target VM
- deploys MariaDB container
- deploys web application container
- configures nginx reverse proxy
- verifies deployment automatically

Workflow file:

```text
.github/workflows/deploy.yml
```

---

# Deployment Verification

Verification script checks:

- GET /
- GET /notes
- GET /health/alive directly on container
- hidden health endpoint through nginx

Verification file:

```text
mywebapp/deploy/verify.sh
```

---

# Self-hosted Runner

Runner labels:

```text
self-hosted
Linux
ARM64
```

---

# Result

The application was successfully:

- tested
- containerized
- published to GitHub Container Registry
- deployed automatically to a remote VM
- verified after deployment