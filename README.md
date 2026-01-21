# Kubernetes

This repository contains Kustomize and Helm resources for deploying applications to Kubernetes clusters using ArgoCD.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Deployment](#deployment)
- [Repository Structure](#repository-structure)
- [Troubleshooting](#troubleshooting)
- [Future Enhancements](#future-enhancements)

## Prerequisites

### Get an AWS account

https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/

## Installation

### Install Required Tools

**macOS:**
```bash
brew install awscli docker helm kubectl
brew tap argoproj/tap
brew install argoproj/tap/argocd
```

**Install Kustomize:**

```bash
# macOS
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# Linux
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# Or use package manager
# macOS
brew install kustomize

# Linux (Ubuntu/Debian)
sudo apt-get install kustomize
```

**Note:** This README now includes both macOS and Linux instructions.

## Deployment

### Deploy ArgoCD and Applications to the Production Cluster

1. **Configure Cluster Settings**

   Ensure the cluster ID is set in:
   - `applications/argocd/prod/cluster-secret-prod-dyhedral.yaml`
   - `clusters/prod/installed_applications/kustomization.yaml`
   
   You can find your cluster ID in the [AWS EKS Console](https://console.aws.amazon.com/eks/home), e.g.:
   ```
   <id>.gr7.us-east-1.eks.amazonaws.com
   ```

2. **Deploy ArgoCD & Applications:**

   ```bash
   kustomize build applications/argocd/prod | kubectl apply -f -
   kustomize build clusters/prod | kubectl apply -f -
   ```

3. **Connect to ArgoCD:**

   ```bash
   kubectl port-forward svc/argocd-server -n argocd 9998:443
   open http://localhost:9998
   ```

4. **Register the Cluster (If Needed):**

   ```bash
   argocd cluster add arn:aws:eks:us-east-1:<id>:cluster/prod-dyhedral-eks
   ```

### Destroy ArgoCD and Applications

```bash
kustomize build applications/argocd/prod | kubectl delete -f -
kustomize build clusters/prod | kubectl delete -f -
```

## Repository Structure

```
.
├── applications/           # Application definitions and configurations
│   ├── argocd/            # ArgoCD installation and configuration
│   ├── cert-manager/      # Certificate management
│   ├── cluster-autoscaler/# Kubernetes cluster autoscaler
│   ├── metrics-server/    # Kubernetes metrics server
│   ├── mysql/             # MySQL database
│   ├── vault/             # HashiCorp Vault
│   └── ...                # Other applications
└── clusters/              # Maps application definitions to specific clusters
    ├── development/       # Development cluster configuration
    └── prod/              # Production cluster configuration
```

## Troubleshooting

### Pod Limit

If you can't seem to spin up pods, you may be at the limit. Check by running:

```bash
kubectl get node -o yaml | grep pods
#   pods: "17" -> Number of pods running
#   pods: "17" -> Limit based on node sizes
```

If you hit this limit before configuring the autoscaler, you may need to manually scale up in the [AWS EC2 Auto Scaling Console](https://console.aws.amazon.com/ec2autoscaling).

### Admin Password

If you forgot the ArgoCD admin password, see: https://argo-cd.readthedocs.io/en/stable/faq/#i-forgot-the-admin-password-how-do-i-reset-it

### Delete All Resources

**Warning:** This will delete all resources in your cluster!

```bash
kubectl delete daemonsets,replicasets,services,deployments,pods,rc --all
cd ../terraform/plans/dyhedral
terraform destroy -target=module.eks-cluster
terraform plan && terraform apply
```

## Future Enhancements

### Short-term Goals

1. Deploy ingress & other applications
2. Finalize & deploy mass testing platform deployment
3. Point DNS at new load balancer manually

### Long-term Goals

1. Set up Route53 zone
2. Set up ExternalDNS