# Module 2 — Validation

## Hard gates

- [ ] From laptop: `kubectl get nodes` returns `Ready` for 1 node.
- [ ] From laptop: `kubectl get pods -A` shows only system pods (coredns, metrics-server, local-path-provisioner) plus what you deployed.
- [ ] You can delete the EC2 via `terraform destroy` and recreate via `terraform apply`, and end up with a working cluster again — same cloud-init.
- [ ] `kubectl describe node` shows the right CPU/memory capacity for t3.micro (~1 vCPU, ~1 GiB).
- [ ] Your scratch nginx Deployment from exercise 4 has been *deleted* — `kubectl get all` shows only system resources.

## Concept gates

You can explain, without looking it up:

- What the kubeconfig file contains and what each section is for.
- The difference between Deployment, ReplicaSet, and Pod.
- The difference between Service types: ClusterIP, NodePort, LoadBalancer, ExternalName.
- Why `kubectl describe pod` is your first move when a Pod is `Pending` or `CrashLoopBackOff`.
- What CoreDNS does in the cluster.
- Why we don't have an Ingress controller yet, and what we'd add if we wanted one.

## Done-when

- Cluster is up, cluster has zero workloads of your own running.
- You can `ssh devvm` and run `sudo systemctl restart k3s` and watch it come back via `journalctl -u k3s -f`.
