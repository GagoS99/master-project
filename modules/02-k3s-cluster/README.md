# Module 2 — k3s Cluster on EC2

**Time:** ~0.5 week (4-6 hours)
**Free-tier risk:** Low. Same t3.micro as Module 1.
**Working dir:** `infra/terraform/` (cloud-init changes) + remote operations on the EC2.

## Why k3s and not EKS?

EKS control plane = $0.10/hr ≈ $72/month, not free. k3s is a production-grade single-binary Kubernetes distribution (used at the edge, in IoT, in CI). It runs comfortably on a t3.micro for our scale. You will learn real Kubernetes — Deployments, Services, Pods, ConfigMaps, Secrets, Ingress — without the EKS bill.

When you interview for jobs, you can say: "I built and operated a kubeadm/k3s cluster from bare metal. I know what the control plane components do because I started them."

## Learning objectives

1. Install k3s on the EC2 from Module 1 via cloud-init (Terraform-managed).
2. Pull the kubeconfig down to your laptop. Switch contexts safely.
3. Verify the cluster: `kubectl get nodes`, `kubectl get pods -A`.
4. Deploy your first workload: a `nginx` Deployment + Service, by hand-written manifest.
5. Understand what k3s ships with: traefik ingress, local-path storage class, ServiceLB (klipper).
6. Decide which built-ins you'll keep and which to disable.

## What you read

- https://docs.k3s.io/ — quick start, especially the "Server installation" page.
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://kubernetes.io/docs/concepts/services-networking/service/
- https://docs.k3s.io/cli/server — flags to know: `--disable`, `--write-kubeconfig-mode`, `--node-external-ip`.

## What you do

See `exercises.md`.

## How you know you're done

See `validation.md`.
