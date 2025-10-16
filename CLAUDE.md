# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Terraform infrastructure-as-code to deploy n8n (workflow automation platform) on Azure Kubernetes Service (AKS) with a PostgreSQL Flexible Server backend. The deployment includes SSL/TLS support via cert-manager and Let's Encrypt.

## Architecture

### Core Infrastructure Components

1. **Azure Resources** ([main.tf](main.tf))
   - Resource Group: `n8n_bs` in East US 2
   - Virtual Network with address space `10.0.0.0/8`
   - Network Security Group (currently minimal configuration)
   - Note: Subnet configuration is commented out for future iteration

2. **AKS Cluster** ([kubernetes-simple.tf](kubernetes-simple.tf))
   - Cluster name: `n8nAKScluster`
   - Node pool: 2x `Standard_B2s` VMs with managed disks
   - System-assigned managed identity
   - Network profile configuration commented out (planned enhancement)

3. **PostgreSQL Database** ([database.tf](database.tf))
   - Azure PostgreSQL Flexible Server v16
   - SKU: `B_Standard_B1ms`
   - Storage: 32GB with 7-day backup retention
   - Public network access currently enabled (private endpoint planned)
   - SSL/TLS required using Baltimore CyberTrust Root certificate

4. **n8n Application** ([kubernetes-simple.tf](kubernetes-simple.tf))
   - Namespace: defined by `var.namespace`
   - Single replica deployment (strategy: Recreate)
   - Init container sets volume permissions for node user (UID 1000)
   - Persistent volume for n8n data at `/home/node/.n8n`
   - SSL certificate mounted from Kubernetes secret at `/certs`
   - Service type: LoadBalancer (default)

5. **Ingress & TLS** ([ingress.tf](ingress.tf))
   - NGINX ingress controller
   - cert-manager for automatic Let's Encrypt certificates
   - TLS termination at ingress
   - Forced SSL redirect enabled

6. **Python Task Runner** ([kubernetes-simple.tf:197-284](kubernetes-simple.tf#L197))
   - Native Python code execution in Code nodes (beta feature)
   - **External mode**: task runner runs as sidecar container (`n8nio/n8n-runners:latest`)
   - Communication via Task Broker on port 5679 (localhost)
   - Secured with randomly-generated auth token
   - Pre-installed Python packages: pandas, numpy, requests, beautifulsoup4, lxml, openpyxl, pypdf, pillow, python-dateutil, pytz
   - Enhanced isolation and stability for code execution
   - Resource allocation:
     - n8n container: 512Mi request / 1Gi limit
     - runner container: 256Mi request / 512Mi limit (100m CPU request / 500m CPU limit)

### File Structure

- `main.tf` - Terraform/Azure provider configuration, resource group, VNet, NSG
- `kubernetes-simple.tf` - AKS cluster, namespace, n8n deployment, service, RBAC
- `database.tf` - PostgreSQL Flexible Server and database
- `variables.tf` - All Terraform variable definitions
- `outputs.tf` - PostgreSQL server name, database name, admin password
- `claim0-persistentvolumeclaim.tf` - PVC for n8n data persistence
- `ingress.tf` - Kubernetes ingress with TLS
- `utils.tf` - Helper resources (random strings, wait provisioner)
- `cluster-issuer.yaml` - cert-manager ClusterIssuer manifest (applied manually)

### Key Design Decisions

1. **SSL Certificate Handling**: Baltimore CyberTrust Root certificate is stored at `/Users/cyrildubovik/Python_projects/n8n/BaltimoreCyberTrustRoot.crt.pem` and mounted into n8n pod. This path is hardcoded in [kubernetes-simple.tf:85](kubernetes-simple.tf#L85).

2. **Database Connection**: n8n connects to PostgreSQL with SSL enabled but `DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false` to handle certificate validation issues.

3. **Delayed Startup**: n8n container includes `sleep 5` before starting to allow database connectivity to establish.

4. **Volume Permissions**: Init container corrects permissions on persistent volume for n8n user.

5. **RBAC**: Default service account in n8n namespace has cluster-admin binding (consider restricting in production).

6. **Python Task Runner**: Deployed in **external mode** as a sidecar container. The `n8n-runner` container runs alongside the main n8n container in the same pod, providing:
   - True process isolation for Python code execution
   - Official `n8nio/n8n-runners` image with Python 3 pre-installed
   - Secure localhost communication via Task Broker (port 5679)
   - Auth token-based security between containers
   - Automatic scaling with the n8n pod

## Common Commands

### Terraform Operations

```bash
# Initialize Terraform (first time or after provider changes)
terraform init

# Plan infrastructure changes
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy all infrastructure
terraform destroy

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate
```

### Kubernetes Operations

```bash
# Get AKS credentials
az aks get-credentials --resource-group n8n_bs --name n8nAKScluster --overwrite-existing

# Check n8n deployment status
kubectl get deployments -n <namespace>
kubectl describe deployment n8n -n <namespace>

# Check n8n pods
kubectl get pods -n <namespace>
kubectl logs -f deployment/n8n -n <namespace>

# Check service and get LoadBalancer IP
kubectl get svc -n <namespace>

# Check ingress configuration
kubectl get ingress -n <namespace>
kubectl describe ingress -n <namespace>

# Check persistent volume claim
kubectl get pvc -n <namespace>
```

### cert-manager Setup

```bash
# Install cert-manager (prerequisite)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Apply ClusterIssuer after cert-manager is ready
kubectl apply -f cluster-issuer.yaml

# Verify cert-manager
kubectl get clusterissuer
kubectl get certificate -n <namespace>
```

### Python Task Runner (External Mode)

```bash
# Deploy Python Task Runner (via GitHub Actions + Terraform)
# Workflow: .github/workflows/apply-python-taskrunner-external.yml
# Deploys runner as sidecar container with external mode

# Check both containers in pod
kubectl get pods -n <namespace>
kubectl get pods -n <namespace> -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .status.containerStatuses[*]}{"\t"}{.name}{": "}{.ready}{"\n"}{end}{end}'

# View n8n main container logs
kubectl logs -n <namespace> deployment/n8n -c n8n --tail=100 --follow

# View runner sidecar container logs
kubectl logs -n <namespace> deployment/n8n -c n8n-runner --tail=100 --follow

# Verify Python task runner is enabled
kubectl describe deployment n8n -n <namespace> | grep -A 10 "N8N_RUNNERS"

# Check available Python packages (in runner container)
kubectl exec -n <namespace> deployment/n8n -c n8n-runner -- python3 -c "import pandas, numpy, requests; print('All packages available')"

# Check Task Broker communication
kubectl logs -n <namespace> deployment/n8n -c n8n | grep -i "task broker"
kubectl logs -n <namespace> deployment/n8n -c n8n-runner | grep -i "connected"
```

**Using Python in Code Nodes:**
1. Open n8n web interface
2. Create/edit a Code node
3. Select "Python (Native) (Beta)" from language dropdown
4. Write Python code using `_items` for input data
5. Available packages: pandas, numpy, requests, beautifulsoup4, lxml, openpyxl, pypdf, pillow, python-dateutil, pytz

**Example Python Code:**
```python
import pandas as pd
import numpy as np
from datetime import datetime

# Process input items
for item in _items:
    # Access item data
    data = item["json"]

    # Use pandas/numpy
    df = pd.DataFrame([data])
    df["processed"] = df["value"] * 2

    # Update item
    item["json"]["result"] = df["processed"].iloc[0]
    item["json"]["timestamp"] = str(datetime.now())

return _items
```

### n8n Upgrade (Automated)

GitHub Actions workflow ([.github/workflows/n8n_update.yml](.github/workflows/n8n_update.yml)) runs weekly on Sundays at 23:50 UTC:
- Updates n8n deployment to `n8nio/n8n:next` image
- Restarts deployment and waits for rollout completion

### Python Task Runner Workflows

GitHub Actions workflow ([.github/workflows/apply-python-taskrunner-external.yml](.github/workflows/apply-python-taskrunner-external.yml)) - one-time manual execution:
- Runs `terraform apply` to deploy Python task runner in external mode
- Adds runner sidecar container to n8n pod
- Configures Task Broker communication between containers
- Verifies both containers are running and connected
- Tests Python package availability

GitHub Actions workflow ([.github/workflows/rollback-python-taskrunner.yml](.github/workflows/rollback-python-taskrunner.yml)) - emergency rollback:
- Removes Python task runner environment variables
- Restores original memory limits (250Mi/500Mi)
- Restarts deployment to restore previous working state

GitHub Actions workflow ([.github/workflows/diagnose-n8n.yml](.github/workflows/diagnose-n8n.yml)) - troubleshooting:
- Checks pod status and events
- Retrieves logs from both n8n and runner containers
- Displays resource usage and configuration
- Helps identify issues with deployment

## Configuration Requirements

### Required Variables (terraform.tfvars)

The following variables must be defined in `terraform.tfvars` or via environment variables:

- `subscription_id` - Azure subscription ID
- `client_id` - Azure Service Principal client ID
- `client_secret` - Azure Service Principal secret (sensitive)
- `tenant_id` - Azure tenant ID
- `administrator_login` - PostgreSQL admin username
- `administrator_login_password` - PostgreSQL admin password (sensitive)
- `namespace` - Kubernetes namespace for n8n
- `postgres_database` - Database name (typically "n8n")
- `postgres_username` - n8n database user
- `postgres_password` - n8n database password (sensitive)
- `PGHOST` - PostgreSQL host (populated from server FQDN)

### Placeholders to Replace

Before deploying, update these placeholder values:

1. **[kubernetes-simple.tf:146](kubernetes-simple.tf#L146)**: `N8N_HOST` - Set to your domain
2. **[kubernetes-simple.tf:195](kubernetes-simple.tf#L195)**: `WEBHOOK_URL` - Set to your webhook URL
3. **[ingress.tf:14,32](ingress.tf#L14)**: `your_host_here` - Set to your domain
4. **[cluster-issuer.yaml:8](cluster-issuer.yaml#L8)**: `your_email_here` - Set to your email for Let's Encrypt
5. **[database.tf:2](database.tf#L2)**: `your_prefix` - Set database server name prefix

## Known Limitations & Future Work

1. **Network Configuration**: Subnet delegation and private endpoints are commented out. Next iteration will implement:
   - Proper VNet/subnet architecture
   - Private endpoint for PostgreSQL
   - Network security group rules
   - Service endpoint for storage

2. **SSL Certificate Path**: Hardcoded local path for Baltimore cert needs to be parameterized or bundled in repo.

3. **Security**:
   - Default service account has cluster-admin (over-permissioned)
   - PostgreSQL public network access enabled
   - SSL rejection disabled for PostgreSQL

4. **Scalability**: Single replica deployment with Recreate strategy causes downtime during updates.

5. **Observability**: No monitoring, logging, or alerting configured.

## Provider Versions

- `hashicorp/azurerm` ~> 4.17.0
- Kubernetes provider configured via AKS cluster kubeconfig

## Dependencies

- Azure CLI (`az`) for authentication and cluster access
- kubectl for Kubernetes operations
- cert-manager must be installed in cluster before applying ingress resources
- NGINX ingress controller must be installed in cluster
