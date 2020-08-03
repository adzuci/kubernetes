#!/usr/bin/env bash

# This script configures the vault kubernetes auth plugin side of the Vault k8s auth mechanism:
# https://www.vaultproject.io/docs/auth/kubernetes/

# The helm chart as of the time of this writing installs a cluster role binding which allows the vault service account to
# use this K8s api endpoint:
# https://github.com/hashicorp/vault-helm/blob/master/templates/server-clusterrolebinding.yaml#L3-L20 

# exit on failure
set -e pipefail

echo "CHECK: kubectl authed to cluster"
if ! kubectl get pods -A 2> /dev/null; then
    echo "ERROR: Not authed to kubernetes cluster" >&2
    exit 1
fi

echo "CHECK: that we have vault cli installed"
if ! which vault; then
    echo "ERROR: Vault CLI Not Installed" >&2
    exit 1
fi

: ${KUBERNETES_URL?"Need to set KUBERNETES_URL! Get this from the AWS console it is the kubernetes API Endpoint eg: https://<id>.gr7.us-east-1.eks.amazonaws.com"}
: ${VAULT_TOKEN?"Need to set VAULT_TOKEN!"}
: ${VAULT_ADDR?"Need to set VAULT_ADDR! - this is the HTTPS DNS name for vault"}
: ${VAULT_SA_NAMESPACE}?"Need to set VAULT_SA_NAMESPACE! - namespace of the service account - typically vault"}
: ${VAULT_SA_NAME}?"Need to set VAULT_SA_NAME! - name of the service account - typically ENV-vault"}

set -xoe

# Find the service account for that secret
export VAULT_SECRET_NAME=$(kubectl get sa -n ${VAULT_SA_NAMESPACE} ${VAULT_SA_NAME} -o jsonpath="{.secrets[*]['name']}")

# Set SA_JWT_TOKEN value to the service account JWT used to access the TokenReview API
export SA_JWT_TOKEN=$(kubectl get secret -n ${VAULT_SA_NAMESPACE} $VAULT_SECRET_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)

# Set SA_CA_CRT to the PEM encoded CA cert used to talk to Kubernetes API
export SA_CA_CRT=$(kubectl get secret -n ${VAULT_SA_NAMESPACE} $VAULT_SECRET_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

if ! vault auth list | grep kubernetes ; then
	vault auth enable kubernetes
fi
vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$KUBERNETES_URL:443" kubernetes_ca_cert="$SA_CA_CRT"

vault policy write vault-acl-job-policy ./clusters/bootstrap-scripts/vault-acl-job-policy.hcl
vault write auth/kubernetes/role/vault-acl-job bound_service_account_names=vault-acl-job bound_service_account_namespaces=vault policies=vault-acl-job-policy ttl=1h
