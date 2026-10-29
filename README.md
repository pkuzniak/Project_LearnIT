# LearnIT DevOps Project

A diploma project demonstrating infrastructure as code, CI/CD,
container deployment, and monitoring.

## Architecture

- AWS EC2: target environment for the application.
- Dell server (kuzi001): development, local testing, and monitoring.
- Terraform: AWS infrastructure provisioning.
- Docker: application packaging and execution.
- GitHub Actions: build, image publication, and deployment.
- Prometheus and Grafana: infrastructure and application monitoring.

Infrastructure, CI/CD, and monitoring are planned and not yet implemented.

## Repository Structure

- `app/`: Python HTTP application and Dockerfile.
- `infra/`: planned Terraform configuration.
- `monitoring/`: planned monitoring configuration.
- `.github/workflows/`: planned CI/CD workflows.
- `docs/requirements.md`: diploma project requirements summary.

## Local Build

From the repository root:

    docker build -t learnit-app:dev ./app

## Local Run

    docker run -d --name learnit-app-test -p 8000:8000 learnit-app:dev

Open http://192.168.18.100:8000 when testing on the Dell server
from the local network.

## Health Check

    curl -i http://127.0.0.1:8000/health

Expected response: HTTP 200 and `{"status": "ok"}`.

## Remove the Test Container

    docker rm -f learnit-app-test

## AWS Deployment

Deployment instructions will be added with the Terraform configuration
and CI/CD workflow.

## Security

Never commit AWS credentials, private keys, environment secrets,
or Terraform state files.
