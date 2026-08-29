# AWS EKS Platform

The AWS build of the same architecture as `../5_azure-aks-platform`:

```text
Empty AWS Account
        |
VPC + public/private subnets, NAT   (modules/network)
        |
CloudWatch log group                (modules/monitoring)
        |
ECR                                 (modules/ecr)
        |
EKS (IRSA-enabled, ECR pull)        (modules/eks)
        |
Secrets Manager + IRSA role         (modules/security)
        |
RDS for PostgreSQL                  (modules/database)
        |
Route 53 + ACM (TLS cert)           (modules/dns_tls)
```

## Module dependency order

`network` -> `monitoring` (log group pre-created so retention is
controlled, rather than left at "never expire" by EKS's implicit creation)
-> `eks` (depends on the log group existing first via an explicit
`depends_on`, and on the VPC's subnets) -> `security` (needs the cluster's
OIDC provider to trust IRSA role assumption) -> `database` (needs the EKS
cluster's security group ID to scope ingress) -> `dns_tls` (independent).

## Where Terraform's job ends

The ALB and its TLS termination are **not** created here. `modules/dns_tls`
validates an ACM certificate and stops - the AWS Load Balancer Controller,
installed via Helm/Argo CD *inside* the cluster, provisions the actual ALB
when it sees an Ingress annotated with `alb.ingress.kubernetes.io/
certificate-arn` pointing at this cert. Terraform hands the cluster a
trusted identity and a validated cert; the cluster owns routing.

## Interview talking points this project exercises

- **Modules**: one module per AWS service, each with its own
  variables/outputs - the same pattern as the Azure build, so the two
  projects are directly comparable service-for-service.
- **Remote state + locking**: `providers.tf` backend block - an S3 bucket
  plus `use_lockfile = true` gives native locking on Terraform >= 1.10
  without a separate DynamoDB table (older Terraform still needs one -
  worth mentioning both in interview since AWS shops often have legacy
  DynamoDB-locked state around).
- **IRSA vs static keys**: `modules/eks` creates the OIDC provider,
  `modules/security` creates a role trusted by it and scoped to exactly one
  secret - the pattern to contrast against Azure's workload identity
  federation when asked "how do these differ across clouds?" (answer:
  conceptually identical - a pod's token exchanges for a cloud-native
  credential via OIDC federation - just different resource names).
- **Environment separation**: separate state key + tfvars per environment
  (`dev.tfstate`/`dev.tfvars`, etc.), same reasoning as the Azure build.
- **Secrets**: `db_password` is `sensitive`, no default, injected via
  `TF_VAR_db_password`. Application secrets live in Secrets Manager, read
  through IRSA (External Secrets Operator), not baked into a Kubernetes
  Secret manifest in Git.
- **Drift**: a security group rule added by hand in the console shows up on
  the next `plan` as something Terraform wants to remove.
- **Import**: `terraform import module.network.aws_vpc.this vpc-0123456789`
  brings a hand-created VPC under management.
- **A gotcha worth mentioning in interview**: pre-creating the CloudWatch
  log group before enabling `enabled_cluster_log_types` on the cluster -
  if you let EKS create it implicitly, you can't set retention on it
  without a second apply importing that group into state first.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
export TF_VAR_db_password="<generate-one>"

terraform init   # -backend-config=backend-dev.hcl once you have a real backend
terraform plan
terraform apply

aws eks update-kubeconfig --region $(terraform output -raw region 2>/dev/null || echo eu-north-1) \
  --name $(terraform output -raw eks_cluster_name)
```

## Azure equivalents

See `../5_azure-aks-platform/README.md` for the full mapping table. Short
version: VPC->VNet, EKS->AKS, ECR->ACR, Secrets Manager->Key Vault,
IRSA->Workload Identity, RDS->Flexible Server, Route 53+ACM->Azure DNS +
cert-manager, CloudWatch->Log Analytics/Container Insights.
