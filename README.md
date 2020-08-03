# Kubernetes

This repo contains the kustomize and helm resources that I have used to spin up resources in Kubernetes.

# Contributing

## Get an AWS account

https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/

## Install Requirements

```
brew install awscli docker helm kubectl
```

Install Kustomize:

```
curl https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.2.1/kustomize_kustomize.v3.2.1_darwin_amd64 > /usr/local/bin/kustomize
```

Note: This README is macOS specific, feel free to submit a PR with Linux instructions.

## Deploy ArgoCD and Applications To The Prod Cluster

Ensure the cluster ID is set in `applications/argocd/prod/cluster-secret-prod-dyhedral.yaml` and `clusters/prod/installed_applications/kustomization.yaml`.  You can find this in https://console.aws.amazon.com/eks/home, e.g.
```
<id>.gr7.us-east-1.eks.amazonaws.com
```

Deploy ArgoCD & Applications:
```
kustomize build applications/argocd/prod | kubectl apply -f -
kustomize build clusters/prod | kubectl apply -f -
```

Connect To ArgoCD:
```
kubectl port-forward svc/argocd-server -n argocd 9998:443
open localhost:9998
```

## Destroy ArgoCD and Applications To The Prod Cluster

```
kustomize build applications/argocd/prod | kubectl delete -f -
kustomize build clusters/prod | kubectl delete -f -
```

## What's In This Repo?

applications        applications definitions / config
clusters            Maps application definitions to clusters

## Troubleshooting

### Pod Limit

If you can't seem to spin up pods you may be at the limit.  You can check by running:

```
kubectl get node -o yaml | grep pods
      pods: "17" -> Number of pods running.
      pods: "17" -> Limit based off of node sizes.
```

If you hit this before you configure the autoscaler you may need to manually scale up in https://console.aws.amazon.com/ec2autoscaling

### Admin Password

https://github.com/argoproj/argo-cd/blob/master/docs/faq.md#i-forgot-the-admin-password-how-do-i-reset-it

## Up Next:

1. Deploy ingress & other apps.
2. Finalize & deploy masstestingplatform deployment.
3. Point DNS at new load balancer manually.

## Reach Goals

1. Set up Route53 zone.
2. Set up extrenaldns.