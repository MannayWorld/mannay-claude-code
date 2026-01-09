#!/usr/bin/env bash
# Safety Net - System Command Rules
# Blocks dangerous system-level commands that can bypass other checks or cause system damage
# Part of mannay-claude-code plugin

# Check system-level rules
# Returns 0 if command is safe, 1 if blocked
check_system_rules() {
  local cmd="$1"

  # ===== EVAL/EXEC BYPASS PREVENTION =====
  # eval can execute arbitrary code, bypassing all other checks
  if [[ "$cmd" =~ ^[[:space:]]*eval[[:space:]] ]]; then
    block "eval can bypass safety checks by executing arbitrary code. Use direct commands instead."
    return 1
  fi

  # exec replaces the current shell, bypassing safety checks
  if [[ "$cmd" =~ ^[[:space:]]*exec[[:space:]] ]]; then
    block "exec replaces the shell process and can bypass safety checks. Use direct commands instead."
    return 1
  fi

  # ===== REMOTE CODE EXECUTION =====
  # curl/wget piped to shell (extremely dangerous)
  if [[ "$cmd" =~ (curl|wget)[[:space:]].*\|[[:space:]]*(bash|sh|zsh|dash|ksh|fish) ]]; then
    block "Piping downloaded content to shell is dangerous (remote code execution). Download first, inspect, then run."
    return 1
  fi

  # curl/wget with -o - piped to shell
  if [[ "$cmd" =~ (curl|wget).*-[oO][[:space:]]*-.*\|.*(bash|sh|zsh) ]]; then
    block "Piping downloaded content to shell is dangerous (remote code execution)."
    return 1
  fi

  # source/. with URL (if someone tries to source from network)
  if [[ "$cmd" =~ ^[[:space:]]*(source|\.).*https?:// ]]; then
    block "Sourcing scripts from URLs is dangerous. Download and inspect first."
    return 1
  fi

  # ===== FILE PERMISSION DANGERS =====
  # chmod 777 (world writable - security risk)
  if [[ "$cmd" =~ chmod.*777 ]]; then
    block "chmod 777 makes files world-writable, which is a security vulnerability. Use more restrictive permissions."
    return 1
  fi

  # chmod 000 (no permissions - can lock you out)
  if [[ "$cmd" =~ chmod.*000 ]]; then
    block "chmod 000 removes all permissions, which can make files inaccessible. Use appropriate permissions instead."
    return 1
  fi

  # chmod -R on system paths
  if [[ "$cmd" =~ chmod[[:space:]]+-R.*(/etc|/usr|/var|/bin|/sbin|/lib|/System|/Applications) ]]; then
    block "Recursive chmod on system directories can break the system."
    return 1
  fi

  # chown -R on system paths
  if [[ "$cmd" =~ chown[[:space:]]+-R.*(/etc|/usr|/var|/bin|/sbin|/lib|/System|/Applications) ]]; then
    block "Recursive chown on system directories can break the system."
    return 1
  fi

  # ===== DISK/DATA DESTRUCTION =====
  # dd to disk devices or important files
  if [[ "$cmd" =~ dd[[:space:]].*of=(/dev/|/etc/|/usr/|/var/) ]]; then
    block "dd to system devices or directories can cause data loss or system damage."
    return 1
  fi

  # dd with if=/dev/zero or /dev/urandom to non-tmp paths
  if [[ "$cmd" =~ dd[[:space:]].*if=/dev/(zero|urandom|random) ]] && ! [[ "$cmd" =~ of=/tmp/ ]]; then
    block "dd with /dev/zero or /dev/random can overwrite data. Only allowed to /tmp/."
    return 1
  fi

  # mkfs (format filesystem)
  if [[ "$cmd" =~ ^[[:space:]]*mkfs ]]; then
    block "mkfs formats filesystems and destroys all data. This is blocked for safety."
    return 1
  fi

  # fdisk/parted (partition manipulation)
  if [[ "$cmd" =~ ^[[:space:]]*(fdisk|parted|gdisk|sgdisk)[[:space:]] ]]; then
    block "Partition manipulation tools can cause data loss. This is blocked for safety."
    return 1
  fi

  # ===== PROCESS KILLING =====
  # kill -9 -1 (kill all user processes)
  if [[ "$cmd" =~ kill.*-9.*-1 ]] || [[ "$cmd" =~ kill.*-1.*-9 ]]; then
    block "kill -9 -1 kills all user processes. This is too dangerous to allow."
    return 1
  fi

  # killall without specific process name
  if [[ "$cmd" =~ ^[[:space:]]*killall[[:space:]]*$ ]] || [[ "$cmd" =~ ^[[:space:]]*killall[[:space:]]+-[0-9]+[[:space:]]*$ ]]; then
    block "killall without a specific process name is too broad. Specify the process to kill."
    return 1
  fi

  # pkill -9 without pattern
  if [[ "$cmd" =~ ^[[:space:]]*pkill[[:space:]]+-9[[:space:]]*$ ]]; then
    block "pkill -9 without a pattern is too broad. Specify a process pattern."
    return 1
  fi

  # ===== FORK BOMB PATTERNS =====
  # Classic fork bomb: :(){ :|:& };:
  if [[ "$cmd" =~ :\(\)\{.*:\|:.*\} ]] || [[ "$cmd" =~ :\s*\(\s*\)\s*\{ ]]; then
    block "Fork bomb detected. This would crash the system by exhausting resources."
    return 1
  fi

  # Other fork bomb variants
  if [[ "$cmd" =~ \&[[:space:]]*\&[[:space:]]*\& ]] && [[ "$cmd" =~ \| ]]; then
    # Potential fork bomb pattern
    if is_paranoid_mode 2>/dev/null; then
      block "Suspicious fork-like pattern detected. Blocked in paranoid mode."
      return 1
    fi
  fi

  # ===== FILE CONTENT DESTRUCTION =====
  # truncate -s 0 on important files
  if [[ "$cmd" =~ truncate.*-s[[:space:]]*0.*(/etc/|/usr/|/var/|\$HOME/\.[a-z]) ]]; then
    block "truncate -s 0 empties files. Blocked on system and config files."
    return 1
  fi

  # Redirect to overwrite important files
  if [[ "$cmd" =~ \>[[:space:]]*(/etc/|/usr/|/var/|/System/) ]]; then
    block "Redirecting output to system directories is blocked."
    return 1
  fi

  # ===== PARANOID MODE EXTRAS =====
  if is_paranoid_mode 2>/dev/null; then
    # Block any sudo commands in paranoid mode
    if [[ "$cmd" =~ ^[[:space:]]*sudo[[:space:]] ]]; then
      block "sudo is blocked in paranoid mode."
      return 1
    fi

    # Block any network download tools with execution flags
    if [[ "$cmd" =~ (curl|wget).*(-x|--execute) ]]; then
      block "Download tools with execute flags blocked in paranoid mode."
      return 1
    fi

    # Block any history manipulation
    if [[ "$cmd" =~ history[[:space:]]+-[cd] ]]; then
      block "History manipulation blocked in paranoid mode."
      return 1
    fi
  fi

  return 0  # Command is safe
}

# Check for shell injection patterns
check_injection_patterns() {
  local cmd="$1"

  # Command substitution with dangerous commands
  if [[ "$cmd" =~ \$\(.*rm[[:space:]]+-rf ]] || [[ "$cmd" =~ \`.*rm[[:space:]]+-rf ]]; then
    block "Command substitution containing rm -rf is blocked."
    return 1
  fi

  # Backtick command substitution with dangerous patterns
  if [[ "$cmd" =~ \`.*eval ]] || [[ "$cmd" =~ \`.*exec ]]; then
    block "Command substitution with eval/exec is blocked."
    return 1
  fi

  return 0
}
