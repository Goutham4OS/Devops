---
title: 'CI CD'
---

# CI CD

<p class="lead">CI CD is the delivery engine that turns change into tested, scanned, packaged, promoted, and reversible releases. This section is built around flow, safety, and scale rather than around pipeline YAML alone.</p>

## What This Section Helps You See

<div class="section-grid">
  <div class="panel-card">
    <div class="icon-chip ops">FLOW</div>
    <h3>The full change path</h3>
    <p>Good pipelines connect commit, build, test, scan, artifact creation, deployment, verification, and rollback as one system.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip devops">SAFE</div>
    <h3>Why speed needs control</h3>
    <p>The best delivery systems do not only move fast. They make change reviewable, measurable, and safer in production.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip cloud">EDGE</div>
    <h3>Where cloud enters the picture</h3>
    <p>Registries, OIDC, runtime targets, and promotion strategies all connect CI CD directly to the cloud runtime story.</p>
  </div>
</div>

## Change to Production Flow

```mermaid
flowchart LR
  A[Commit] --> B[Build]
  B --> C[Test and scan]
  C --> D[Artifact or image]
  D --> E[Deploy or promote]
  E --> F[Verify and rollback if needed]
```

<p class="diagram-note">The main idea is simple: every stage should either increase trust or reduce risk before the change reaches production.</p>

## Why It Matters by Role

<div class="role-grid">
  <div class="role-card">
    <div class="icon-chip devops">DV</div>
    <h3>For DevOps engineers</h3>
    <p>This section helps you design pipelines that balance feedback speed, release confidence, and operational safety.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip cloud">CL</div>
    <h3>For cloud engineers</h3>
    <p>This section helps connect registries, identities, runtime targets, and environment promotion to the wider architecture.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip sre">SR</div>
    <h3>For SREs</h3>
    <p>This section helps explain how release quality, verification, and rollback paths directly influence reliability.</p>
  </div>
</div>

## Reading Path

<div class="path-grid">
  <div class="path-card">
    <div class="path-step">01</div>
    <h3>Software Delivery Map</h3>
    <p>Start with the big-picture delivery flow before going into pipeline details.</p>
    <p><a href="./software-delivery-map.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">02</div>
    <h3>CI Foundations</h3>
    <p>Review the conceptual pipeline model before deeper enterprise examples.</p>
    <p><a href="../basics/6.0.0.CI.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">03</div>
    <h3>Continuous Delivery and Deployment</h3>
    <p>Study the promotion path from successful builds to controlled release.</p>
    <p><a href="../basics/CI/2.continuous_delivery_deployment_wiki.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">04</div>
    <h3>Enterprise GitHub Actions Project</h3>
    <p>See how the model works in a more realistic enterprise-scale example.</p>
    <p><a href="../basics/CD/Github/Enterprise_CICD_GitHubActions_OIDC_Kubernetes_Project.html">Open page</a></p>
  </div>
</div>

<div class="callout">
  <span class="mini-kicker">How to use this section</span>
  <h3>Read pipelines as systems, not only YAML</h3>
  <p>Focus on trust boundaries, promotion points, rollback paths, and runtime verification. Those ideas matter more than the exact CI tool syntax.</p>
</div>
