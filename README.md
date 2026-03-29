---
title: 'DevOps From Scratch'
---

# DevOps From Scratch

<p class="lead">This site is a guided journey from machines to modern platforms. The goal is to help DevOps, Cloud, and SRE engineers understand not only what a tool does, but why it exists, where it breaks, and how it fits into the full operating model.</p>

## What This Site Optimizes For

<div class="section-grid">
  <div class="panel-card">
    <div class="icon-chip ops">MAP</div>
    <h3>One connected story</h3>
    <p>Foundations, delivery, runtime, cloud, reliability, and platform engineering are taught as one sequence instead of disconnected notes.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip devops">WHY</div>
    <h3>DevOps-first framing</h3>
    <p>Each topic is tied back to delivery speed, safe change, runtime behavior, and operational tradeoffs.</p>
  </div>
  <div class="panel-card">
    <div class="icon-chip cloud">RUN</div>
    <h3>Cloud and SRE relevance</h3>
    <p>The site keeps connecting low-level concepts to cloud design, incident response, observability, and platform decisions.</p>
  </div>
</div>

## Platform Story

```mermaid
flowchart LR
  A[Machines and OS] --> B[Linux and networking]
  B --> C[Git and CI CD]
  C --> D[Containers and Kubernetes]
  D --> E[Cloud runtime and security]
  E --> F[Observability and SRE]
  F --> G[Platform engineering and projects]
```

<p class="diagram-note">Read the repository from left to right when you want a full-stack mental model. Jump into projects first when you want practical stories, then come back to the layers underneath.</p>

## Why It Matters by Role

<div class="role-grid">
  <div class="role-card">
    <div class="icon-chip devops">DV</div>
    <h3>For DevOps engineers</h3>
    <p>This site helps connect build, test, release, runtime, and rollback work into one delivery system instead of a set of separate tools.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip cloud">CL</div>
    <h3>For cloud engineers</h3>
    <p>This site helps connect managed services, networking, identity, runtime choices, and platform tradeoffs back to the system behaviors underneath.</p>
  </div>
  <div class="role-card">
    <div class="icon-chip sre">SR</div>
    <h3>For SREs</h3>
    <p>This site helps connect change risk, latency, bottlenecks, incident response, and observability to the layers that actually create them.</p>
  </div>
</div>

## Best Entry Points

<div class="path-grid">
  <div class="path-card">
    <div class="path-step">01</div>
    <h3>Interactive Journey Map</h3>
    <p>Use the visual atlas when you want the whole platform story in one screen.</p>
    <p><a href="./index.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">02</div>
    <h3>Navigation Hub</h3>
    <p>Use the structured path when you want a cleaner reading route through the repository.</p>
    <p><a href="./navigation.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">03</div>
    <h3>From Computers to Cloud</h3>
    <p>Start here when cloud feels abstract and you want the lower-layer story first.</p>
    <p><a href="./00-foundations/from-computers-to-cloud.html">Open page</a></p>
  </div>
  <div class="path-card">
    <div class="path-step">04</div>
    <h3>VM to AKS Modernization Story</h3>
    <p>Start here when you prefer realistic project narratives over isolated concept notes.</p>
    <p><a href="./15-projects/vm-to-aks-modernization-story.html">Open page</a></p>
  </div>
</div>

<div class="callout">
  <span class="mini-kicker">How to use this site</span>
  <h3>Pick a path, not a random page</h3>
  <p>If you are building foundations, start with the story pages and section landing pages. If you are solving a real problem at work, jump to the closest section, then use the new previous and next navigation to move backward into fundamentals and forward into runtime, cloud, or SRE impact.</p>
</div>
