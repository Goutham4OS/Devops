---
title: 'Git Internals: Complete Guide From Scratch'
---

# Git Internals: Complete Guide From Scratch

## Table of Contents
1. [The Three Areas](#the-three-areas)
2. [Git Objects](#git-objects)
3. [References and HEAD](#references-and-head)
4. [Git Commands by Category](#git-commands-by-category)
5. [Internal Workflow](#internal-workflow)

---

## The Three Areas

Git manages your code through three distinct areas:

```
┌─────────────────────┐
│  Working Directory  │  ← Your actual files
│   (Working Tree)    │
└──────────┬──────────┘
           │ git add
           ↓
┌─────────────────────┐
│   Staging Area      │  ← Prepared for commit
│     (Index)         │
└──────────┬──────────┘
           │ git commit
           ↓
┌─────────────────────┐
│   Repository        │  ← Permanent history
│   (.git directory)  │
└─────────────────────┘
```

### 1. Working Directory (Working Tree)
- **What it is**: Your project folder with actual files you can see and edit
- **Location**: Current directory where you work
- **Contains**: Modified, unmodified, and untracked files

### 2. Staging Area (Index)
- **What it is**: A snapshot of what will go into the next commit
- **Location**: `.git/index` (binary file)
- **Purpose**: Lets you prepare commits precisely
- **Contains**: Snapshots of files you've "staged" with `git add`

### 3. Repository (.git directory)
- **What it is**: Permanent history of all commits
- **Location**: `.git/` folder
- **Contains**: All committed snapshots, branches, tags, configuration

---

## Git Objects

Git stores everything as **objects** identified by SHA-1 hashes. There are 4 types:

### 1. Blob (Binary Large Object)

**Stores**: Raw file content (no filename, no metadata)

```bash
# View blob content
git cat-file -p <sha1>

# Get blob size
git cat-file -s <sha1>

# Get object type
git cat-file -t <sha1>
```

**Example**:
```
# File: hello.txt containing "Hello, World!"
# Git creates blob with SHA-1: 8ab686eafeb1f44702738c8b0f24f2567c36da6d
```

**Key Point**: Same content = same blob (Git deduplicates)

### 2. Tree

**Stores**: Directory structure (like filesystem directories)

```
100644 blob 8ab686  hello.txt
040000 tree 5f2c85  src/
100755 blob 3c4e9c  script.sh
```

- **100644**: Regular file
- **100755**: Executable file
- **040000**: Directory (subdirectory tree)

**Command**:
```bash
git cat-file -p <tree-sha1>
```

### 3. Commit

**Stores**: Snapshot metadata

```
tree 5f2c851d...
parent 3a4b5c6d...
author John Doe <john@example.com> 1633024800 +0000
committer John Doe <john@example.com> 1633024800 +0000

Initial commit
```

**Contains**:
- Pointer to root tree
- Parent commit(s)
- Author & committer info
- Commit message

**Command**:
```bash
git cat-file -p <commit-sha1>
```

### 4. Tag (Annotated)

**Stores**: Named pointer to commit with metadata

```
object 3a4b5c6d...
type commit
tag v1.0.0
tagger John Doe <john@example.com> 1633024800 +0000

Release version 1.0.0
```

---

## File States in Git

```
┌─────────────┐
│  Untracked  │ ← New files Git doesn't know about
└──────┬──────┘
       │ git add
       ↓
┌─────────────┐
│   Staged    │ ← Added to index, ready for commit
│  (Tracked)  │
└──────┬──────┘
       │ git commit
       ↓
┌─────────────┐
│ Unmodified  │ ← Committed, no changes
│ (Committed) │
└──────┬──────┘
       │ edit file
       ↓
┌─────────────┐
│  Modified   │ ← Changed but not staged
└──────┬──────┘
       │ git add
       └──────→ Back to Staged
```

---

## References and HEAD

### Branches
- **What**: Movable pointers to commits
- **Location**: `.git/refs/heads/<branch-name>`
- **Content**: SHA-1 of commit

```bash
# View branch reference
cat .git/refs/heads/main
# Output: 3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b
```

### HEAD
- **What**: Pointer to current branch or commit
- **Location**: `.git/HEAD`
- **Content**: Reference to branch

```bash
cat .git/HEAD
# Output: ref: refs/heads/main
```

**Detached HEAD**: When HEAD points directly to commit (not branch)

### Tags
- **Lightweight**: Simple pointer (like branch that never moves)
  - Location: `.git/refs/tags/<tag-name>`
- **Annotated**: Full object with metadata
  - Stored in objects database

---

## Git Commands by Category

### 1. Repository Setup

```bash
# Initialize new repository
git init

# Clone existing repository
git clone <url>

# Clone specific branch
git clone -b <branch> <url>

# Clone with depth (shallow clone)
git clone --depth 1 <url>
```

### 2. Configuration

```bash
# Set user name
git config --global user.name "Your Name"

# Set email
git config --global user.email "you@example.com"

# View all config
git config --list

# View specific config
git config user.name

# Edit config file
git config --global --edit

# Set default branch name
git config --global init.defaultBranch main
```

### 3. Working with Changes

```bash
# Check status
git status

# Shorter status
git status -s

# Add file to staging
git add <file>

# Add all files
git add .
git add -A

# Add interactively
git add -i

# Add part of file
git add -p <file>

# Remove from staging (unstage)
git reset <file>
git restore --staged <file>

# Discard changes in working directory
git checkout -- <file>
git restore <file>

# View differences
git diff                    # Working vs Staging
git diff --staged           # Staging vs Repository
git diff HEAD               # Working vs Repository
git diff <commit> <commit>  # Between commits
git diff <branch1> <branch2> # Between branches
```

### 4. Committing

```bash
# Commit staged changes
git commit -m "message"

# Commit with detailed message
git commit

# Commit all tracked changes (skip staging)
git commit -a -m "message"

# Amend last commit
git commit --amend

# Amend without changing message
git commit --amend --no-edit

# Empty commit (no changes)
git commit --allow-empty -m "message"
```

### 5. Viewing History

```bash
# View commit history
git log

# One line per commit
git log --oneline

# Graph view
git log --graph --oneline --all

# Show changes in commits
git log -p

# Show last N commits
git log -n 5

# Show commits by author
git log --author="John"

# Show commits in date range
git log --since="2 weeks ago"
git log --after="2024-01-01" --before="2024-12-31"

# Show commits affecting file
git log -- <file>

# Show who changed what in file
git blame <file>

# View specific commit
git show <commit>

# View file at specific commit
git show <commit>:<file>

# Search commits
git log --grep="bug fix"
git log -S "function_name"  # Search code changes
```

### 6. Branching

```bash
# List branches
git branch              # Local
git branch -r           # Remote
git branch -a           # All

# Create branch
git branch <branch-name>

# Create and switch to branch
git checkout -b <branch-name>
git switch -c <branch-name>

# Switch branch
git checkout <branch-name>
git switch <branch-name>

# Rename branch
git branch -m <old-name> <new-name>

# Delete branch
git branch -d <branch-name>     # Safe delete
git branch -D <branch-name>     # Force delete

# Delete remote branch
git push origin --delete <branch-name>

# View merged branches
git branch --merged
git branch --no-merged
```

### 7. Merging

```bash
# Merge branch into current
git merge <branch-name>

# Merge without fast-forward
git merge --no-ff <branch-name>

# Squash merge (combine all commits)
git merge --squash <branch-name>

# Abort merge
git merge --abort

# View merge conflicts
git diff --name-only --diff-filter=U
```

### 8. Rebasing

```bash
# Rebase current branch onto another
git rebase <branch>

# Interactive rebase (edit history)
git rebase -i <commit>
git rebase -i HEAD~3

# Continue after resolving conflicts
git rebase --continue

# Skip current commit
git rebase --skip

# Abort rebase
git rebase --abort

# Rebase onto different base
git rebase --onto <newbase> <oldbase> <branch>
```

### 9. Remote Operations

```bash
# View remotes
git remote -v

# Add remote
git remote add <name> <url>

# Remove remote
git remote remove <name>

# Rename remote
git remote rename <old> <new>

# Fetch from remote
git fetch <remote>
git fetch --all

# Pull (fetch + merge)
git pull

# Pull with rebase
git pull --rebase

# Push to remote
git push <remote> <branch>

# Push all branches
git push --all

# Push tags
git push --tags

# Force push (dangerous!)
git push --force
git push --force-with-lease  # Safer

# Set upstream branch
git push -u origin <branch>
```

### 10. Stashing

```bash
# Stash current changes
git stash

# Stash with message
git stash save "message"

# List stashes
git stash list

# Apply latest stash
git stash apply

# Apply and remove stash
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Drop stash
git stash drop stash@{0}

# Clear all stashes
git stash clear

# Create branch from stash
git stash branch <branch-name>
```

### 11. Tagging

```bash
# List tags
git tag

# Create lightweight tag
git tag <tag-name>

# Create annotated tag
git tag -a <tag-name> -m "message"

# Tag specific commit
git tag <tag-name> <commit>

# View tag details
git show <tag-name>

# Delete tag
git tag -d <tag-name>

# Push tag to remote
git push origin <tag-name>

# Push all tags
git push --tags
```

### 12. Undoing Changes

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard <commit>

# Revert commit (create new commit)
git revert <commit>

# Revert multiple commits
git revert <oldest>..<newest>

# Remove untracked files
git clean -n             # Dry run
git clean -f             # Remove files
git clean -fd            # Remove files and directories
git clean -fdx           # Include ignored files
```

### 13. Inspecting Objects

```bash
# Show object type
git cat-file -t <sha1>

# Show object content
git cat-file -p <sha1>

# Show object size
git cat-file -s <sha1>

# List all objects
find .git/objects -type f

# Verify repository integrity
git fsck

# Count objects
git count-objects -v

# Garbage collection
git gc
```

### 14. Advanced Commands

```bash
# Cherry-pick commit
git cherry-pick <commit>

# Find commit that introduced bug
git bisect start
git bisect bad                  # Current is bad
git bisect good <commit>        # Known good commit
# Git checks out middle commit, test and mark:
git bisect good/bad
# Repeat until found
git bisect reset

# Find who introduced line
git blame <file>

# Show reference log
git reflog

# Recover deleted commit
git reflog
git checkout <commit>

# Create patch
git format-patch <commit>

# Apply patch
git apply <patch>
git am <patch>

# Submodules
git submodule add <url>
git submodule init
git submodule update
git submodule update --remote
```

---

## Internal Workflow Example

Let's trace what happens internally when you make a commit:

### Step 1: Initialize Repository
```bash
git init myproject
cd myproject
```

**What happens**:
- Creates `.git/` directory
- Creates subdirectories: `objects/`, `refs/`, `hooks/`, etc.
- Creates `HEAD` file pointing to `refs/heads/main`

### Step 2: Create File
```bash
echo "Hello Git" > hello.txt
```

**State**: File in working directory (untracked)

### Step 3: Stage File
```bash
git add hello.txt
```

**What happens**:
1. Git computes SHA-1 of content: `8d0e41...`
2. Compresses content with zlib
3. Stores in `.git/objects/8d/0e41...` (blob object)
4. Updates `.git/index` with filename → blob mapping

**State**: File staged (in index)

### Step 4: Commit
```bash
git commit -m "Initial commit"
```

**What happens**:
1. Git reads staged files from index
2. Creates **tree object** representing directory structure
   - Stores tree in `.git/objects/...`
3. Creates **commit object** with:
   - Pointer to tree
   - Author/committer info
   - Commit message
4. Stores commit in `.git/objects/...`
5. Updates branch reference (`.git/refs/heads/main`) to commit SHA-1
6. HEAD points to main, which points to commit

### Step 5: Modify and Commit Again
```bash
echo "More content" >> hello.txt
git add hello.txt
git commit -m "Add more content"
```

**What happens**:
1. New blob created (different SHA-1)
2. New tree object (references new blob)
3. New commit object (parent = previous commit)
4. Branch reference updated to new commit

---

## Visualization of Git Object Model

```
Commit Tree:

commit a1b2c3 ────────┐
│ tree: t1           │
│ parent: d4e5f6     │
│ message: "Fix bug" │
└────────────────────┘
         │
         │ points to
         ↓
tree t1 ─────────────┐
│ hello.txt → blob1  │
│ src/ → tree2       │
└────────────────────┘
         │
         ├─→ blob1 (content: "Hello Git")
         │
         └─→ tree2 ────────────┐
             │ app.py → blob3  │
             └─────────────────┘
                      │
                      └─→ blob3 (content: "print('hi')")
```

---

## Git Directory Structure

```
.git/
├── HEAD                      # Points to current branch
├── config                    # Local config
├── description              # Repository description
├── index                    # Staging area (binary)
├── hooks/                   # Git hooks (scripts)
│   ├── pre-commit
│   ├── post-commit
│   └── ...
├── info/                    # Global excludes
│   └── exclude
├── objects/                 # Object database
│   ├── pack/               # Packed objects
│   ├── info/
│   ├── 8d/
│   │   └── 0e41234...      # Blob/tree/commit objects
│   └── ...
├── refs/                    # References
│   ├── heads/              # Branch refs
│   │   ├── main
│   │   └── feature
│   ├── remotes/            # Remote refs
│   │   └── origin/
│   │       └── main
│   └── tags/               # Tag refs
│       └── v1.0.0
└── logs/                    # Reflog
    ├── HEAD
    └── refs/...
```

---

## Common Workflows

### Feature Branch Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Implement feature"

# Push to remote
git push -u origin feature/new-feature

# Merge to main
git checkout main
git merge feature/new-feature
git push

# Delete feature branch
git branch -d feature/new-feature
git push origin --delete feature/new-feature
```

### Fixing Mistakes

```bash
# Oops, forgot to add file to last commit
git add forgotten_file.txt
git commit --amend --no-edit

# Oops, committed to wrong branch
git reset --soft HEAD~1   # Undo commit, keep changes
git stash                 # Save changes
git checkout correct-branch
git stash pop
git commit -m "Right place now"

# Oops, need to change commit message
git commit --amend -m "Better message"

# Oops, pushed bad commit
git revert <commit>       # Safe: creates new commit
git push
```

---

## Best Practices

1. **Commit Often**: Small, logical commits
2. **Write Good Messages**: Explain why, not what
3. **Use Branches**: Keep main stable
4. **Pull Before Push**: Stay in sync
5. **Review Before Commit**: Use `git diff --staged`
6. **Don't Rewrite Public History**: Avoid force push on shared branches
7. **Use `.gitignore`**: Don't commit generated files
8. **Tag Releases**: Mark important milestones

---

## Pro Tips

```bash
# View pretty log
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit

# Create alias
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Use it
git lg

# Find deleted file
git log --all --full-history -- "**/myfile.txt"

# Undo git add before commit
git reset

# Show files in commit
git diff-tree --no-commit-id --name-only -r <commit>

# Search code across all branches
git grep "search term" $(git rev-list --all)
```

---

## Summary

**Core Concepts**:
- **Working Directory**: Your files
- **Staging Area**: Prepared snapshot
- **Repository**: Permanent history
- **Objects**: Blobs (content), Trees (structure), Commits (snapshots)
- **References**: Pointers to commits (branches, tags, HEAD)

**Key Understanding**: Git is a content-addressable filesystem. Everything is a snapshot, not a delta. Each commit is a complete snapshot of your project at that point in time.

