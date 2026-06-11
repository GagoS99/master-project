# Module 2 — Exercises

## Exercise 1 — k3s via cloud-init

Modify the EC2's `user_data` (cloud-init) to install k3s on first boot.

Requirements:
- Pin the k3s version (e.g., `v1.30.4+k3s1`). Do not use `INSTALL_K3S_VERSION=latest`.
- Disable `servicelb` and `traefik` for now — you'll decide about them in exercise 3.
- Set `--write-kubeconfig-mode 644` so a non-root user can read kubeconfig.
- Set `--tls-san <public-ip-or-dns>` so kubeconfig works from your laptop.

Apply via `terraform apply`. If you have an existing instance, you may need to `terraform taint` it or `terraform replace` to force re-creation. (Or destroy + apply.)

After apply: SSH in, run `sudo systemctl status k3s`, then `sudo kubectl get nodes` (k3s ships a bundled `kubectl`).

## Exercise 2 — Local kubectl

1. From your laptop, install `kubectl` (`brew install kubectl` or via krew).
2. Copy `/etc/rancher/k3s/k3s.yaml` from the EC2 to `~/.kube/config-bootcamp` on your laptop.
3. Edit the `server:` field — replace `127.0.0.1` with the EC2 public IP.
4. Set `KUBECONFIG=~/.kube/config-bootcamp` or merge into `~/.kube/config`.
5. `kubectl get nodes` from your laptop. Should show your single node, status `Ready`.
6. `kubectl config get-contexts` — confirm you understand which context you're on.

## Exercise 3 — Decide on built-ins

k3s ships with optional components. For our bootcamp:

- **traefik**: ingress controller. Disabled. (We'll port-forward and NodePort instead — less moving parts, no DNS pain.)
- **servicelb (klipper-lb)**: LoadBalancer implementation. Disabled. (Free-tier — no real ELB.)
- **local-path-provisioner**: keep. We need a StorageClass for Postgres later.
- **metrics-server**: keep. `kubectl top` is too useful to skip.
- **coredns**: keep. Service discovery requires it.

Write down in `infra/terraform/notes.md` your decision per component, and *why*. Commit it.

## Exercise 4 — Your first workload (by hand)

Hand-write a YAML manifest at `~/scratch/nginx-test.yaml` on your laptop:

- A Deployment of `nginx:1.27-alpine` with 2 replicas, named `nginx-test`.
- A Service of type `NodePort` exposing port 80 on a node port in the 30000-32767 range.
- Resource requests: `cpu: 10m`, `memory: 32Mi` per pod. (Free-tier survival — t3.micro is small.)

Apply: `kubectl apply -f nginx-test.yaml`.

Verify:
- `kubectl get deploy,svc,pods -l app=nginx-test`
- Open `http://<ec2-public-ip>:<nodeport>` — should see the nginx welcome page.
  - You'll need to add an inbound rule to the EC2 SG for the node port range. Add it to Terraform, not by hand in the console.
- Use `kubectl logs`, `kubectl describe pod`, `kubectl exec` on the pod.

Clean up: `kubectl delete -f nginx-test.yaml`.

## Exercise 5 — Break things deliberately

1. Apply the Deployment with an image tag that doesn't exist (`nginx:doesnotexist`). What happens? Diagnose with `kubectl describe` until you can articulate the failure mode.
2. Apply a Pod with a resource request larger than the node has (e.g., `memory: 8Gi`). What happens? Find the relevant event with `kubectl get events --sort-by=.lastTimestamp`.
3. Apply a NetworkPolicy that blocks egress from the nginx pods. Then try to `kubectl exec` and `curl example.com`. What do you see, and where do you see it?

## Exercise 6 — Persist the kubeconfig safely

Write a short shell script `scripts/fetch-kubeconfig.sh` that:
- SCPs `/etc/rancher/k3s/k3s.yaml` from the EC2.
- Replaces `127.0.0.1` with the public IP.
- Renames the context to `bootcamp`.
- Writes to `~/.kube/config-bootcamp`.

Idempotent. Safe to re-run after EC2 re-creation.

## Deliverables checklist

- [ ] k3s installed via cloud-init (re-creating the EC2 reproduces the cluster).
- [ ] `kubectl get nodes` from your laptop works.
- [ ] You have a written rationale for keeping/disabling each k3s built-in.
- [ ] You can SSH in, find the k3s logs (`journalctl -u k3s -n 100`), and identify common startup phases.
- [ ] No NodePort > 32767, no LoadBalancer Service in the cluster.
