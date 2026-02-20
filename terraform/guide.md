# Terraform Learning Guide (Practical + Memorization)

This guide complements `learning.tf` with workflows, diagrams, best practices, real-world scenarios, and memory aids.

---

## 1) Terraform Mental Model (Cheat Sheet)

**Remember the flow:**
`write -> init -> plan -> apply -> observe -> iterate -> destroy`

**Memory hook (W-I-P-A-O-I-D):** *Write it, Init it, Plan it, Apply it, Observe it, Iterate, Destroy if needed.*

**Key files**
- `*.tf` — configuration
- `terraform.tfstate` — current real-world state snapshot
- `.terraform/` — provider plugins + module cache
- `terraform.lock.hcl` — provider dependency lock file
- `.terraform.tfstate.lock.info` — lock metadata when using a backend with locking

**Fast memory anchor:**
- *Variables in, resources in the middle, outputs out.*

**“3-Layer Cake” mnemonic:**
```
Inputs (variables)  ->  Logic (locals + resources + modules)  ->  Outputs
```

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

**Memory phrase (TPV LDRMO):** *“Terraform Providers Verify, Locals Data Resources Modules Outputs.”*

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

### Local Backend (Default)
**Local backend** stores `terraform.tfstate` on disk in the working directory. It is the default if no backend is configured.
**Pros:** simple, great for learning.  
**Cons:** no collaboration/locking, easy to lose or overwrite.

### Remote State (Recommended)
**Use remote state for:** collaboration, locking, and recovery.

Example remote backend: S3 + DynamoDB (locking).

### State Corruption: What It Looks Like + Recovery
**Symptoms:** `state snapshot was created by Terraform vX`, JSON parse errors, resources missing from state.  
**Recovery checklist:**
1. **Stop** and back up the current state file.  
2. If using remote state, check backend health and version.  
3. Restore from a prior backup if available.  
4. Re-import missing resources (`terraform import`).  
5. Run `terraform plan` to verify drift and reconciliation.

---

## 4) Command Workflow (Step-by-step)

### Step 1: Initialize
```
terraform init
```
- Downloads providers
- Configures backend
- Creates `.terraform/` and `.terraform.lock.hcl`

### Step 2: Validate and Format
```
terraform fmt
terraform validate
```
**Remember:** *fmt first, validate second.*

### Step 3: Plan
```
terraform plan -out=tfplan
```
**Tip:** use `-var-file` for per-environment inputs.

### Step 4: Apply
```
terraform apply tfplan
```
**Tip:** `terraform apply -auto-approve` for CI (use carefully).

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

### Most-Used CLI Commands (Quick Recall)
- `terraform init` — initialize project
- `terraform validate` — static validation
- `terraform fmt` — format config
- `terraform plan` — preview changes
- `terraform apply` — create/update
- `terraform destroy` — tear down
- `terraform output` — show outputs
- `terraform show` — show state/plan
- `terraform providers` — provider tree
- `terraform graph` — DOT graph
- `terraform state ...` — manage state
- `terraform workspace ...` — manage workspaces
- `terraform import` — bring existing resources under Terraform

**Memory hook:** *“I V F P A D O S P G S W I”*  
(Init, Validate, Fmt, Plan, Apply, Destroy, Output, Show, Providers, Graph, State, Workspace, Import)

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

### “Scaffold” a Project (Terraform Has No Built-in Generator)
Terraform doesn’t provide a built-in project generator like `helm create`.
Instead, use a **starter layout**:
```
terraform/
  main.tf
  variables.tf
  outputs.tf
  versions.tf
  providers.tf
  envs/
    dev.tfvars
    prod.tfvars
```
**Tip:** Create your own internal template repo for teams and clone it to start new projects.

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

**Mnemonic:** *Count = clone by number, For_each = clone by key.*

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

**Extra hardening:**
- Use `.tfvars` files that are git-ignored.
- Use `sensitive = true` on variables, too.
- Consider using CI secrets to inject variables during plan/apply.

---

## 10) Validation and Testing

- `terraform validate` for syntax and type checks.
- Use `validation` blocks in variables.
- Use `tflint` or `checkov` for policy checks (optional).

**Validation memory hook:** *validate config, validate inputs, validate policy.*

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

### Force Unlock (When Lock is Stuck)
```
terraform force-unlock <lock_id>
```

---

## 12) Common Issues + Fixes

| Issue | Cause | Fix |
|------|-------|-----|
| Plan shows destroy/create | immutable change | Use `create_before_destroy` or accept replacement |
| Provider auth error | bad creds | check env vars/credentials |
| State lock error | stale lock | `terraform force-unlock <lock_id>` |
| Drift detected | manual changes | re-apply or import |
| State corruption | file edited or broken | restore backup or re-import |

---

## 13) Functions (Quick Reference)

### Common Functions + Examples
- `merge(map1, map2)` → `merge({a=1},{b=2})`
- `join(",", list)` → `join(",", ["a","b"])` => `"a,b"`
- `toset(list)` → `toset(["a","a"])` => `["a"]`
- `length(list)` → `length(["a","b"])` => `2`
- `regex(pattern, string)` → `regex("^[a-z]+$", "dev")`
- `try(a, b, c)` → `try(var.maybe, "fallback")`
- `coalesce(a, b)` → first non-null value
- `lookup(map, key, default)` → safe map lookup
- `format("%s-%s", var.env, "web")`
- `lower("Prod")` => `"prod"`
- `replace("prod-db", "-", "_")` => `"prod_db"`

### Remember Functions Fast
**Group them:**
- **Lists/Sets:** `length`, `join`, `toset`
- **Maps:** `merge`, `lookup`
- **Strings:** `format`, `lower`, `replace`, `regex`
- **Fallbacks:** `try`, `coalesce`

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

### ASCII Diagram: Config to State to Reality
```
Variables -> Resources -> Outputs
     \          |           /
      \         |          /
       +------ State ------+
               |
               v
          Real Infrastructure
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

**One-liner memory:** *“Format, Validate, Plan, Apply.”*

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

**More complete layout:**
```
terraform/
  versions.tf
  providers.tf
  variables.tf
  main.tf
  outputs.tf
  modules/
  envs/
```

---

## 17) Definitions to Remember (Flash Cards)

- **State:** Terraform’s memory of managed resources.
- **Drift:** Real resources differ from state/config.
- **Plan:** Execution preview.
- **Module:** Reusable Terraform unit.
- **Provider:** API plugin to manage resources.
- **Backend:** Where state is stored (local or remote).
