#!/usr/bin/env bash
# Safety Net - RM/File Deletion Rules
# Blocks dangerous file deletion operations
# Part of mannay-claude-code plugin

# Protected paths that should never be deleted
PROTECTED_PATHS=(
  "/"
  "/etc"
  "/usr"
  "/var"
  "/bin"
  "/sbin"
  "/lib"
  "/opt"
  "/System"
  "/Applications"
  "/Library"
  "$HOME"
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/.config"
  "$HOME/.local"
)

# Check if a path is safe to delete
# Returns 0 if safe, 1 if dangerous
is_safe_path() {
  local path="$1"
  local original_path="$path"

  # Expand ~ to $HOME
  path="${path/#\~/$HOME}"

  # Expand $HOME variable
  if [[ "$path" == *'$HOME'* ]]; then
    path="${path//\$HOME/$HOME}"
  fi

  # Expand ${HOME} variable
  if [[ "$path" == *'${HOME}'* ]]; then
    path="${path//\$\{HOME\}/$HOME}"
  fi

  # Block root filesystem
  if [[ "$path" == "/" || "$path" == "/*" || "$path" == "/." ]]; then
    return 1
  fi

  # Block home directory itself
  if [[ "$path" == "$HOME" || "$path" == "$HOME/" ]]; then
    return 1
  fi

  # Block current directory (.) entirely
  if [[ "$path" == "." || "$path" == "./" ]]; then
    return 1
  fi

  # Block parent directory traversal to dangerous paths
  # Resolve .. in path
  if [[ "$path" == *".."* ]]; then
    # Try to resolve the path
    local resolved
    if resolved=$(cd "$(dirname "$path")" 2>/dev/null && pwd -P)/$(basename "$path"); then
      path="$resolved"
    fi
  fi

  # Check against protected paths
  for protected in "${PROTECTED_PATHS[@]}"; do
    # Expand variables in protected path
    local expanded_protected="${protected//\$HOME/$HOME}"

    # Exact match
    if [[ "$path" == "$expanded_protected" ]]; then
      return 1
    fi

    # Direct child of protected path (e.g., /etc/passwd)
    if [[ "$path" == "$expanded_protected/"* ]]; then
      # Exception: allow /tmp/* and /var/tmp/*
      if [[ "$expanded_protected" == "/var" && "$path" == "/var/tmp/"* ]]; then
        return 0
      fi
      # Block other protected path children if paranoid mode
      if is_paranoid_mode 2>/dev/null; then
        return 1
      fi
    fi
  done

  # Allow /tmp/* always
  if [[ "$path" == "/tmp" || "$path" == "/tmp/"* ]]; then
    return 0
  fi

  # Allow /var/tmp/* always
  if [[ "$path" == "/var/tmp" || "$path" == "/var/tmp/"* ]]; then
    return 0
  fi

  # Allow relative paths (within project) by default
  if [[ "$path" != /* ]]; then
    # In paranoid mode, block rm -rf on current directory patterns
    if is_paranoid_mode 2>/dev/null; then
      if [[ "$original_path" == "*" || "$original_path" == "./*" ]]; then
        return 1
      fi
    fi
    return 0  # Relative paths are generally safe
  fi

  # Block other absolute paths by default
  # (anything not explicitly allowed above)
  return 1
}

# Extract paths from rm command
# Handles various rm flag combinations
extract_rm_paths() {
  local cmd="$1"
  local paths=()

  # Remove 'rm' and flags, keep paths
  # This is a simplified extraction - handles common cases
  local args="${cmd#rm }"

  # Skip flags (words starting with -)
  local in_path=false
  for arg in $args; do
    if [[ "$arg" == -* ]]; then
      # Skip flags, but note some flags take arguments
      continue
    else
      # This is a path
      echo "$arg"
    fi
  done
}

# Check rm-specific rules
# Returns 0 if command is safe, 1 if blocked
check_rm_rules() {
  local cmd="$1"

  # Only check commands that start with rm
  if ! [[ "$cmd" =~ ^[[:space:]]*rm[[:space:]] ]]; then
    return 0  # Not an rm command, allow
  fi

  # Check for recursive flag (-r or -R or --recursive)
  local is_recursive=false
  if [[ "$cmd" =~ [[:space:]]-[a-zA-Z]*[rR] ]] || [[ "$cmd" =~ --recursive ]]; then
    is_recursive=true
  fi

  # Check for force flag (-f or --force)
  local is_force=false
  if [[ "$cmd" =~ [[:space:]]-[a-zA-Z]*f ]] || [[ "$cmd" =~ --force ]]; then
    is_force=true
  fi

  # Extract and check each path
  while IFS= read -r path; do
    [ -z "$path" ] && continue

    # Skip if path is empty or just whitespace
    path="${path#"${path%%[![:space:]]*}"}"
    path="${path%"${path##*[![:space:]]}"}"
    [ -z "$path" ] && continue

    if ! is_safe_path "$path"; then
      if [ "$is_recursive" = true ] && [ "$is_force" = true ]; then
        block "rm -rf on '$path' is blocked. This path is protected to prevent accidental data loss."
      elif [ "$is_recursive" = true ]; then
        block "rm -r on '$path' is blocked. This path is protected to prevent accidental data loss."
      else
        block "rm on '$path' is blocked. This path is protected."
      fi
      return 1
    fi
  done < <(extract_rm_paths "$cmd")

  # In paranoid mode, block rm -rf even on seemingly safe paths
  if is_paranoid_mode 2>/dev/null && [ "$is_recursive" = true ] && [ "$is_force" = true ]; then
    # Still allow known safe patterns
    if [[ "$cmd" =~ rm[[:space:]]+-rf?[[:space:]]+(node_modules|dist|build|\.next|__pycache__|\.cache|coverage|\.nyc_output)/? ]]; then
      return 0  # Common build artifacts are always allowed
    fi
  fi

  return 0  # Command is safe
}

# Check other file deletion commands
check_file_deletion_rules() {
  local cmd="$1"

  # Check unlink command
  if [[ "$cmd" =~ ^[[:space:]]*unlink[[:space:]] ]]; then
    local path="${cmd#*unlink }"
    path="${path%% *}"
    if ! is_safe_path "$path"; then
      block "unlink on '$path' is blocked. This path is protected."
      return 1
    fi
  fi

  # Check rmdir command (less dangerous but still check)
  if [[ "$cmd" =~ ^[[:space:]]*rmdir[[:space:]] ]]; then
    # rmdir only removes empty directories, less dangerous
    # But still check protected paths
    local args="${cmd#*rmdir }"
    for arg in $args; do
      if [[ "$arg" != -* ]] && ! is_safe_path "$arg"; then
        block "rmdir on '$arg' is blocked. This path is protected."
        return 1
      fi
    done
  fi

  return 0
}
