# LearnIT DevOps Project - Piotr Kuzniak

A diploma project demonstrating AWS infrastructure provisioning,
container image publication, automated deployment, and monitoring.

## Architecture

- **AWS EC2:** runs the Python application in Docker.
- **Terraform:** provisions networking, EC2, security groups, and IAM.
- **GitHub Actions:** builds and publishes images after every branch push.
- **GitHub Container Registry (GHCR):** stores application images tagged with the commit SHA.
- **AWS Systems Manager (SSM):** executes deployments on EC2 after pushes to `main`.
- **Dell / Proxmox / kuzi001:** hosts the development environment and monitoring stack.
- **Prometheus:** collects EC2 system metrics and application probe results.
- **Node Exporter:** exposes EC2 CPU, memory, and filesystem metrics.
- **Blackbox Exporter:** checks the application health endpoint.
- **Grafana:** displays the provisioned LearnIT dashboard.

## Repository Files

| File | Description |
| --- | --- |
| `.github/workflows/ci.yml` | Builds and publishes container images, deploys from main through SSM, and defines optional SMTP notifications. |
| `.gitignore` | Excludes credentials, local environment files, Terraform state, plans, and Python cache files. |
| `README.md` | Project overview, file inventory, setup instructions, and current limitations. |
| `app/Dockerfile` | Builds the Python application image and runs it as a non-root user. |
| `app/main.py` | Implements the application HTTP server, version response, and health endpoint. |
| `docs/requirements.md` | Summarizes the diploma project requirements. |
| `infra/.terraform.lock.hcl` | Records the selected AWS provider version and package checksums. |
| `infra/bootstrap.sh` | Installs Docker and Node Exporter during initial EC2 provisioning. |
| `infra/compute.tf` | Selects an Ubuntu image and defines the application EC2 instance. |
| `infra/deploy-iam.tf` | Defines the dedicated deployment user and its restricted SSM permissions. |
| `infra/iam.tf` | Defines the EC2 role and instance profile required by SSM. |
| `infra/network.tf` | Creates the VPC, public subnet, internet gateway, and routing. |
| `infra/outputs.tf` | Exposes the instance ID, public IP, application URL, and SSH command. |
| `infra/providers.tf` | Configures the AWS region and default resource tags. |
| `infra/security.tf` | Defines application, SSH, monitoring, and outbound network rules. |
| `infra/ssh.tf` | Registers the administrator's public SSH key with AWS. |
| `infra/variables.tf` | Defines the project name, EC2 instance type, and administrator network address. |
| `infra/versions.tf` | Declares Terraform and AWS provider version constraints. |
| `monitoring/blackbox.yml` | Defines an HTTP probe requiring status 200 and a healthy response body. |
| `monitoring/compose.yml` | Runs Prometheus, Grafana, and Blackbox Exporter on the Dell server. |
| `monitoring/grafana/dashboards/learnit.json` | Defines application health and EC2 resource usage panels. |
| `monitoring/grafana/provisioning/dashboards/default.yml` | Automatically loads dashboards into the LearnIT folder. |
| `monitoring/grafana/provisioning/datasources/prometheus.yml` | Automatically configures Prometheus as Grafana's default data source. |
| `monitoring/prometheus.yml` | Configures Prometheus self-monitoring, EC2 metrics, and application health probes. |

## Local Files Not Published to Git

| File or directory | Description |
| --- | --- |
| `infra/terraform.tfvars` | Local Terraform variable values, including the administrator's public IPv4 CIDR. |
| `infra/terraform.tfstate` | Terraform's record of managed resources. Preserve securely; never commit it. |
| `infra/terraform.tfstate.backup` | Local backup of Terraform state. |
| `infra/deployment.tfplan` | Saved deployment plan; regenerate it after configuration changes. |
| `infra/.terraform/` | Downloaded providers and local Terraform working data. |
| `monitoring/.env` | Local Grafana administrator password. |
| `app/__pycache__/` | Generated Python bytecode cache. |

Docker volumes store Prometheus metrics and Grafana data outside the repository.

## Prerequisites

On the Dell development server:

- Git
- Docker Engine and Docker Compose
- Terraform matching the constraints in `infra/versions.tf`
- AWS CLI with permission to provision the declared resources
- A public SSH key at `~/.ssh/id_ed25519.pub`

The configured AWS region is `eu-north-1`.
AWS resources consume Free Tier credits or incur charges according to the account plan.

## Local Application Test

Run from the repository root:

```bash
docker build -t learnit-app:dev ./app
docker run -d --name learnit-app-test -p 8000:8000 learnit-app:dev
curl --fail http://127.0.0.1:8000/health
```

Expected response:

```json
{"status": "ok"}
```

Remove the test container:

```bash
docker rm -f learnit-app-test
```

## Infrastructure Provisioning

Create a local `infra/terraform.tfvars` file:

```hcl
admin_cidr = "YOUR_PUBLIC_IPV4/32"
```

Use the public IPv4 address of the Dell network, not the VM's private address.

Initialize, review, and apply:

```bash
terraform -chdir=infra init
terraform -chdir=infra validate
terraform -chdir=infra plan -out=deployment.tfplan
terraform -chdir=infra apply deployment.tfplan
terraform -chdir=infra output
```

Inspect every plan before applying it.

The current configuration uses local Terraform state.
Preserve the state and its backup securely.

The SSH public key path and AWS availability zone are currently configured
for this development environment.

After provisioning, confirm that EC2 appears Online in SSM.
If the agent started before its IAM role became available, restart it over SSH:

```bash
sudo systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service
```

## CI/CD

Every branch push:

1. Builds the image from `app/`.
2. Publishes it to `ghcr.io/pkuzniak/project_learnit`.
3. Tags the image with the full commit SHA.

A push to `main` additionally:

1. Waits for a successful build.
2. Sends an SSM command to the configured EC2 instance.
3. Pulls the image before replacing the running application container.
4. Starts the new container with the commit SHA as `APP_VERSION`.
5. Checks `/health`, retrying startup connection errors.
6. Reports the command result to GitHub Actions.

Container replacement causes a short interruption.
Automatic rollback is not implemented.

### GitHub Actions Configuration

Repository secrets:

| Name | Purpose |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Access key ID of the dedicated deployment user. |
| `AWS_SECRET_ACCESS_KEY` | Secret access key of the dedicated deployment user. |

Repository variable:

| Name | Purpose |
| --- | --- |
| `EC2_INSTANCE_ID` | Target instance ID from Terraform outputs. |

Create the deployment user's access key outside Terraform and store it
directly in GitHub Secrets. Do not use the administrator's credentials.

The deployment user can run shell commands through SSM only on the
application instance. Protect its credentials accordingly.

Keep the GHCR package public so EC2 can pull it without registry credentials.

OIDC setup could not be completed because the account's organization policy
denied the required IAM read operations.

## Email Notifications

SMTP notification code is present but disabled and not yet tested.

The current recipient, `example321@example.com`, is a placeholder.
Replace it with a real recipient before enabling notifications.

Required repository secrets:

- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `MAIL_FROM`

Set repository variable `MAIL_ENABLED` to `true` only after configuring
SMTP and replacing the recipient.

Port 465 uses implicit TLS. Other configured ports use STARTTLS.

The notification job reports build and deployment results, including failures.
The diploma notification requirement remains incomplete until actual delivery
has been tested.

## Monitoring Setup

Create `monitoring/.env` with a unique administrator password:

```dotenv
GRAFANA_ADMIN_PASSWORD='YOUR_STRONG_UNIQUE_PASSWORD'
```

Protect the file and start the stack:

```bash
chmod 600 monitoring/.env
docker compose --env-file monitoring/.env -f monitoring/compose.yml config --quiet
docker compose --env-file monitoring/.env -f monitoring/compose.yml up -d
```

Grafana automatically provisions its data source and dashboard.

The dashboard includes:

- Application health
- EC2 metrics collection status
- CPU usage
- Memory usage
- Root filesystem usage
- HTTP probe duration

Prometheus retains metrics for up to 15 days, with a 5 GB retention size limit.

### Current Network Layout

| Endpoint | Purpose |
| --- | --- |
| `10.10.10.10` | Private address of the kuzi001 VM. |
| `192.168.18.100` | Proxmox address used for access from the Wi-Fi network. |
| `http://192.168.18.100:3000` | Grafana through Proxmox NAT. |
| `http://127.0.0.1:9090` | Prometheus on kuzi001 only. |
| `http://16.171.113.22:8000` | Current application endpoint on EC2. |

Proxmox forwards TCP port 3000 on `wlp0s20f3` to `10.10.10.10:3000`.
Persistence of this newly added forwarding rule across host restarts
has not yet been configured or verified.

Grafana binds to `10.10.10.10:3000`; adjust the Compose configuration
when deploying monitoring on another host.

EC2 port 8000 is public. SSH port 22 and Node Exporter port 9100
are restricted to `admin_cidr`.

The monitoring server initiates connections to EC2.
EC2 does not need an inbound connection to the Dell monitoring stack.

### Monitoring Checks

On kuzi001:

```bash
curl --fail http://10.10.10.10:3000/api/health
curl --fail http://127.0.0.1:9090/-/ready
curl --get --data-urlencode 'query=up{job="ec2-node"}' http://127.0.0.1:9090/api/v1/query
curl --get --data-urlencode 'query=probe_success{job="app-health"}' http://127.0.0.1:9090/api/v1/query
```

Both metric queries should return a value of `1`.

## Current Limitations and Remaining Work

- Configure and test real SMTP notifications.
- Verify build and image publication from a non-main branch.
- Persist and verify the Proxmox forwarding rule.
- Demonstrate a Terraform plan with no changes after deployment.
- Test complete infrastructure recreation and application redeployment.
- Update monitoring targets and `EC2_INSTANCE_ID` if EC2 is replaced.
- Update `admin_cidr` when the Dell network's public IPv4 address changes.
- Documented requirements are still summarized in Polish.

Changing `bootstrap.sh` currently forces EC2 replacement because
`user_data_replace_on_change` is enabled.

The Node Exporter installation was added to the bootstrap script after the
current instance was created and was installed manually on that instance.
A subsequent Terraform plan may therefore propose replacing EC2.
Do not apply that replacement without reviewing its effect on deployment
and monitoring addresses.

The current public EC2 address is not an Elastic IP and may change after
a stop/start or instance replacement.

## Security and Cleanup

Never commit AWS keys, SSH private keys, SMTP credentials,
Grafana passwords, Terraform state, or saved plans.

Application and Grafana access currently use HTTP.
TLS and monitoring alert notifications are not yet configured.

To stop local monitoring while preserving its data:

```bash
docker compose --env-file monitoring/.env -f monitoring/compose.yml down
```

Do not add `-v` unless you intend to delete stored monitoring data.

To remove the AWS resources when they are no longer needed:

```bash
terraform -chdir=infra plan -destroy -out=destroy.tfplan
terraform -chdir=infra apply destroy.tfplan
```

Review the destruction plan carefully. Destruction removes the managed EC2
instance and its root disk. Retain any required evidence or data beforehand.

Separately remove obsolete GitHub secrets and container images when
retiring the project.
