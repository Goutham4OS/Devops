---
title: 'DevOps From Scratch Navigation Hub'
---

# DevOps From Scratch Navigation Hub

<p class="lead">This page is the text-first reading guide for the repository. Use it when you want a clear study path by role, by layer, or by practical goal without depending only on the visual atlas.</p>

## What This Page Helps You Do

<div class="section-grid">
  <div class="panel-card">
    <div class="icon-chip ops">PATH</div>
    <h3>Choose a starting point</h3>
    <p>Pick foundations, delivery, runtime, cloud, observability, or projects based on what you need right now.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip devops">FLOW</div>
    <h3>Move in a logical order</h3>
    <p>The hub helps you avoid jumping into advanced tools before the lower-layer ideas are stable.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip cloud">LENS</div>
    <h3>Study by role</h3>
    <p>You can use the hub as a DevOps path, a Cloud path, or an SRE path instead of reading everything at once.</p>
  </div>
</div>

## Reading Modes

```mermaid
flowchart TD
  A[Choose your current need] --> B[Foundations and Linux]
  A --> C[Git and CI CD]
  A --> D[Cloud and runtime]
  A --> E[Observability and SRE]
  B --> F[Projects and platform engineering]
  C --> F
  D --> F
  E --> F
```

<p class="diagram-note">If you are unsure where to begin, start with foundations or projects. Foundations give you the model. Projects show you how the model becomes real delivery and runtime work.</p>

## Role-Focused Entry Paths

<div class="role-grid">
  <div class="role-card">
    <div class="icon-chip devops">DV</div>
    <h3>DevOps path</h3>
    <p>Read Foundations, Git, CI CD, Containers, Orchestration, and Security when your focus is safe and fast software delivery.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip cloud">CL</div>
    <h3>Cloud path</h3>
    <p>Read Foundations, Networking, Linux, Cloud, Infra as Code, and Platform Engineering when your focus is architecture and runtime design.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip sre">SR</div>
    <h3>SRE path</h3>
    <p>Read Foundations, Linux, Orchestration, Observability, Security, and Projects when your focus is reliability, incidents, and service behavior.</p>
  </div>
</div>

## Best Starting Pages

<div class="path-grid">
  <div class="path-card">
    <div class="path-step">01</div>
    <h3>Foundations</h3>
    <p>Start here when you want the machine, operating-system, and storage model first.</p>
    <p><a href="./00-foundations/README.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">02</div>
    <h3>Cloud</h3>
    <p>Start here when you want runtime targets, edge flow, and well-architected tradeoffs.</p>
    <p><a href="./12-cloud/README.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">03</div>
    <h3>Observability</h3>
    <p>Start here when your focus is incidents, alerts, telemetry, and reliability loops.</p>
    <p><a href="./10-observability/README.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">04</div>
    <h3>Projects</h3>
    <p>Start here when you want realistic modernization and platform stories first.</p>
    <p><a href="./15-projects/README.html">Open page</a></p>
  </div>
</div>

<div class="callout">
  <span class="mini-kicker">How to use this hub</span>
  <h3>Read with a concrete goal</h3>
  <p>Choose the path that matches your current problem or interview target. That keeps the repository readable and prevents the content from feeling like one giant undifferentiated note dump.</p>
</div>
