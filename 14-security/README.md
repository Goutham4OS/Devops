---
title: 'Security'
---

# Security

<p class="lead">Security in this repository is focused on the delivery path and runtime path together. The goal is to make secure defaults, supply chain trust, and runtime guardrails understandable from a platform point of view.</p>

## What This Section Helps You See

<div class="section-grid">
  <div class="panel-card">
    <div class="icon-chip ops">TRUST</div>
    <h3>Security as a path</h3>
    <p>Good security is built across code, build, registry, deployment, runtime, and monitoring rather than added at the end.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip devops">SHIFT</div>
    <h3>Why shift-left is not enough alone</h3>
    <p>Scanning earlier helps, but runtime controls, identity boundaries, and supply-chain trust still matter after deployment.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip cloud">GUARD</div>
    <h3>Where platform defaults matter</h3>
    <p>This section helps with secret handling, policy, container risk, software trust, and secure release paths.</p>
  </div>
</div>

## Trust Path

```mermaid
flowchart LR
  A[Code] --> B[Scan and review]
  B --> C[Build and sign]
  C --> D[Registry and promotion]
  D --> E[Deploy with policy]
  E --> F[Runtime guardrails and monitoring]
```

<p class="diagram-note">The strongest security posture is built when each stage of the path increases trust or limits blast radius.</p>

## Why It Matters by Role

<div class="role-grid">
  <div class="role-card">
    <div class="icon-chip devops">DV</div>
    <h3>For DevOps engineers</h3>
    <p>This section helps place policy and trust controls directly into delivery flow without losing too much speed.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip cloud">CL</div>
    <h3>For cloud engineers</h3>
    <p>This section helps connect identity, secrets, policy, and service usage to safer platform architecture.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip sre">SR</div>
    <h3>For SREs</h3>
    <p>This section helps think about blast radius, runtime abuse, secure recovery, and production guardrails under pressure.</p>
  </div>
</div>

## Reading Path

<div class="path-grid">
  <div class="path-card">
    <div class="path-step">01</div>
    <h3>DevSecOps Supply Chain</h3>
    <p>Start with the delivery-path view of software trust and integrity.</p>
    <p><a href="./devsecops-supply-chain.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">02</div>
    <h3>Privileged Containers Threat Model</h3>
    <p>Connect container runtime behavior to real security boundaries.</p>
    <p><a href="../Basics/3.3.privileged_containers_threat_model.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">03</div>
    <h3>CI CD Security at Scale</h3>
    <p>See how enterprise delivery systems become security control points.</p>
    <p><a href="../Basics/CD/Github/ci_cd_security_sap_scale_wiki.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">04</div>
    <h3>Software Delivery Map</h3>
    <p>Revisit the delivery flow through a security and trust lens.</p>
    <p><a href="../09-ci-cd/software-delivery-map.html">Open page</a></p>
  </div>
</div>

<div class="callout">
  <span class="mini-kicker">How to use this section</span>
  <h3>Treat security as an operating model</h3>
  <p>The most useful reading habit here is to ask how trust is maintained from commit to runtime. That keeps security grounded in platform behavior instead of turning it into a disconnected checklist.</p>
</div>

