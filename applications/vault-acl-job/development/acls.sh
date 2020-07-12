#!/bin/sh
set -x -e pipefail

if ! vault secrets list | grep 'kv/' | grep kv; then
  vault secrets enable -path=kv kv-v2
fi

# Kubernetes Policies and Roles
vault policy write app-policy /vault-acl-job-cm/app.hcl
vault write auth/kubernetes/role/app bound_service_account_names=app bound_service_account_namespaces=app policies=app-policy ttl=1h