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

```
kustomize build applications/argocd/prod | kubectl apply -f -
kustomize build clusters/prod | kubectl apply -f -
```

## What's In This Repo?

applications        applications definitions / config
clusters            Maps application definitions to clusters


## Up Next:

1. Fix ArgoCD issues.
2. Switch Cert Manager to http01.
3. Deploy ingress & other apps.
4. Finalize & deploy masstesting deployment.
5. Point DNS at new load balancer manually.

## Reach Goals

1. Set up Route53 zone.
2. Set up extrenaldns.