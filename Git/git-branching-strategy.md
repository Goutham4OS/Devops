# Git Branching Strategies - Complete Visual Guide

> 🎯 **Purpose**: Easy-to-understand guide with visual diagrams for choosing and implementing Git branching strategies

---

## 📊 Quick Revision Table

| Strategy | Complexity | Best For | Release Cadence | Branch Types | CI/CD Need | Feature Flags |
|----------|------------|----------|-----------------|--------------|------------|---------------|
| **Git Flow** | 🔴 High | Enterprise, Mobile Apps, Versioned Software | Scheduled (Monthly/Quarterly) | 5 (main, develop, feature, release, hotfix) | Optional | No |
| **GitHub Flow** | 🟢 Low | SaaS, Startups, Open Source | Continuous | 2 (main, feature) | Recommended | Optional |
| **GitLab Flow** | 🟡 Medium | QA-heavy workflows, Staging needs | Continuous | 3-4 (main, feature, staging, production) | Required | Optional |
| **Trunk-Based** | 🟢 Low | High-velocity teams, Big Tech | Continuous (multiple/day) | 1-2 (main, short-lived) | Critical | Yes |

---

## 🤔 Why Branching Strategies Matter?

```mermaid
mindmap
  root((Branching Strategy))
    Isolation
      Developers work independently
      No code overwrites
    Quality Gates
      Code review
      Automated testing
      Approvals
    Release Control
      Ship specific features
      When you want
    Hotfix Paths
      Fix bugs fast
      Without unfinished work
    Audit Trails
      Track changes
      Know who approved
```

### ❌ Without a Strategy
- Developers overwrite each other's work
- Untested code reaches production
- Releases become stressful
- Nobody knows which branch is stable

### ✅ With a Strategy
- Clear rules for code flow
- Predictable releases
- Quick bug fixes
- Happy teams

---

## 1️⃣ Git Flow

> **Best For**: Enterprise projects, Mobile apps, Software with scheduled releases

```mermaid
gitGraph
    commit id: "Initial"
    branch develop
    checkout develop
    commit id: "Setup"
    branch feature/auth
    checkout feature/auth
    commit id: "Add login"
    commit id: "Add JWT"
    checkout develop
    merge feature/auth
    branch feature/payments
    checkout feature/payments
    commit id: "Add cart"
    commit id: "Add checkout"
    checkout develop
    merge feature/payments
    branch release/2.0
    checkout release/2.0
    commit id: "Bump version"
    commit id: "Fix bugs"
    checkout main
    merge release/2.0 tag: "v2.0.0"
    checkout develop
    merge release/2.0
    checkout main
    branch hotfix/crash
    commit id: "Fix crash"
    checkout main
    merge hotfix/crash tag: "v2.0.1"
    checkout develop
    merge hotfix/crash
```

### Git Flow Branch Types

```mermaid
flowchart TB
    subgraph "🏭 Production"
        MAIN[main<br/>Always production-ready<br/>Tagged releases]
    end
    
    subgraph "🔧 Development"
        DEV[develop<br/>Integration branch<br/>Features come together]
    end
    
    subgraph "✨ Feature Work"
        FEAT[feature/*<br/>Individual features<br/>Branch from develop]
    end
    
    subgraph "📦 Release Prep"
        REL[release/*<br/>Final bug fixes<br/>Version bumps]
    end
    
    subgraph "🚨 Emergency"
        HOT[hotfix/*<br/>Production fixes<br/>Branch from main]
    end
    
    FEAT -->|merge| DEV
    DEV -->|create| REL
    REL -->|merge| MAIN
    REL -->|merge| DEV
    HOT -->|merge| MAIN
    HOT -->|merge| DEV
    MAIN -->|create| HOT
    DEV -->|create| FEAT
```

### When to Use Git Flow

| ✅ Use When | ❌ Avoid When |
|-------------|---------------|
| Scheduled releases (monthly/quarterly) | Deploying multiple times per day |
| Multiple versions in production | Small teams or solo developers |
| Need formal release processes | Web apps with single live version |
| Regulated industries | Overhead slows you down |

### Git Flow Commands Cheat Sheet

```bash
# Start a feature
git checkout develop
git checkout -b feature/user-dashboard

# Finish a feature
git checkout develop
git merge --no-ff feature/user-dashboard

# Create release
git checkout develop
git checkout -b release/2.0.0

# Finish release
git checkout main
git merge --no-ff release/2.0.0
git tag -a v2.0.0 -m "Release 2.0.0"
git checkout develop
git merge --no-ff release/2.0.0

# Emergency hotfix
git checkout main
git checkout -b hotfix/fix-crash
# fix the bug...
git checkout main
git merge --no-ff hotfix/fix-crash
git tag -a v2.0.1 -m "Hotfix"
git checkout develop
git merge --no-ff hotfix/fix-crash
```

---

## 2️⃣ GitHub Flow

> **Best For**: SaaS products, Startups, Open Source, Continuous deployment

```mermaid
gitGraph
    commit id: "Production"
    branch feature/login
    checkout feature/login
    commit id: "Add form"
    commit id: "Add validation"
    checkout main
    merge feature/login id: "PR #1"
    branch feature/search
    checkout feature/search
    commit id: "Add index"
    commit id: "Add API"
    checkout main
    merge feature/search id: "PR #2"
    branch feature/profile
    checkout feature/profile
    commit id: "Add UI"
    checkout main
    merge feature/profile id: "PR #3"
```

### GitHub Flow Rules

```mermaid
flowchart LR
    subgraph "📋 Simple Rules"
        A[1️⃣ main is ALWAYS<br/>deployable]
        B[2️⃣ Branch from main<br/>for every change]
        C[3️⃣ Open Pull Request<br/>for review]
        D[4️⃣ Merge after<br/>approval + CI]
        E[5️⃣ Deploy<br/>immediately]
    end
    
    A --> B --> C --> D --> E
```

### GitHub Flow Workflow

```mermaid
sequenceDiagram
    participant Dev as 👩‍💻 Developer
    participant Feature as 🌿 Feature Branch
    participant PR as 📝 Pull Request
    participant CI as ⚙️ CI/CD
    participant Main as 🏠 Main
    participant Prod as 🚀 Production

    Dev->>Feature: git checkout -b feature/xyz
    Dev->>Feature: Write code + commits
    Dev->>PR: Open Pull Request
    PR->>CI: Run tests, lint, build
    CI-->>PR: ✅ All checks pass
    PR->>Main: Merge (after review)
    Main->>Prod: Auto deploy
```

### When to Use GitHub Flow

| ✅ Use When | ❌ Avoid When |
|-------------|---------------|
| Web applications | Multiple versions in production |
| Continuous deployment | Need staging environment |
| Small to medium teams | Strict QA processes |
| Single live version | Scheduled releases |

### GitHub Flow Commands

```bash
# Create feature branch
git checkout main
git pull origin main
git checkout -b feature/add-search

# Work and commit
git add .
git commit -m "feat: add search functionality"
git push -u origin feature/add-search

# After PR merge, clean up
git checkout main
git pull origin main
git branch -d feature/add-search
```

---

## 3️⃣ GitLab Flow

> **Best For**: Teams needing staging/QA environments, Medium+ teams

```mermaid
gitGraph
    commit id: "Code"
    branch feature/notifications
    checkout feature/notifications
    commit id: "Add service"
    commit id: "Add templates"
    checkout main
    merge feature/notifications
    commit id: "More features"
    branch staging
    checkout staging
    commit id: "QA Testing"
    branch production
    checkout production
    commit id: "Live"
    checkout main
    commit id: "New feature"
    checkout staging
    merge main
    checkout production
    merge staging
```

### GitLab Flow with Environments

```mermaid
flowchart TB
    subgraph "Development"
        FEAT[feature/* branches]
        MAIN[main branch<br/>Always works]
    end
    
    subgraph "Testing"
        STAGE[staging branch<br/>Pre-production QA]
    end
    
    subgraph "Live"
        PROD[production branch<br/>What users see]
    end
    
    FEAT -->|Merge Request| MAIN
    MAIN -->|Promote| STAGE
    STAGE -->|After QA| PROD
    
    style FEAT fill:#e1f5fe
    style MAIN fill:#fff9c4
    style STAGE fill:#ffe0b2
    style PROD fill:#c8e6c9
```

### GitLab Flow Commands

```bash
# Develop feature
git checkout main
git checkout -b feature/notifications
# work...
git push -u origin feature/notifications
# Create Merge Request via GitLab UI

# After merge to main, promote to staging
git checkout staging
git merge main
git push origin staging
# Staging deployment triggers

# After QA, promote to production
git checkout production
git merge staging
git push origin production
# Production deployment triggers
```

---

## 4️⃣ Trunk-Based Development

> **Best For**: Google, Meta, Amazon-style high-velocity teams

```mermaid
gitGraph
    commit id: "v1"
    commit id: "v2"
    branch short-lived-1
    checkout short-lived-1
    commit id: "Quick fix"
    checkout main
    merge short-lived-1
    commit id: "v3"
    commit id: "v4"
    branch short-lived-2
    checkout short-lived-2
    commit id: "Small feature"
    checkout main
    merge short-lived-2
    commit id: "v5"
    commit id: "v6"
```

### Trunk-Based Principles

```mermaid
mindmap
  root((Trunk-Based<br/>Development))
    Main is the Trunk
      Single source of truth
      Always green
      CI must pass
    Short-lived Branches
      Less than 24 hours
      Merge same day
      Or commit directly
    Small Changes
      Incremental updates
      Easy to review
      Easy to rollback
    Feature Flags
      Hide incomplete work
      Gradual rollout
      No long branches needed
```

### Feature Flags Flow

```mermaid
flowchart LR
    subgraph "🏗️ Development"
        CODE[Write Code<br/>Behind Flag]
        MERGE[Merge to Main<br/>Flag OFF]
    end
    
    subgraph "🧪 Rollout"
        INT[Enable for<br/>Internal Users]
        BETA[Enable for<br/>Beta Users]
        ALL[Enable for<br/>Everyone]
    end
    
    subgraph "🧹 Cleanup"
        REMOVE[Remove Flag<br/>Remove Legacy Code]
    end
    
    CODE --> MERGE --> INT --> BETA --> ALL --> REMOVE
```

### When to Use Trunk-Based

| ✅ Use When | ❌ Avoid When |
|-------------|---------------|
| Strong CI/CD pipeline | Weak or no test coverage |
| Deploying multiple times/day | Need formal release process |
| Experienced teams | Can't use feature flags |
| Web applications | Multiple versions needed |

---

## 📝 Branch Naming Conventions

```mermaid
flowchart TB
    subgraph "Branch Prefixes"
        F[feature/] --> F1[feature/user-auth]
        B[bugfix/] --> B1[bugfix/login-loop]
        H[hotfix/] --> H1[hotfix/security-patch]
        R[release/] --> R1[release/2.1.0]
        D[docs/] --> D1[docs/api-docs]
        RE[refactor/] --> RE1[refactor/db-queries]
        T[test/] --> T1[test/integration]
        C[chore/] --> C1[chore/update-deps]
    end
```

### Naming Rules

| Rule | Example |
|------|---------|
| Use lowercase | ✅ `feature/user-auth` ❌ `Feature/User-Auth` |
| Use hyphens (kebab-case) | ✅ `feature/add-login` ❌ `feature/add_login` |
| Keep under 50 chars | ✅ `feature/auth` ❌ `feature/user-authentication-system-with-jwt` |
| Include ticket numbers | ✅ `feature/PROJ-1234-user-auth` |
| Be descriptive | ✅ `bugfix/fix-payment-null` ❌ `bugfix/fix-bug` |

---

## 🔀 Merge Strategies Comparison

```mermaid
flowchart TB
    subgraph "Original State"
        O1[main: A → B → C]
        O2[feature: D → E → F]
    end
    
    subgraph "Merge Commit"
        M1["main: A → B → C ─────→ M"]
        M2["         ↘ D → E → F ↗"]
    end
    
    subgraph "Squash Merge"
        S1["main: A → B → C → S"]
        S2["(S = D + E + F combined)"]
    end
    
    subgraph "Rebase Merge"
        R1["main: A → B → C → D' → E' → F'"]
        R2["(Linear history, no merge commit)"]
    end
```

### Merge Strategy Table

| Strategy | Command | Pros | Cons | Best For |
|----------|---------|------|------|----------|
| **Merge Commit** | `git merge --no-ff` | Full history, easy to revert feature | Cluttered history | Git Flow releases |
| **Squash Merge** | `git merge --squash` | Clean history, one commit per feature | Loses granular commits | GitHub Flow |
| **Rebase Merge** | `git rebase` then merge | Linear history, no merge commits | Rewrites hashes | Trunk-Based |

---

## 🛡️ Branch Protection Rules

```mermaid
flowchart LR
    subgraph "Protection Rules"
        A[Require Pull Request]
        B[Require Reviews<br/>1-2 approvers]
        C[Require Status Checks<br/>CI must pass]
        D[Require Up-to-date<br/>Branch]
        E[Restrict Direct Push]
    end
    
    PR[Pull Request] --> A
    A --> B --> C --> D --> E --> MAIN[main branch]
    
    style MAIN fill:#c8e6c9
```

---

## ⚔️ Handling Merge Conflicts

```mermaid
flowchart TD
    A[Conflict Detected!] --> B{Choose Resolution}
    
    B -->|Keep Your Changes| C[Use HEAD version]
    B -->|Keep Their Changes| D[Use incoming version]
    B -->|Combine Both| E[Manually merge]
    
    C --> F[Remove conflict markers]
    D --> F
    E --> F
    
    F --> G[git add file]
    G --> H{Merge or Rebase?}
    
    H -->|Merge| I[git commit]
    H -->|Rebase| J[git rebase --continue]
    
    style A fill:#ffcdd2
    style F fill:#fff9c4
    style I fill:#c8e6c9
    style J fill:#c8e6c9
```

### Conflict Resolution Commands

```bash
# See conflicted files
git status

# After resolving manually
git add <resolved-file>

# For merge conflicts
git commit

# For rebase conflicts
git rebase --continue

# To abort and start over
git merge --abort
# or
git rebase --abort

# Enable auto-resolution for repeated conflicts
git config --global rerere.enabled true
```

---

## 🎯 Decision Flowchart: Which Strategy?

```mermaid
flowchart TD
    START[Start] --> Q1{How often do<br/>you deploy?}
    
    Q1 -->|Multiple times/day| Q2{Strong CI/CD<br/>pipeline?}
    Q1 -->|Weekly/Monthly| Q3{Multiple versions<br/>in production?}
    Q1 -->|Quarterly+| GF[Git Flow]
    
    Q2 -->|Yes| TBD[Trunk-Based<br/>Development]
    Q2 -->|No| GHF[GitHub Flow]
    
    Q3 -->|Yes| GF
    Q3 -->|No| Q4{Need staging<br/>environment?}
    
    Q4 -->|Yes| GLF[GitLab Flow]
    Q4 -->|No| GHF
    
    style TBD fill:#e8f5e9
    style GHF fill:#e3f2fd
    style GLF fill:#fff3e0
    style GF fill:#fce4ec
```

---

## 📚 Summary: Key Takeaways

```mermaid
mindmap
  root((Git Branching<br/>Best Practices))
    Keep Branches Short
      Merge within hours/days
      Sync with main often
    Protect Main Branch
      Require reviews
      Require CI pass
    Consistent Naming
      Use prefixes
      Include ticket numbers
    Small PRs
      Under 400 lines
      Single purpose
    Communicate
      Tell team what you're changing
      Avoid same file edits
```

---

## 🔗 Quick Reference Commands

| Action | Command |
|--------|---------|
| Create branch | `git checkout -b feature/xyz` |
| Switch branch | `git checkout main` |
| Update from main | `git pull origin main` |
| Merge with commit | `git merge --no-ff feature/xyz` |
| Squash merge | `git merge --squash feature/xyz` |
| Rebase | `git rebase main` |
| Create tag | `git tag -a v1.0.0 -m "Release"` |
| Delete local branch | `git branch -d feature/xyz` |
| Delete remote branch | `git push origin --delete feature/xyz` |
| View branches | `git branch -a` |

---

> 💡 **Remember**: Start with the simplest strategy (GitHub Flow) and only add complexity when you have a concrete problem that demands it!
