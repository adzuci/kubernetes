# Tests

This directory contains validation tests for the Kubernetes manifests in this repository.

## Running Tests Locally

### Prerequisites

Ensure you have `kustomize` installed:

```bash
# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/
```

### Run All Tests

```bash
# From the repository root
./tests/validate.sh
```

This will:
- Check that all `kustomization.yaml` files can be built successfully
- Validate the YAML syntax
- Report any errors

## Continuous Integration

Tests are automatically run on every push and pull request via GitHub Actions. See `.github/workflows/validate.yml` for details.

The CI pipeline includes:
- YAML linting with `yamllint`
- Kustomize build validation
- Kubernetes manifest validation with `kubeconform`

## Adding New Tests

To add new validation tests:

1. Update `tests/validate.sh` with your new test logic
2. Update `.github/workflows/validate.yml` to include the new test in CI
3. Document the new test in this README
