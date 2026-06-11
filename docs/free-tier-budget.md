# Free-Tier Budget — Line Items

Last checked: 2026-05. AWS free-tier terms change; verify at https://aws.amazon.com/free/ before relying on this.

## Resources we use

| Resource                    | Free-tier allowance (first 12 mo)        | Bootcamp usage           | Risk |
|-----------------------------|------------------------------------------|--------------------------|------|
| EC2 t3.micro / t2.micro     | 750 hrs/month (1 instance 24/7 = 730 hr) | 1 instance, run on demand| Low if torn down |
| EBS gp3 storage             | 30 GB-months                             | 20 GB root volume        | Low  |
| S3 (Terraform state)        | 5 GB + 20k GET + 2k PUT                  | < 10 MB state            | None |
| DynamoDB (TF state lock)    | 25 GB + 25 WCU/RCU always-free           | Single table, minimal IO | None |
| VPC, IGW, route tables      | Always free                              | 1 VPC, 2 subnets         | None |
| Elastic IP                  | Free *only when attached* to a running instance | Detach or release before stopping the EC2 | **Medium — $0.005/hr when unattached** |
| Data transfer OUT           | 100 GB/month always-free (since 2021)    | Light                    | None |
| CloudWatch logs             | 5 GB ingestion + 5 GB storage            | Optional, used in M6     | Low  |

## Resources to AVOID

| Resource                  | Why                                              |
|---------------------------|--------------------------------------------------|
| EKS                       | $0.10/hr control plane = ~$72/mo. We use k3s.    |
| NAT Gateway               | $0.045/hr + data = ~$32/mo. Use public subnet only. |
| ALB / NLB                 | $0.0225/hr + LCU. Use NodePort or k3s ServiceLB. |
| RDS                       | t3.micro has free tier but easy to misconfigure. We run Postgres in-cluster as a StatefulSet. |
| Route 53 hosted zone      | $0.50/mo per zone. Use sslip.io or nip.io.       |

## Session checklist

End of every session:

```sh
./scripts/check-free-tier.sh
```

This script:
- Lists running EC2 instances
- Lists unattached EBS volumes
- Lists unattached Elastic IPs (most common surprise charge)
- Lists any LoadBalancers, NAT Gateways, RDS instances (should be empty)

Walking away for > 48 hours:

```sh
./scripts/destroy-all.sh
```

## Budget alarm — set this on day 1

In AWS Billing → Budgets, create a `$5` monthly budget with email alert at 50% and 100%. Walkthrough in `modules/01-aws-terraform/exercises.md`.
