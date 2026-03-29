# From Computers to Cloud

This page is the foundation story for the whole repository.

## Big Picture

```mermaid
flowchart LR
    A[Early machines] --> B[CPU, memory, storage]
    B --> C[Operating systems]
    C --> D[Networking and the web]
    D --> E[Programming and automation]
    E --> F[Servers and databases]
    F --> G[Containers]
    G --> H[Kubernetes]
    H --> I[Cloud platforms]
    I --> J[SRE and platform engineering]
```

## Why this matters for DevOps

- DevOps engineers troubleshoot across layers, not inside one tool only.
- Cloud abstractions still sit on top of compute, storage, and networking reality.
- SRE and platform engineering make more sense when the lower layers are clear.

## Current source material

- [CS/Machines to computers](../CS/Machines%20to%20computers/)
- [CS/Disk](../CS/Disk/)
- [CS/Virtual_Memory](../CS/Virtual_Memory/)
- [basics/3.0.LinuxOSIntro.md](../basics/3.0.LinuxOSIntro.md)

## What to build next

1. A proper chapter on computer history and boot flow.
2. A chapter connecting Linux internals to containers and Kubernetes.
3. A chapter showing how cloud services map back to foundational concepts.
