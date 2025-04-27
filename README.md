# base-app Helm Chart

## Overview
This Helm chart (***base-app***) provides a template for deploying a generic application to Azure Kubernetes Service (AKS). It includes all common Kubernetes resources such as Deployment, Service, IngressRoute (Traefik), PersistentVolumeClaim, Job, CronJob, SecretProviderClass for Azure Key Vault, and Horizontal Pod Autoscaler. All components are highly configurable via the `values.yaml` file, allowing application teams to easily tailor the deployment to their app's needs.

## Prerequisites
- **Kubernetes**: An AKS cluster (or any Kubernetes cluster) with Helm installed.
- **Traefik Ingress Controller**: The Traefik ingress controller should be installed in the cluster (for the IngressRoute resource).
- **Secrets Store CSI Driver**: If using Azure Key Vault integration, the Azure Key Vault CSI driver and its SecretProviderClass CRD must be installed in the cluster.

## Usage
1. **Add this chart** to your Helm repository or clone this repository.
2. **Customize values**: Edit the `charts/base-app/values.yaml` file to suit your application. At minimum, set the container image (`image.repository` and `image.tag`) for your app. 
3. **Enable/disable features**: Toggle the features you need (e.g., ingress, persistence, autoscaling, jobs) by setting the corresponding values.
4. **Deploy the chart** using Helm:
   ```bash
   helm install my-app charts/base-app -f my-values.yaml
