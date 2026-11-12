#!/bin/bash

# Kubernetes Manifest Validation Script
# This script validates all Kubernetes manifests in the repository

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Kubernetes Manifest Validation"
echo "=========================================="
echo ""

# Function to print success messages
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error messages
error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print warning messages
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if kustomize is installed
if ! command -v kustomize &> /dev/null; then
    error "Kustomize is not installed. Please install it first."
    echo "Run: curl -s 'https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh' | bash"
    exit 1
fi

success "Kustomize is installed: $(kustomize version --short)"
echo ""

# Validate all kustomization.yaml files
echo "Validating Kustomize builds..."
echo "----------------------------------------"

failed_builds=()

for kustomization in $(find . -name "kustomization.yaml" -not -path "./.git/*"); do
    dir=$(dirname "$kustomization")
    echo -n "Building $dir ... "
    
    if kustomize build "$dir" > /dev/null 2>&1; then
        success "OK"
    else
        error "FAILED"
        failed_builds+=("$dir")
    fi
done

echo ""

# Report results
if [ ${#failed_builds[@]} -eq 0 ]; then
    success "All Kustomize builds passed!"
    echo ""
    echo "=========================================="
    echo "Validation Complete: All tests passed! ✅"
    echo "=========================================="
    exit 0
else
    error "Failed builds:"
    for build in "${failed_builds[@]}"; do
        echo "  - $build"
    done
    echo ""
    echo "=========================================="
    echo "Validation Failed: ${#failed_builds[@]} build(s) failed ❌"
    echo "=========================================="
    exit 1
fi
