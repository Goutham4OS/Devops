# Terraform Learning Guide (Practical + Memorization)

This guide complements `learning.tf` with workflows, diagrams, best practices, and real-world scenarios.

---

## 1) Terraform Mental Model (Cheat Sheet)

**Remember the flow:**
`write -> init -> plan -> apply -> observe -> iterate -> destroy`

**Key files**
- `*.tf` — configuration
- `terraform.tfstate` — current real-world state snapshot
- `.terraform/` — provider plugins + module cache
- `terraform.lock.hcl` — provider dependency lock file

**Fast memory anchor:**
- *Variables in, resources in the middle, outputs out.*

---

## 2) Core Blocks Summary (What/Why)

- **terraform**: CLI settings, backend, required providers.
- **provider**: credentials/region and API settings.
- **variable**: input configuration.
- **local**: computed constants.
- **data**: read existing infra.
- **resource**: manage infrastructure.
- **module**: reusable bundle of resources.
- **output**: expose values.

---

## 3) State: What It Is + How It Works

**State definition (easy memory):**
> *State is Terraform’s memory of what it created and how to map config to real resources.*

### Diagram: State Relationship
```
   .tf config  -----> plan -----> apply
       |                           |
       |                           v
       +---------------------- terraform.tfstate
                                    |
                                    v
                                real resources
```

### Common State Commands
- `terraform state list`
- `terraform state show <addr>`
- `terraform state mv <src> <dst>`
- `terraform state rm <addr>`

### Remote State (Recommended)
**Use remote state for:** collaboration, locking, and recovery.

Example remote backend: S3 + DynamoDB (locking).

---

## 4) Command Workflow (Step-by-step)

### Step 1: Initialize
```
terraform init
```
- Downloads providers
- Configures backend

### Step 2: Validate and Format
```
terraform fmt
terraform validate
```

### Step 3: Plan
```
terraform plan -out=tfplan
```

### Step 4: Apply
```
terraform apply tfplan
```

### Step 5: Observe
```
terraform show
terraform output
```

### Step 6: Change / Destroy
```
terraform plan
terraform apply
terraform destroy
```

---

## 5) Real-World Scenario (Simple Web App)

**Goal:** Deploy a small web tier (SG + EC2) in dev, then prod.

**Steps:**
1. Create `learning.tf` with SG and instance.
2. Configure backend to remote state.
3. Provide variables via `dev.tfvars` and `prod.tfvars`.
4. Use workspaces or multi-env directories (preferred).

**Example apply:**
```
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars
```

---

## 6) Multi-Environment Structure

**Preferred structure (folders per env):**
```
terraform/
  modules/
    vpc/
    app/
  envs/
    dev/
      main.tf
      dev.tfvars
    stage/
      main.tf
      stage.tfvars
    prod/
      main.tf
      prod.tfvars
```

### Why folder-per-env is best
- Clear isolation of state
- Safe changes without accidental cross-environment damage
- Easier to reason about in CI/CD

### Disadvantages of Workspaces
- Easy to apply to wrong workspace
- Harder to isolate state with different backends
- Shared code tends to become complex with conditionals
- Poor visibility in CI unless enforced carefully

---

## 7) Meta-Arguments Quick Guide

- `count`: N copies, index-based (`count.index`)
- `for_each`: map/set-based, stable keys (`each.key`, `each.value`)
- `depends_on`: explicit dependency ordering
- `lifecycle`: `create_before_destroy`, `prevent_destroy`, `ignore_changes`
- `provider`: use provider aliases for multi-region

### count vs for_each (simple memory)
- **count** = *number-based*, use when identical resources.
- **for_each** = *key-based*, use when objects vary or need stable identity.

---

## 8) Drift: What It Is + How to Detect

**Drift definition:**
> *Drift is when real infrastructure changes outside Terraform, making state differ from reality.*

**Detect drift:**
```
terraform plan
```
It shows changes needed to match config.

**Prevent drift:**
- Avoid manual changes
- Use read-only IAM for humans
- Prefer automated pipelines

---

## 9) Secrets Handling (Best Practices)

- Never hardcode secrets in `.tf` files.
- Use environment variables (`TF_VAR_*`) or secret stores.
- For AWS: use SSM Parameter Store or Secrets Manager.
- Mark outputs as `sensitive = true`.

Example output:
```
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

---

## 10) Validation and Testing

- `terraform validate` for syntax and type checks.
- Use `validation` blocks in variables.
- Use `tflint` or `checkov` for policy checks (optional).

---

## 11) Import / Taint / Replace

### Import
Bring existing resources under Terraform management.
```
terraform import aws_instance.web i-0123456789abcdef0
```

### Taint (Deprecated, use replace)
Marks a resource for recreation.
```
terraform apply -replace=aws_instance.web
```

### State Move (Refactor)
```
terraform state mv aws_instance.web aws_instance.web_old
```

---

## 12) Common Issues + Fixes

| Issue | Cause | Fix |
|------|-------|-----|
| Plan shows destroy/create | immutable change | Use `create_before_destroy` or accept replacement |
| Provider auth error | bad creds | check env vars/credentials |
| State lock error | stale lock | `terraform force-unlock <lock_id>` |
| Drift detected | manual changes | re-apply or import |

---

## 13) Functions (Quick Reference)

- `merge(map1, map2)`
- `join(",", list)`
- `toset(list)`
- `length(list)`
- `regex(pattern, string)`
- `try(a, b, c)`
- `coalesce(a, b)`
- `lookup(map, key, default)`

---

## 14) Mind Map (Text)

```
Terraform
├── Write
│   ├── variables
│   ├── locals
│   ├── resources
│   └── modules
├── Init
│   ├── providers
│   └── backend
├── Plan
│   └── diff
├── Apply
│   └── state update
├── Observe
│   ├── outputs
│   └── state show
├── Maintain
│   ├── drift detect
│   └── refactor state
└── Multi-env
    ├── folders
    └── workspaces (avoid)
```

---

## 15) Easy-to-Remember Cheat Sheet

**Rules of thumb:**
- Use **modules** to reuse infra.
- Use **for_each** when identity matters.
- Keep **state remote** with locking.
- Separate **dev/stage/prod** by folder.
- Never commit secrets.

**Mini checklist before apply:**
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- Confirm workspace or env folder

---

## 16) Suggested File Layout (Beginner)

```
terraform/
  learning.tf
  envs/
    dev.tfvars
    stage.tfvars
    prod.tfvars
```

---

## 17) Definitions to Remember (Flash Cards)

- **State:** Terraform’s memory of managed resources.
- **Drift:** Real resources differ from state/config.
- **Plan:** Execution preview.
- **Module:** Reusable Terraform unit.
- **Provider:** API plugin to manage resources.
