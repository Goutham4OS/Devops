# Terraform Remote Backend (AzureRM)

This repo is configured to use an AzureRM remote backend.

## What you must provide
Edit `backend.hcl` and set these values from your already-created backend resources:

- `resource_group_name`: resource group that contains the state storage account
- `storage_account_name`: storage account used for Terraform state
- `container_name`: blob container for state files
- `key`: blob name/path for this environment state file (example: `dev/terraform.tfstate`)

## Initialize
```bash
terraform init -backend-config=backend.hcl
```

If Terraform was already initialized with local state, migrate it:

```bash
terraform init -migrate-state -backend-config=backend.hcl
```
