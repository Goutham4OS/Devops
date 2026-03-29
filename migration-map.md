# Migration Map

This file keeps the old content and the new structure synced.

| Existing location | New home | Notes |
| --- | --- | --- |
| `CS/Machines to computers` | `00-foundations` | Computer history, CPU, memory, boot flow |
| `CS/Disk` | `00-foundations` | Storage and file system basics |
| `CS/Virtual_Memory` | `00-foundations` | Memory management foundations |
| `basics/1.AgileScrumDevops.md` | `00-foundations` | Good early context for how teams work |
| `cloud-networking/*` | `01-networking` and `12-cloud` | Split core networking from cloud edge topics |
| `basics/3.0.*` to `3.7.*` | `02-linux` | Linux, filesystems, cgroups, processes |
| `Python/*` | `03-programming` | Automation and scripting content |
| `Git/*` and `todo/05-version-control-before-git.todo.md` | `04-git` | Git history, workflows, branching, PRs |
| `DB/*`, `CS/Database/*`, `basics/4.*` | `05-databases` | Merge duplicated database content carefully |
| `Server/WebServer/Ngnix.md` | `06-servers` | Reverse proxy and web serving layer |
| `basics/3.docker.md` and `todo/04-containers-docker.todo.md` | `07-containers` | Container origin story and image lifecycle |
| `K8s/*` and `basics/5.k8s` | `08-orchestration` | Kubernetes, Helm, and service runtime |
| `basics/CI/*`, `basics/CD/Github/*`, `.github/workflows/*` | `09-ci-cd` | CI/CD, GitHub Actions, GitOps, release flow |
| No strong current home | `10-observability` | Add new content here first |
| `terraform/*` | `11-infra-as-code` | Modules, state, environment model |
| `onprem/*`, `todo/01-*`, `todo/02-*` | `12-cloud` | Cloud migration and runtime evolution |
| `basics/2.Platformengineering.md` | `13-platform-engineering` | Good seed for IDP and golden path content |
| `basics/3.3.*`, `ci_cd_security_*` | `14-security` | DevSecOps, container security, policy |
| `todo/03-*` and future capstones | `15-projects` | Migration scenarios and end-to-end labs |

## Migration Rules

1. Do not move everything at once.
2. Keep links alive while pages are being rewritten.
3. Prefer creating a new cleaned page, then back-link to the original source.
4. Replace TODO files with narrative chapters before deleting the placeholders.
5. Treat CI/CD, security, runtime, and observability as first-class stories, not side notes.
