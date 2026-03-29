# Terraform environments

Environment-specific variable files are organized into dedicated folders:

- `environments/dev/terraform.tfvars`
- `environments/stage/terraform.tfvars`
- `environments/prod/terraform.tfvars`

## Usage

Run Terraform with the variable file for the target environment:

```bash
terraform init
terraform plan  -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

Replace `dev` with `stage` or `prod` as needed.

A root `terraform.tfvars` is kept as a default/local fallback (aligned with `dev`).
