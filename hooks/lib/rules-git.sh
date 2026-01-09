#!/usr/bin/env bash
# Safety Net - Git Rules
# Blocks destructive git operations that can cause data loss
# Part of mannay-claude-code plugin

# Check git-specific rules
# Returns 0 if command is safe, 1 if blocked
check_git_rules() {
  local cmd="$1"

  # Only check commands that start with git
  if ! [[ "$cmd" =~ ^[[:space:]]*git[[:space:]] ]]; then
    return 0  # Not a git command, allow
  fi

  # ===== RESET RULES =====
  # git reset --hard destroys uncommitted changes
  if [[ "$cmd" =~ git[[:space:]]+reset ]] && [[ "$cmd" =~ --hard ]]; then
    block "git reset --hard destroys uncommitted work. Use 'git stash' to save changes first, or 'git reset --soft' to keep changes staged."
    return 1
  fi

  # git reset --merge can lose uncommitted changes
  if [[ "$cmd" =~ git[[:space:]]+reset ]] && [[ "$cmd" =~ --merge ]]; then
    block "git reset --merge can lose uncommitted changes. Use 'git stash' first."
    return 1
  fi

  # ===== PUSH RULES =====
  # git push --force without --force-with-lease
  if [[ "$cmd" =~ git[[:space:]]+push ]] && [[ "$cmd" =~ --force ]] && ! [[ "$cmd" =~ --force-with-lease ]]; then
    block "git push --force can overwrite remote history. Use --force-with-lease for safer force push."
    return 1
  fi

  # git push -f (short form)
  if [[ "$cmd" =~ git[[:space:]]+push ]] && [[ "$cmd" =~ [[:space:]]-[a-zA-Z]*f ]] && ! [[ "$cmd" =~ --force-with-lease ]]; then
    # Check it's actually -f flag not part of another word
    if [[ "$cmd" =~ [[:space:]]-f([[:space:]]|$) ]] || [[ "$cmd" =~ [[:space:]]-[a-zA-Z]*f([[:space:]]|$) ]]; then
      block "git push -f can overwrite remote history. Use --force-with-lease for safer force push."
      return 1
    fi
  fi

  # ===== CLEAN RULES =====
  # git clean -f without --dry-run (-n)
  if [[ "$cmd" =~ git[[:space:]]+clean ]] && [[ "$cmd" =~ -[a-zA-Z]*f ]] && ! [[ "$cmd" =~ (--dry-run|-n) ]]; then
    block "git clean -f permanently removes untracked files. Use --dry-run (-n) first to preview what will be deleted."
    return 1
  fi

  # ===== CHECKOUT RULES =====
  # git checkout -- <file> discards changes
  if [[ "$cmd" =~ git[[:space:]]+checkout[[:space:]]+-- ]]; then
    block "git checkout -- discards uncommitted changes to files. Use 'git stash' to save changes first."
    return 1
  fi

  # ===== RESTORE RULES =====
  # git restore without --staged discards working tree changes
  if [[ "$cmd" =~ git[[:space:]]+restore ]] && ! [[ "$cmd" =~ --staged ]] && ! [[ "$cmd" =~ --source ]]; then
    # Check if it's restoring files (not just --help etc)
    if [[ "$cmd" =~ git[[:space:]]+restore[[:space:]]+[^-] ]] || [[ "$cmd" =~ git[[:space:]]+restore[[:space:]]*$ ]]; then
      block "git restore discards working tree changes. Use --staged to only unstage, or 'git stash' to save changes."
      return 1
    fi
  fi

  # ===== BRANCH RULES =====
  # git branch -D (force delete without merge check)
  if [[ "$cmd" =~ git[[:space:]]+branch ]] && [[ "$cmd" =~ [[:space:]]-D([[:space:]]|$) ]]; then
    block "git branch -D force-deletes branch without merge check. Use -d for safe delete with merge verification."
    return 1
  fi

  # ===== STASH RULES =====
  # git stash drop
  if [[ "$cmd" =~ git[[:space:]]+stash[[:space:]]+drop ]]; then
    block "git stash drop permanently removes stashed changes. Consider 'git stash apply' instead to keep the stash."
    return 1
  fi

  # git stash clear
  if [[ "$cmd" =~ git[[:space:]]+stash[[:space:]]+clear ]]; then
    block "git stash clear permanently removes ALL stashed changes. This cannot be undone."
    return 1
  fi

  # ===== REBASE RULES =====
  # git rebase -i (interactive) rewrites history
  if [[ "$cmd" =~ git[[:space:]]+rebase ]] && [[ "$cmd" =~ -i([[:space:]]|$)|--interactive ]]; then
    block "git rebase -i rewrites commit history. This is dangerous for shared branches. Use with caution on local-only branches."
    return 1
  fi

  # ===== HISTORY REWRITING RULES =====
  # git filter-branch (destructive history rewriting)
  if [[ "$cmd" =~ git[[:space:]]+filter-branch ]]; then
    block "git filter-branch destructively rewrites repository history. Consider using 'git filter-repo' for safer alternatives."
    return 1
  fi

  # git reflog expire (destroys recovery options)
  if [[ "$cmd" =~ git[[:space:]]+reflog[[:space:]]+expire ]]; then
    block "git reflog expire removes reflog entries needed for recovery. This limits your ability to undo mistakes."
    return 1
  fi

  # git gc --prune=now (immediate garbage collection)
  if [[ "$cmd" =~ git[[:space:]]+gc ]] && [[ "$cmd" =~ --prune=now ]]; then
    block "git gc --prune=now immediately removes unreachable objects. Use 'git gc' without --prune=now for safer cleanup."
    return 1
  fi

  # git update-ref -d (direct ref deletion)
  if [[ "$cmd" =~ git[[:space:]]+update-ref ]] && [[ "$cmd" =~ [[:space:]]-d([[:space:]]|$) ]]; then
    block "git update-ref -d directly deletes references. Use 'git branch -d' for safer branch deletion."
    return 1
  fi

  # ===== PARANOID MODE EXTRAS =====
  if is_paranoid_mode 2>/dev/null; then
    # Block any rebase in paranoid mode
    if [[ "$cmd" =~ git[[:space:]]+rebase ]]; then
      block "git rebase rewrites history. Blocked in paranoid mode."
      return 1
    fi

    # Block git commit --amend in paranoid mode (history rewriting)
    if [[ "$cmd" =~ git[[:space:]]+commit ]] && [[ "$cmd" =~ --amend ]]; then
      block "git commit --amend rewrites the last commit. Blocked in paranoid mode."
      return 1
    fi
  fi

  return 0  # Command is safe
}
