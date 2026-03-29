---
title: 'DevOps to Platform to SRE Learning Journey'
---

# DevOps to Platform to SRE Learning Journey

This page explains how to grow from basics to advanced work without skipping the foundations.

## Stage 1: Build the core base

### Topics
- computer basics
- Linux
- networking
- storage and filesystems
- Git
- scripting

### Why it matters
These topics explain what actually happens under VMs, containers, cloud runtimes, and CI/CD systems.

### Repo anchors
- [00-foundations](../00-foundations/)
- [01-networking](../01-networking/)
- [02-linux](../02-linux/)
- [03-programming](../03-programming/)
- [04-git](../04-git/)

## Stage 2: Become a solid DevOps engineer

### Topics
- CI/CD design
- artifact management
- container basics
- cloud basics
- infrastructure as code
- deployment and rollback
- observability basics

### Why it matters
This is where you stop operating servers manually and start designing reliable delivery systems.

### Repo anchors
- [07-containers](../07-containers/)
- [09-ci-cd](../09-ci-cd/)
- [11-infra-as-code](../11-infra-as-code/)
- [12-cloud](../12-cloud/)
- [10-observability](../10-observability/)

## Stage 3: Move into cloud and platform engineering

### Topics
- cloud architecture patterns
- identity and network design
- AKS and Kubernetes operations
- managed versus self-hosted tradeoffs
- reusable Terraform modules
- golden paths and platform templates
- policy and guardrails

### Why it matters
This is the shift from operating single workloads to building a platform other teams can trust.

### Repo anchors
- [Cloud architecture and well-architected review](../12-cloud/cloud-architecture-and-well-architected.html)
- [08-orchestration](../08-orchestration/)
- [11-infra-as-code](../11-infra-as-code/)
- [13-platform-engineering](../13-platform-engineering/)

## Stage 4: Grow into SRE thinking

### Topics
- SLI and SLO design
- incident response
- error budgets
- release risk management
- capacity planning
- failure testing
- toil reduction

### Why it matters
The platform is not successful just because it deploys. It is successful when production behavior is measurable, supportable, and resilient.

### Repo anchors
- [10-observability](../10-observability/)
- [observability-and-sre-loop.md](../10-observability/observability-and-sre-loop.html)
- [vm-to-aks-modernization-story.md](./vm-to-aks-modernization-story.html)

## Role view

### DevOps engineer
Focus on:
- delivery pipelines
- Linux and networking
- containers and runtime basics
- IaC and environment setup
- cloud operational basics

### Cloud or platform engineer
Focus on:
- platform architecture
- AKS and runtime standards
- reusable modules and templates
- security and guardrails
- managed-service decisions

### SRE
Focus on:
- reliability metrics and production risk
- alert quality and response workflow
- capacity and dependency behavior
- reducing toil through engineering

## The practical rule

Do not try to learn AKS first and foundations later.

A stronger path is:
1. understand the base systems
2. learn delivery and cloud operations
3. standardize runtime and platform patterns
4. learn reliability engineering on top of real production systems

