#!/usr/bin/env bash
# break-it.sh — Capstone scenario runner.
#
# Picks one of N scenarios at random and applies it. Stores the chosen
# scenario in .last-scenario so --restore can undo it.
#
# Engineer should NOT read past this header until they've solved it.
#
# Usage:
#   ./break-it.sh             # pick random scenario, apply
#   ./break-it.sh --restore   # undo previous scenario

set -euo pipefail

NS="${NS:-bootcamp}"
STATE_FILE="$(dirname "$0")/.last-scenario"

# === DO NOT READ PAST HERE UNTIL YOU HAVE FIXED THE SYSTEM ===
#
#
#
#
#
#
#
#
#
#

scenario_1_bad_db_password() {
  echo "[break-it] applying scenario 1"
  kubectl -n "$NS" patch secret api-db --type=json \
    -p='[{"op":"replace","path":"/data/url","value":"'"$(echo -n 'postgres://postgres:WRONG@postgres-postgresql:5432/items' | base64)"'"}]'
  kubectl -n "$NS" rollout restart deployment/api
}
restore_1() {
  echo "[break-it] restoring scenario 1 — you must set api-db secret back to the real password manually (or re-sync ArgoCD)."
  kubectl -n "$NS" rollout restart deployment/api || true
}

scenario_2_wrong_image_tag() {
  echo "[break-it] applying scenario 2"
  kubectl -n "$NS" set image deployment/api api=docker.io/library/nginx:1.27-alpine
}
restore_2() {
  echo "[break-it] restoring scenario 2 — re-sync ArgoCD app 'api' to revert."
}

scenario_3_blocked_egress() {
  echo "[break-it] applying scenario 3"
  cat <<EOF | kubectl -n "$NS" apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: capstone-block-egress
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: api
  policyTypes: ["Egress"]
  egress: []
EOF
}
restore_3() {
  echo "[break-it] restoring scenario 3"
  kubectl -n "$NS" delete networkpolicy capstone-block-egress --ignore-not-found
}

scenario_4_zero_replicas() {
  echo "[break-it] applying scenario 4"
  kubectl -n "$NS" scale statefulset postgres-postgresql --replicas=0
}
restore_4() {
  echo "[break-it] restoring scenario 4"
  kubectl -n "$NS" scale statefulset postgres-postgresql --replicas=1
}

scenario_5_resource_starvation() {
  echo "[break-it] applying scenario 5"
  kubectl -n "$NS" patch deployment api --type=json \
    -p='[{"op":"replace","path":"/spec/template/spec/containers/0/resources/limits/memory","value":"8Mi"}]'
}
restore_5() {
  echo "[break-it] restoring scenario 5"
  kubectl -n "$NS" patch deployment api --type=json \
    -p='[{"op":"replace","path":"/spec/template/spec/containers/0/resources/limits/memory","value":"256Mi"}]'
}

apply_random() {
  local n=$((1 + RANDOM % 5))
  echo "$n" > "$STATE_FILE"
  "scenario_${n}_$(case $n in
    1) echo bad_db_password;;
    2) echo wrong_image_tag;;
    3) echo blocked_egress;;
    4) echo zero_replicas;;
    5) echo resource_starvation;;
  esac)"
  echo "[break-it] done. The clock is running. Good luck."
}

restore_previous() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "[break-it] no previous scenario recorded. Nothing to restore."
    exit 0
  fi
  local n; n=$(cat "$STATE_FILE")
  "restore_${n}"
  rm -f "$STATE_FILE"
  echo "[break-it] restored. Verify with your dashboards."
}

case "${1:-}" in
  --restore) restore_previous ;;
  "")        apply_random ;;
  *)         echo "Usage: $0 [--restore]"; exit 2 ;;
esac
