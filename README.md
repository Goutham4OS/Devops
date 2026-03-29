---
title: 'DevOps From Scratch'
---

# DevOps From Scratch

This repository is becoming a story-first learning platform for DevOps, Cloud, SRE, and Platform Engineering.

The direction is simple:
1. start from how computers, operating systems, and networks work
2. show how teams build and ship software safely
3. explain how platforms run in Kubernetes, VMs, and private cloud
4. connect delivery with reliability, security, observability, and platform engineering

## Start Here

- [Interactive journey map](./index.html)
- [Navigation hub](./navigation.html)
- [Real story: from VMs to AKS and platform operations](./15-projects/vm-to-aks-modernization-story.html)
- [Roadmap](./roadmap.html)
- [Migration map](./migration-map.html)
- [Diagram library](./assets/diagrams/README.html)

## Target Information Architecture

```text
00-foundations
01-networking
02-linux
03-programming
04-git
05-databases
06-servers
07-containers
08-orchestration
09-ci-cd
10-observability
11-infra-as-code
12-cloud
13-platform-engineering
14-security
15-projects
assets/diagrams
```

## Story We Want the Site to Tell

### Phase 1: Foundations
- How machines became computers
- CPU, memory, storage, boot, operating systems
- Linux, networking, and programming basics

### Phase 2: Modern Delivery
- Agile requirements and developer workflow
- Git, branching, pull requests, and review best practices
- CI, quality gates, test automation, artifact creation
- DevSecOps controls such as SAST, secret scanning, IaC scanning, SBOM, and image signing

### Phase 3: Runtime and Cloud
- Registries such as ACR and deployment targets such as Kubernetes, VMs, and private cloud
- Traffic path from users and partners through DNS, CDN, WAF, load balancer, ingress, API gateway, and NGINX
- Application, cache, queue, object storage, and database runtime concerns
- Cloud architecture, well-architected thinking, and system design tradeoffs

### Phase 4: Reliability and Platforms
- Monitoring, logging, tracing, alerting, SLIs, SLOs, and incident response
- IaC, policy, guardrails, golden paths, self-service, and internal platform engineering

## What This Pass Adds

- A new landing experience focused on the end-to-end story instead of a loose tool catalog
- New section folders with landing pages
- Focused high-level diagram pages that we can deepen later
- A migration map so the existing content stays connected while we reorganize
- Real story pages for VM to AKS modernization, cloud architecture, and role progression

## Existing Content Is Still Valuable

The current folders such as `CS`, `basics`, `Git`, `K8s`, `terraform`, `cloud-networking`, and `todo` contain good raw material. In this pass, they are not deleted or moved. They are mapped into the new structure so we can migrate safely.

## Suggested Next Build Steps

1. Expand each new section with lesson pages and labs.
2. Move existing source files into the new folders in small batches.
3. Replace TODO pages with narrative chapters and detailed architecture walkthroughs.
4. Publish the new landing experience through GitHub Pages.
