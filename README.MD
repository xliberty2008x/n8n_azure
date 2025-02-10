# n8n Kubernetes Deployment on Azure

## Project Overview

This project sets up a Kubernetes cluster on Azure using Terraform to deploy the n8n workflow automation tool. The deployment includes a PostgreSQL database, persistent storage, and necessary Kubernetes resources such as namespaces, deployments, and services.

## Purpose

The primary purpose of this project is to automate the deployment of n8n on Azure Kubernetes Service (AKS) using Terraform. This setup ensures that the deployment is reproducible, scalable, and easy to manage.

## Key Parts

### 1. AKS Cluster
The AKS cluster is defined in `kubernetes-simple.tf` and includes:
- A Kubernetes cluster with a default node pool.
- System-assigned identity for the cluster.
- Tags for environment identification.

### 2. Kubernetes Namespace
A namespace for n8n is created to isolate the resources within the cluster.

### 3. PostgreSQL Database
A PostgreSQL flexible server is deployed to store n8n's data. The database configuration is defined in `database.tf`.

### 4. Persistent Storage
Persistent storage is provisioned using Kubernetes Persistent Volume Claims (PVCs) to ensure data persistence across pod restarts.

### 5. Kubernetes Resources
- **Deployment**: Defines the n8n application deployment, including environment variables, container specifications, and volume mounts.
- **Service**: Exposes the n8n application within the cluster and optionally to the outside world.

### 6. Secrets Management
Kubernetes secrets are used to securely store sensitive information such as database credentials and SSL certificates.

## Benefits

- **Reproducibility**: The entire infrastructure can be recreated using Terraform scripts, ensuring consistency across environments.
- **Scalability**: The AKS cluster can be easily scaled to handle increased load.
- **Security**: Sensitive information is managed using Kubernetes secrets, and the cluster is configured with appropriate access controls.
- **Persistence**: Data is stored in persistent volumes, ensuring it is not lost during pod restarts.

## Next Iteration

In the next iteration, the following improvements will be addressed:
- **Virtual Networks (VNets)**: Proper configuration of VNets to enhance network security and isolation.
- **Subnets**: Creation and association of subnets to organize and segment the network.
- **Network Security Groups (NSGs)**: Implementation of NSGs to control inbound and outbound traffic to the resources.

## Getting Started

To deploy this project, follow these steps:

1. Clone the repository.
2. Configure your Azure credentials and Terraform variables.
3. Run `terraform init` to initialize the Terraform configuration.
4. Run `terraform apply` to create the resources.

## Conclusion

This project provides a robust and scalable deployment of n8n on Azure Kubernetes Service using Terraform. It ensures that the deployment is secure, reproducible, and easy to manage. Future iterations will further enhance the network configuration and security.
