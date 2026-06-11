#!/usr/bin/env bash
# destroy-all.sh — Tear down the bootcamp infrastructure.
#
# Order matters:
#   1. Drain ArgoCD-managed apps (so finalizers don't block).
#   2. Destroy Helm releases that aren't ArgoCD-managed.
#   3. terraform destroy in infra/terraform.
#
# This is destructive. Confirmation required.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$REPO_ROOT/infra/terraform"

confirm() {
  printf '%s ' "$1"; read -r ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted."; exit 1; }
}

echo "This will destroy:"
echo "  - All ArgoCD Applications in the cluster"
echo "  - All Helm releases (api, frontend, postgres, monitoring, argocd itself, loki)"
echo "  - Everything Terraform manages in $TF_DIR"
echo
confirm "Proceed? [y/N]"

# 1. ArgoCD apps
if command -v argocd >/dev/null && argocd account whoami >/dev/null 2>&1; then
  echo "==> deleting ArgoCD Applications"
  for app in $(argocd app list -o name 2>/dev/null || true); do
    argocd app delete "$app" --cascade --yes || true
  done
fi

# 2. Helm releases (best-effort)
if command -v helm >/dev/null && command -v kubectl >/dev/null; then
  echo "==> uninstalling Helm releases"
  for ns in bootcamp monitoring argocd; do
    for rel in $(helm -n "$ns" list -q 2>/dev/null || true); do
      helm -n "$ns" uninstall "$rel" || true
    done
  done
  echo "==> deleting namespaces"
  for ns in bootcamp monitoring argocd; do
    kubectl delete namespace "$ns" --ignore-not-found --wait=false || true
  done
fi

# 3. Terraform
if [[ -d "$TF_DIR" ]]; then
  echo "==> terraform destroy in $TF_DIR"
  ( cd "$TF_DIR" && terraform destroy -auto-approve )
fi

echo
echo "Done. Run ./scripts/check-free-tier.sh to confirm $0 charges."
