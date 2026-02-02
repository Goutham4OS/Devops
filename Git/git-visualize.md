# Git Visual Command Guide & Mind Map

## Git Commands Mind Map

```
                                    GIT
                                     |
        ┌────────────────────────────┼────────────────────────────┐
        │                            │                            │
    SETUP & CONFIG            BASIC WORKFLOW              BRANCHING & MERGING
        │                            │                            │
   ┌────┴────┐              ┌────────┼────────┐          ┌────────┼────────┐
   │         │              │        │        │          │        │        │
  init    config          add     commit    diff      branch   merge    rebase
 clone   --global        reset   --amend   status    checkout  --ff    -i
                        restore                       switch   --no-ff
                                                      -b/-c    --squash
        │
    REMOTE OPS                  HISTORY                    ADVANCED
        │                          │                           │
   ┌────┴────┐              ┌──────┼──────┐           ┌────────┼────────┐
   │         │              │      │      │           │        │        │
 remote    push           log   show   blame       stash   cherry-pick  bisect
  fetch    pull         reflog  tag   --graph       pop    revert      reflog
 origin   --force      --oneline                   apply   clean       fsck
 -u/-v    --tags                                   list    gc
```

---

## Visual Guide to Git Commands

### 1. Git Init - Creating Repository

```
Before:
  myproject/
    └── files...

After git init:
  myproject/
    ├── files...
    └── .git/
        ├── HEAD ────────────→ refs/heads/main (doesn't exist yet)
        ├── objects/
        ├── refs/
        │   └── heads/
        └── config
```

---

### 2. Git Add - Staging Files

```
Working Directory          Staging Area           Repository
                          (Index)                (.git)
┌──────────────┐         ┌──────────────┐      ┌──────────────┐
│              │         │              │      │              │
│  file.txt    │         │              │      │              │
│  (modified)  │         │              │      │              │
│              │         │              │      │              │
└──────────────┘         └──────────────┘      └──────────────┘

                    git add file.txt ↓

┌──────────────┐         ┌──────────────┐      ┌──────────────┐
│              │         │              │      │              │
│  file.txt    │────────→│  file.txt    │      │              │
│  (modified)  │  copy   │  (staged)    │      │              │
│              │         │              │      │              │
└──────────────┘         └──────────────┘      └──────────────┘
```

**Commands**:
```bash
git add file.txt          # Stage specific file
git add .                 # Stage all in current directory
git add -A                # Stage all changes (adds, mods, deletes)
git add -p                # Interactive staging (choose hunks)
git add *.js              # Stage all .js files
```

---

### 3. Git Commit - Saving Snapshot

```
Working Directory          Staging Area           Repository
┌──────────────┐         ┌──────────────┐      ┌──────────────┐
│              │         │              │      │              │
│  file.txt    │         │  file.txt    │      │              │
│              │         │  (staged)    │      │              │
│              │         │              │      │              │
└──────────────┘         └──────────────┘      └──────────────┘

                    git commit -m "message" ↓

┌──────────────┐         ┌──────────────┐      ┌──────────────┐
│              │         │              │      │  Commit a1b2 │
│  file.txt    │         │  (empty)     │      │  tree: t1    │
│  (clean)     │         │              │      │  file.txt    │
│              │         │              │      │              │
└──────────────┘         └──────────────┘      └──────────────┘
                                                       ↑
                                                    main HEAD
```

**Commands**:
```bash
git commit -m "Add feature"         # Commit with message
git commit -am "Fix bug"            # Add + commit tracked files
git commit --amend                  # Modify last commit
git commit --amend --no-edit        # Add to last commit, keep message
git commit --allow-empty            # Empty commit (CI triggers)
```

---

### 4. Branch Creation - Pointer Creation

```
Initial State:
┌─────────────┐
│  Commit A   │
│  a1b2c3     │
└─────────────┘
      ↑
      │
   main (HEAD)


After: git branch feature
┌─────────────┐
│  Commit A   │
│  a1b2c3     │
└─────────────┘
      ↑
      ├── main (HEAD)
      └── feature

Note: Both point to same commit!
      HEAD still on main
      No new commit created
```

**Commands**:
```bash
git branch feature              # Create branch (don't switch)
git branch                      # List local branches
git branch -a                   # List all branches (local + remote)
git branch -d feature           # Delete merged branch
git branch -D feature           # Force delete branch
git branch -m old new           # Rename branch
```

---

### 5. Checkout/Switch - Moving HEAD

```
Before: git checkout feature
┌─────────────┐
│  Commit A   │
└─────────────┘
      ↑
      ├── main (HEAD) ←── You are here
      └── feature


After: git checkout feature
┌─────────────┐
│  Commit A   │
└─────────────┘
      ↑
      ├── main
      └── feature (HEAD) ←── You moved here

Working directory updated to match commit A
(no changes because both branches point to same commit)
```

**Commands**:
```bash
git checkout feature            # Switch to branch (old way)
git switch feature              # Switch to branch (new way)
git checkout -b feature         # Create + switch (old)
git switch -c feature           # Create + switch (new)
git checkout <commit>           # Detached HEAD state
git checkout -- file.txt        # Discard working changes
```

---

### 6. Making Commits on Branch

```
Initial:
    A
    ↑
    ├── main
    └── feature (HEAD)

After commit on feature:
    A ←────── B
    ↑         ↑
    │         └── feature (HEAD)
    └── main

After another commit:
    A ←────── B ←────── C
    ↑         │         ↑
    │         │         └── feature (HEAD)
    └── main  └── (intermediate)

Notice:
- main pointer DIDN'T MOVE
- feature pointer moves with each commit
- HEAD follows feature
```

**Commands**:
```bash
# On feature branch
git add .
git commit -m "Feature work"    # Creates new commit, moves feature pointer
```

---

## Merge vs Rebase: The Complete Visual Story

### Scenario Setup

```
Starting Point (after branching):
    A
    ↑
    ├── main (HEAD)
    └── feature

After work on both branches:
         main commits
         ↓    ↓
    A ← B ← C
    ↑         ↑
    │         main (HEAD)
    ↓
    D ← E
        ↑
        feature

Timeline:
1. Created feature from A
2. Made commits D, E on feature
3. Meanwhile, commits B, C added to main
4. Now we want to integrate feature into main
```

---

### Option 1: MERGE (git merge)

```bash
git checkout main               # Switch to main
git merge feature               # Merge feature into main
```

#### Fast-Forward Merge (when possible)

```
Before (no divergence):
    A ← B ← C
    ↑       ↑
    │       main (HEAD)
    └ feature

After: git merge feature
    A ← B ← C
            ↑
            ├── main (HEAD) ←── Pointer just moved!
            └── feature

Result: No merge commit needed, just move pointer forward
```

#### Three-Way Merge (diverged history)

```
Before:
         main
         ↓  ↓
    A ← B ← C ← ?
    ↑           
    └ D ← E     
          ↑
          feature

After: git merge feature
         main
         ↓  ↓
    A ← B ← C ←──┐
    ↑            ↓
    └ D ← E ← M (merge commit)
          ↑   ↑
      feature main (HEAD)

Merge Commit M contains:
- parent 1: C (from main)
- parent 2: E (from feature)
- Combined changes from both
```

**Characteristics**:
- ✅ Preserves complete history
- ✅ Shows when branches merged
- ✅ Safe (doesn't rewrite history)
- ❌ Creates extra merge commits
- ❌ History can become cluttered

**Commands**:
```bash
git merge feature               # Merge with auto-commit
git merge --no-ff feature       # Force merge commit (no fast-forward)
git merge --squash feature      # Combine all commits into one
git merge --abort               # Cancel merge (during conflicts)
```

---

### Option 2: REBASE (git rebase)

```bash
git checkout feature            # Switch to feature branch
git rebase main                 # Rebase feature onto main
```

#### How Rebase Works

```
Before:
         main
         ↓  ↓
    A ← B ← C
    ↑           
    └ D ← E     
          ↑
          feature (HEAD)

Step 1: Git finds common ancestor (A)

Step 2: Git temporarily removes D and E
    A ← B ← C
    ↑       ↑
    |       main
    |
    └ D ← E (saved as patches)

Step 3: Replay D' and E' on top of C
    A ← B ← C ← D' ← E'
    ↑       ↑        ↑
    |       main     feature (HEAD)

Result: Linear history, D' and E' are NEW commits
        (different SHA-1s than D and E)
```

**Important Notes**:
- D' and E' have **new commit hashes** (SHA-1)
- Same changes, different parent
- Original D and E are discarded (garbage collected)

**Characteristics**:
- ✅ Clean, linear history
- ✅ Easier to follow
- ✅ No merge commits
- ❌ Rewrites history (changes commit hashes)
- ❌ Dangerous on public branches

**Commands**:
```bash
git rebase main                 # Rebase current branch onto main
git rebase -i HEAD~3            # Interactive rebase (last 3 commits)
git rebase --continue           # Continue after resolving conflicts
git rebase --skip               # Skip current commit
git rebase --abort              # Cancel rebase
git rebase --onto new old branch # Advanced: change base
```

---

### Merge vs Rebase Side-by-Side

```
MERGE RESULT:
         main
         ↓  ↓
    A ← B ← C ←──┐
    ↑            ↓
    └ D ← E ← M 
              ↑
              main (HEAD)

git log --oneline:
M  Merge feature into main
E  Feature work 2
D  Feature work 1
C  Main work 2
B  Main work 1
A  Initial commit

REBASE RESULT:
    A ← B ← C ← D' ← E'
    ↑       ↑        ↑
    |       |        feature (HEAD)
    |       main
    
git log --oneline:
E' Feature work 2
D' Feature work 1
C  Main work 2
B  Main work 1
A  Initial commit

Note: D' and E' are new commits!
```

---

## Interactive Rebase: Editing History

```bash
git rebase -i HEAD~3            # Edit last 3 commits
```

```
Opens editor with:

pick a1b2c3 Add feature A
pick d4e5f6 Fix typo
pick g7h8i9 Add feature B

# Commands:
# p, pick = use commit
# r, reword = use commit, but edit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, meld into previous
# f, fixup = like squash, discard message
# d, drop = remove commit
```

### Example: Squashing Commits

```
Before:
    A ← B ← C ← D
            ↑       ↑
            |       feature (HEAD)
            main

B: "Add login form"
C: "Fix typo"
D: "Add validation"

Rebase commands:
pick B Add login form
squash C Fix typo
squash D Add validation

After:
    A ← B'
        ↑
        ├── feature (HEAD)
        └── main

B': "Add login form with validation"
    (combines B + C + D into single commit)
```

---

## Cherry-Pick: Selecting Specific Commits

```bash
git cherry-pick <commit-hash>
```

```
Before:
    feature branch:
    A ← B ← C ← D
        ↑       ↑
        |       feature
        main

    main branch:
    A ← B ← E
        ↑   ↑
        |   main (HEAD)

After: git cherry-pick D (on main)
    A ← B ← E ← D'
        ↑       ↑
        |       main (HEAD)
        
    Original feature unchanged:
    A ← B ← C ← D
                ↑
                feature

Result: D' is a copy of D on main
```

**Commands**:
```bash
git cherry-pick abc123          # Pick specific commit
git cherry-pick abc123 def456   # Pick multiple commits
git cherry-pick abc123..def456  # Pick range of commits
git cherry-pick --continue      # Continue after conflict
git cherry-pick --abort         # Cancel cherry-pick
```

---

## Reset: Moving Branch Pointer Backward

```
Initial State:
    A ← B ← C ← D ← E
        ↑           ↑
        |           main (HEAD)
        other
```

### git reset --soft HEAD~2

```
After:
    A ← B ← C ← D ← E
        ↑   ↑       ↑
        |   main    (D and E become unreachable)
        |   (HEAD)
        other

Working Directory: Unchanged
Staging Area:      Contains changes from D and E
Effect: Undo commits, keep changes staged
```

### git reset --mixed HEAD~2 (default)

```
After:
    A ← B ← C ← D ← E
        ↑   ↑       ↑
        |   main    (D and E become unreachable)
        |   (HEAD)
        other

Working Directory: Contains changes from D and E
Staging Area:      Empty
Effect: Undo commits, unstage changes
```

### git reset --hard HEAD~2

```
After:
    A ← B ← C ← D ← E
        ↑   ↑       ↑
        |   main    (D and E lost forever!)
        |   (HEAD)
        other

Working Directory: Clean (like C)
Staging Area:      Empty
Effect: Undo commits, discard all changes
```

**Commands**:
```bash
git reset --soft HEAD~1         # Undo last commit, keep staged
git reset HEAD~1                # Undo last commit, unstage
git reset --hard HEAD~1         # Undo last commit, discard changes
git reset --hard origin/main    # Match remote exactly
git reset file.txt              # Unstage file
```

---

## Revert: Safe Undo with New Commit

```
Before:
    A ← B ← C ← D
    ↑           ↑
    |           main (HEAD)

After: git revert C
    A ← B ← C ← D ← C'
    ↑               ↑
    |               main (HEAD)

C': "Revert 'Original message'"
    Contains inverse changes of C
    
Result: Undo C's changes without rewriting history
```

**Commands**:
```bash
git revert abc123               # Revert specific commit
git revert HEAD                 # Revert last commit
git revert HEAD~3..HEAD         # Revert last 3 commits
git revert --no-commit abc123   # Revert without auto-commit
git revert --abort              # Cancel revert
```

---

## Stash: Temporary Storage

```
Working Directory with changes:
┌──────────────────┐
│ file.txt         │
│ (modified)       │
│                  │
│ new.txt          │
│ (untracked)      │
└──────────────────┘

git stash (or git stash push)
         ↓

Clean Working Directory:
┌──────────────────┐
│ (clean)          │
│                  │
│                  │
│                  │
│                  │
└──────────────────┘

Stash Stack:
┌──────────────────┐
│ stash@{0}        │ ← Latest (file.txt changes)
├──────────────────┤
│ stash@{1}        │
├──────────────────┤
│ stash@{2}        │ ← Oldest
└──────────────────┘

git stash pop
         ↓

Changes restored:
┌──────────────────┐
│ file.txt         │
│ (modified)       │
└──────────────────┘
```

**Commands**:
```bash
git stash                       # Save changes
git stash save "WIP feature"    # Save with message
git stash list                  # List all stashes
git stash show stash@{0}        # Show stash diff
git stash pop                   # Apply + delete latest
git stash apply stash@{1}       # Apply specific stash (keep it)
git stash drop stash@{0}        # Delete specific stash
git stash clear                 # Delete all stashes
git stash branch new-branch     # Create branch from stash
```

---

## Remote Operations

### Clone

```
Remote Repository:
    github.com/user/repo
    A ← B ← C
            ↑
            main

git clone <url>
         ↓

Local Repository:
    .git/
    A ← B ← C
        ↑   ↑
        |   origin/main (remote tracking)
        |   
        └── main (HEAD)

    Working Directory:
    Files from commit C
```

### Fetch

```
Remote:
    A ← B ← C ← D ← E
                    ↑
                    main

Local (before fetch):
    A ← B ← C
        ↑   ↑
        |   origin/main
        └── main (HEAD)

git fetch origin
         ↓

Local (after fetch):
    A ← B ← C
        ↑   ↑
        |   main (HEAD)
        ↓
        D ← E
            ↑
            origin/main (updated)

Your branch: Unchanged
Remote tracking: Updated
Working Directory: Unchanged
```

### Pull (Fetch + Merge)

```
git pull = git fetch + git merge origin/main

Remote:
    A ← B ← C ← D
                ↑
                main

Local before:
    A ← B ← C ← X
        ↑   ↑   ↑
        |   |   main (HEAD)
        |   origin/main (old)
        
After git pull:
    A ← B ← C ← X ←─┐
        ↑   ↑       ↓
        |   |       M (merge)
        |   |       ↑
        |   |       main (HEAD)
        ↓   |
        D ←─┘
            ↑
            origin/main
```

### Push

```
Local:
    A ← B ← C ← D
                ↑
                main (HEAD)

Remote (before push):
    A ← B ← C
            ↑
            main

git push origin main
         ↓

Remote (after push):
    A ← B ← C ← D
                ↑
                main (updated!)

Local remote-tracking updated:
    A ← B ← C ← D
            ↑   ↑
            |   origin/main (updated)
            main (HEAD)
```

**Commands**:
```bash
# Fetch
git fetch origin                # Fetch from origin
git fetch --all                 # Fetch from all remotes

# Pull
git pull                        # Fetch + merge
git pull --rebase               # Fetch + rebase
git pull origin main            # Pull specific branch

# Push
git push origin main            # Push to remote
git push -u origin main         # Push + set upstream
git push --all                  # Push all branches
git push --tags                 # Push all tags
git push --force                # Dangerous! Overwrites remote
git push --force-with-lease     # Safer force push
git push origin --delete branch # Delete remote branch
```

---

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    TYPICAL GIT WORKFLOW                      │
└─────────────────────────────────────────────────────────────┘

1. START NEW FEATURE
   git checkout main
   git pull origin main
   git checkout -b feature/new-thing
   
   State:
   main ← feature (HEAD)
   (both point to same commit)

2. MAKE CHANGES
   [edit files]
   git status
   git add .
   git commit -m "Add feature"
   
   State:
   main ← A ← B
          ↑   ↑
          |   feature (HEAD)

3. KEEP UP TO DATE (option A: merge)
   git checkout main
   git pull origin main
   git checkout feature
   git merge main
   
   State:
   main ← A ← B ← M
          ↑       ↑
          |       feature (HEAD)
          └─ C ←──┘ (from main)

3. KEEP UP TO DATE (option B: rebase)
   git checkout feature
   git fetch origin
   git rebase origin/main
   
   State:
   main ← A ← C ← B'
          ↑   ↑   ↑
          |   |   feature (HEAD)
          |   main

4. PUSH FEATURE
   git push -u origin feature
   
   Remote now has feature branch

5. CREATE PULL REQUEST
   (via GitHub/GitLab UI)
   
6. MERGE TO MAIN
   (via PR, or locally)
   git checkout main
   git merge feature
   git push origin main
   
7. CLEANUP
   git branch -d feature
   git push origin --delete feature
```

---

## Quick Reference: Pointer Movement

```
COMMAND                 EFFECT ON POINTERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

git commit              ✓ Current branch moves forward
                        ✓ HEAD moves with branch
                        ✗ Other branches unchanged

git checkout branch     ✓ HEAD moves to branch
                        ✗ No branch pointers move
                        ✓ Working dir updated

git merge               ✓ Current branch moves to new commit
                        ✓ HEAD moves with branch
                        ✗ Merged branch unchanged

git rebase              ✓ Current branch rewrites commits
                        ✓ HEAD moves with branch
                        ✗ Base branch unchanged

git reset --hard        ✓ Current branch moves backward
                        ✓ HEAD moves with branch
                        ✓ Working dir/staging reset
                        ! Old commits become unreachable

git cherry-pick         ✓ Current branch gets new commit
                        ✓ HEAD moves forward
                        ✗ Source branch unchanged

git branch newbranch    ✓ New pointer created
                        ✗ HEAD doesn't move
                        ✗ Current branch unchanged

git tag v1.0            ✓ New tag pointer created
                        ✗ HEAD doesn't move
                        ✗ Branches unchanged

git fetch               ✓ Remote-tracking branches update
                        ✗ Local branches unchanged
                        ✗ HEAD unchanged

git pull                ✓ Remote-tracking updates
                        ✓ Current branch moves (merge)
                        ✓ HEAD moves with branch
```

---

## Most Used Commands Cheat Sheet

### Daily Basics
```bash
git status                      # Check current state
git add .                       # Stage all changes
git commit -m "message"         # Save snapshot
git push                        # Upload to remote
git pull                        # Download from remote
```

### Branching
```bash
git branch feature              # Create branch
git checkout feature            # Switch branch
git checkout -b feature         # Create + switch
git branch -d feature           # Delete branch
```

### Viewing
```bash
git log                         # View history
git log --oneline --graph       # Compact graph view
git diff                        # See changes
git show abc123                 # View commit
git blame file.txt              # Who changed what
```

### Undoing
```bash
git restore file.txt            # Discard working changes
git restore --staged file.txt   # Unstage file
git reset HEAD~1                # Undo last commit
git revert abc123               # Safe undo
git reset --hard origin/main    # Match remote
```

### Remote
```bash
git remote -v                   # List remotes
git fetch origin                # Download updates
git push -u origin main         # Push + track
git push --force-with-lease     # Safe force push
```

### Advanced
```bash
git stash                       # Save work temporarily
git stash pop                   # Restore stashed work
git cherry-pick abc123          # Copy commit
git rebase -i HEAD~3            # Edit history
git reflog                      # View all HEAD movements
```

---

## Mental Model Summary

### Core Principles

1. **Git is a Graph of Commits**
   - Each commit points to parent(s)
   - Directed acyclic graph (DAG)

2. **Branches are Pointers**
   - Just a reference to a commit SHA-1
   - Moving a branch = updating the pointer
   - Cheap to create (40 bytes)

3. **HEAD is Special**
   - Points to current location
   - Usually points to a branch
   - Detached HEAD = points to commit directly

4. **Three Trees**
   - Working Directory (files you see)
   - Staging Area/Index (prepared snapshot)
   - Repository/HEAD (last commit)

5. **Objects are Immutable**
   - Once created, never changed
   - "Rewriting history" = creating new objects
   - Old objects become unreachable

6. **Remote Tracking Branches**
   - Local copies of remote branch states
   - Updated by fetch/pull
   - Can't be moved directly by you

---

## Decision Tree: Which Command to Use?

```
Need to save changes?
├─ YES → Ready to commit?
│        ├─ YES → git commit -m "message"
│        └─ NO → git stash
│
├─ Want to switch branches?
│  ├─ Clean working dir → git checkout branch
│  └─ Dirty working dir → git stash, then checkout
│
├─ Want to integrate changes?
│  ├─ Keep history → git merge
│  └─ Clean history → git rebase
│
├─ Made a mistake?
│  ├─ Not committed yet → git restore file
│  ├─ Committed locally → git reset
│  └─ Pushed to remote → git revert
│
└─ Want to share work?
   ├─ First time → git push -u origin branch
   └─ Subsequent → git push
```

This visual guide should help you understand how Git commands affect the repository structure!
