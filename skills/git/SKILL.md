---
name: git
description: "All git operations: commits, branches, PRs, merging, rebasing, stashing. MANDATORY for any git operation. Activates automatically when working with version control."
always_active_for:
  - "committing code"
  - "pushing changes"
  - "creating branches"
  - "creating PRs"
  - "merging code"
triggers:
  - "commit"
  - "push"
  - "branch"
  - "merge"
  - "PR"
  - "pull request"
  - "stash"
  - "rebase"
---

# Git Operations

Standard git workflows following conventional commits and best practices.

---

## Conventional Commits

### Format
```
<type>(<scope>): <description>
```

### Types

| Type | Use |
|------|-----|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting |
| `refactor` | Code restructure |
| `perf` | Performance |
| `test` | Tests |
| `build` | Build/deps |
| `ci` | CI/CD |
| `chore` | Maintenance |

### Rules

1. Subject ≤50 chars
2. Imperative mood: "Add" not "Added"
3. No period at end
4. Capitalize first letter
5. Body wrapped at 72 chars

### What NOT to Include

- NO `Co-Authored-By` footers
- NO `Signed-off-by` footers
- NO credits or attributions
- NO vague messages ("Update files", "Fix bug")
- NO secrets or keys

---

## Commits

### Basic Commit
```bash
git add .
git commit -m "feat(scope): add new feature"
```

### Multi-line Commit
```bash
git commit -m "$(cat <<'EOF'
feat(auth): add password reset

- Add reset endpoint
- Create email template
- Add token validation
EOF
)"
```

### Breaking Change
```bash
git commit -m "feat(api)!: change response format"
```

---

## Branches

### Create Branch
```bash
# From current branch
git checkout -b feature/branch-name

# From specific branch
git checkout -b feature/branch-name main
```

### Branch Naming
```
feature/description    # New features
fix/description        # Bug fixes
docs/description       # Documentation
refactor/description   # Refactoring
```

### List/Switch
```bash
git branch              # List local
git branch -a           # List all
git checkout main       # Switch
git switch feature/x    # Switch (newer)
```

### Delete Branch
```bash
git branch -d branch-name      # Safe delete
git push origin --delete name  # Delete remote
```

---

## Push/Pull

### Push
```bash
git push                           # Current branch
git push -u origin branch-name     # First push, set upstream
git push origin branch-name        # Specific branch
```

### Pull
```bash
git pull                    # Fetch + merge
git pull --rebase           # Fetch + rebase (cleaner history)
git fetch && git merge      # Explicit
```

### Force Push (CAREFUL)
```bash
git push --force-with-lease  # Safe force (checks remote)
# NEVER use --force on shared branches
```

---

## Pull Requests

### Create PR (GitHub CLI)
```bash
gh pr create --title "feat: description" --body "$(cat <<'EOF'
## Summary
- Change 1
- Change 2

## Test Plan
- [ ] Test case 1
- [ ] Test case 2
EOF
)"
```

### PR Title Format
Same as commit: `feat(scope): description`

### Review PR
```bash
gh pr view 123
gh pr diff 123
gh pr checkout 123
```

---

## Merging

### Merge Branch
```bash
git checkout main
git merge feature/branch-name
```

### Squash Merge (cleaner history)
```bash
git merge --squash feature/branch-name
git commit -m "feat: squashed feature"
```

### Resolve Conflicts
```bash
# After conflict
git status                    # See conflicted files
# Edit files, remove conflict markers
git add .
git commit -m "fix: resolve merge conflicts"
```

---

## Rebasing

### Rebase onto main
```bash
git checkout feature/branch
git rebase main
```

### Interactive Rebase (clean up commits)
```bash
git rebase -i HEAD~3          # Last 3 commits
# pick, squash, reword, drop
```

### After Rebase
```bash
git push --force-with-lease   # Required after rebase
```

---

## Stashing

### Stash Changes
```bash
git stash                     # Stash tracked
git stash -u                  # Include untracked
git stash save "description"  # With message
```

### Apply Stash
```bash
git stash pop                 # Apply + remove
git stash apply               # Apply, keep stash
git stash list                # List stashes
git stash drop stash@{0}      # Delete specific
```

---

## Undoing

### Unstage Files
```bash
git reset HEAD file.txt       # Unstage file
git reset HEAD                # Unstage all
```

### Discard Changes
```bash
git checkout -- file.txt      # Discard file changes
git restore file.txt          # Newer syntax
```

### Amend Last Commit
```bash
git commit --amend -m "new message"
# ONLY if not pushed yet
```

### Revert Commit (safe)
```bash
git revert <commit-hash>      # Creates new commit undoing changes
```

---

## Status & History

### Status
```bash
git status
git status -s                 # Short format
git diff --stat               # Summary of changes
```

### History
```bash
git log --oneline -10         # Last 10, compact
git log --graph --oneline     # With branch graph
git show <commit>             # Show commit details
```

---

## Quick Workflows

### Feature Development
```bash
git checkout -b feature/name
# ... make changes ...
git add .
git commit -m "feat(scope): description"
git push -u origin feature/name
gh pr create --title "feat(scope): description"
```

### Bug Fix
```bash
git checkout -b fix/bug-name
# ... fix bug ...
git add .
git commit -m "fix(scope): description"
git push -u origin fix/bug-name
gh pr create --title "fix(scope): description"
```

### Update Branch with Main
```bash
git checkout feature/branch
git fetch origin
git rebase origin/main
git push --force-with-lease
```

---

## Integration

**Called by:**
- `test-driven-development` — After tests pass, commit
- `systematic-debugging` — After fix verified, commit
- `executing-plans` — After task completion, commit
- `ralph-mode` — After each story, commit
- Any skill after code changes

**Pairs with:**
- All implementation skills — Commit after work
- `requesting-code-review` — Push before PR
- GitHub CLI (`gh`) — For PR creation

---

## Safety Rules

**NEVER:**
- `git push --force` on main/master
- `git reset --hard` without understanding
- Commit secrets, passwords, API keys
- Rebase shared/public branches
- `git clean -f` without checking

**ALWAYS:**
- Use `--force-with-lease` instead of `--force`
- Check `git status` before committing
- Pull before pushing to shared branches
- Create branches for features/fixes
