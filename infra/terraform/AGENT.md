# AGENT.md — `infra/terraform/`

Module 1 output lives here. The engineer is learning Terraform fundamentals plus AWS networking.

## Expected final structure (engineer must build it, not you)

```
terraform/
├── backend.tf              # S3 + DynamoDB remote state
├── providers.tf            # AWS provider config
├── versions.tf             # required_version + required_providers
├── variables.tf            # input vars
├── outputs.tf              # public IP, kubeconfig hint
├── main.tf                 # composition (calls modules)
├── modules/
│   ├── vpc/                # VPC, subnets, IGW, route tables
│   ├── ec2/                # security group, EC2 instance, EIP (optional)
│   └── iam/                # instance profile for the EC2
└── environments/
    └── dev/
        └── terraform.tfvars
```

## Hint ladder calibration for this dir

- **L1 concept:** "You're describing what — the VPC, subnets, route tables. Sketch it on paper first."
- **L2 pointer:** "Terraform registry: `terraform-aws-modules/vpc/aws`. Read the inputs and outputs before deciding to use it or roll your own."
- **L3 example:** "In a typical 2-AZ public-only VPC, you'd have: 1 VPC, 2 public subnets, 1 IGW, 1 route table with 0.0.0.0/0 → IGW, subnet associations. We only need 1 AZ."
- **L4 shape:** sketch the resource graph as a list, no HCL.
- **L5 draft:** only on "I'm stuck, draft it."

## Things to push back on

- Using `terraform-aws-modules/vpc/aws` without understanding what it generates. Engineer should read the module source at least once.
- Hard-coding the AMI ID. Use `data.aws_ami` with filters.
- Skipping `terraform fmt` and `terraform validate`.
- Committing `.terraform/` or `*.tfstate*`.
- Defining the S3 backend bucket *in* the same Terraform that uses the backend. Chicken-and-egg — bucket gets created by a separate bootstrap step or by hand once.

## Free-tier red flags

If you see any of these in the engineer's HCL, stop and ask:

- `aws_nat_gateway`
- `aws_lb` / `aws_lb_target_group` / `aws_lb_listener`
- `aws_eks_*`
- `aws_db_instance`
- `instance_type` that is not `t3.micro` or `t2.micro` (in us-east-1, t3.micro is free-tier eligible)
- `aws_eip` that isn't attached to a running instance

## Validation hints (Module 1 exit)

The engineer should be able to:
- Run `terraform plan` and explain every "+ create" line.
- SSH to the EC2 via its public IP (or session manager) on port 22.
- Show `terraform state list` and explain each resource.
- Destroy with `terraform destroy` and re-create idempotently.
