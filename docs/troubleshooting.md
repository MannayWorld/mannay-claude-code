# Troubleshooting

> Common issues and solutions for Mannay Claude Code plugin.

## Plugin Installation Issues

### "Plugin is already installed" but not showing

**Symptoms:**
- `/plugin install` says "already installed"
- Plugin doesn't appear in `/plugin` → Installed tab
- Agents/skills/commands not working

**Solution:**

1. Clean all plugin state:
```bash
rm -rf ~/.claude/plugins/cache/mannay-claude-code
rm ~/.claude/plugins/installed_plugins.json
```

2. Remove from settings.json - edit `~/.claude/settings.json` and remove the line:
```json
"mannay-claude-code@mannay-claude-code": true
```

3. Quit Claude Code completely

4. Reopen Claude Code

5. Reinstall:
```bash
/plugin install mannay-claude-code@mannay-claude-code
```

---

### ENAMETOOLONG error (recursive directory)

**Symptoms:**
- Error in `/plugin` → Errors tab
- Path shows repeating `mannay-claude-code/1.3.0/mannay-claude-code/1.3.0/...`
- `ENAMETOOLONG: name too long, copyfile` error

**Solution:**

Same as above - the recursive cache needs to be deleted:
```bash
rm -rf ~/.claude/plugins/cache/mannay-claude-code
```

---

### Plugin cache out of sync

**Symptoms:**
- Plugin installed but using old version
- New features/fixes not appearing after update

**Solution:**

Force refresh by clearing cache:
```bash
rm -rf ~/.claude/plugins/cache/mannay-claude-code
```

Then restart Claude Code. It will re-download the latest version.

---

## Hook Errors

### "Stop hook error" on session end

**Symptoms:**
- Error message when closing Claude Code
- References `ralph-stop.sh` not found

**Solution:**

This was fixed in v1.3.0. Update your plugin:
```bash
rm -rf ~/.claude/plugins/cache/mannay-claude-code
```
Then restart Claude Code.

---

### "UserPromptSubmit hook error"

**Symptoms:**
- Error on every message you send
- Hook script not found

**Solution:**

Clear cache and reinstall:
```bash
rm -rf ~/.claude/plugins/cache/mannay-claude-code
rm ~/.claude/plugins/installed_plugins.json
```
Restart Claude Code and reinstall the plugin.

---

## Memory System Issues

### Memory database not created

**Symptoms:**
- `/memory-status` says "No memory database found"
- No `.claude/memory/` folder in your project
- Memory features not working

**Cause:**

After clearing the plugin cache, the memory dependencies (`better-sqlite3`) need to be reinstalled. The plugin auto-installs them in the background, but it may not complete before your first session.

**Solution:**

1. Manually install memory dependencies:
```bash
cd ~/.claude/plugins/cache/mannay-claude-code/mannay-claude-code/*/memory
npm install
```

2. Manually initialize the database for your project:
```bash
cd /path/to/your/project
CLAUDE_PROJECT_ROOT="$(pwd)" node ~/.claude/plugins/cache/mannay-claude-code/mannay-claude-code/*/memory/hooks/session-start.js <<< '{}'
```

3. Verify it worked:
```bash
ls -la .claude/memory/memory.db
```

4. Restart Claude Code

**Note:** After this fix, the memory system will work automatically for all future sessions in this project.

---

### Memory not persisting between sessions

**Symptoms:**
- Learnings not being recalled
- Session state not restored after compaction

**Cause:**

The memory database is per-project, stored in `PROJECT_ROOT/.claude/memory/`. If you're opening Claude Code from different directories, each gets its own database.

**Solution:**

Always open Claude Code from your project root directory:
```bash
cd /path/to/your/project
claude
```

---

## Progress Tracking Issues

### Session crashed during plan execution

**Symptoms:**
- Session crashed or context filled mid-task
- Unsure what tasks were completed
- Need to resume from where left off

**Solution:**

Check the progress files alongside your plan:

```bash
# Look for progress files
ls planning/*-progress.*

# Read the human-readable dashboard
cat planning/YYYY-MM-DD-feature-progress.md

# Check the plan file for ✅ markers
grep "✅" planning/YYYY-MM-DD-feature.md
```

When you start a new session, the executing-plans skill automatically:
1. Detects existing progress files
2. Resumes from the first incomplete task
3. Shows you what was already completed

---

### Progress files not being created

**Symptoms:**
- No `-progress.json` or `-progress.md` files alongside plans
- Old plans don't have progress tracking

**Cause:**

Progress tracking was added recently. Plans created before this feature won't have progress files.

**Solution:**

For new plans, progress files are created automatically by the writing-plans skill.

For old plans, manually initialize:
```javascript
// In Claude, ask:
"Initialize progress tracking for planning/YYYY-MM-DD-feature.md"
```

---

### Progress out of sync with actual state

**Symptoms:**
- Progress shows task incomplete but code is committed
- ✅ markers missing but work was done

**Solution:**

1. Check git for actual completed work:
```bash
git log --oneline -10
```

2. Manually update the progress.json or ask Claude to sync it
3. The plan file ✅ markers can be added manually if needed

---

## Nuclear Option

If nothing else works, completely reset the plugin system:

```bash
# 1. Remove cache
rm -rf ~/.claude/plugins/cache/mannay-claude-code

# 2. Remove marketplace
rm -rf ~/.claude/plugins/marketplaces/mannay-claude-code

# 3. Remove installed plugins registry
rm ~/.claude/plugins/installed_plugins.json

# 4. Edit known_marketplaces.json - remove the entire "mannay-claude-code": {...} block
nano ~/.claude/plugins/known_marketplaces.json

# 5. Edit settings.json - remove the line:
#    "mannay-claude-code@mannay-claude-code": true
nano ~/.claude/settings.json
```

Then:
1. **Quit Claude Code completely** (Cmd+Q, not just close window)
2. Reopen Claude Code
3. Add marketplace: `/plugin marketplace add MannayWorld/mannay-claude-code`
4. Install: `/plugin install mannay-claude-code`

## Updating the Plugin

**Important:** Claude Code has bugs with plugin updates ([#14061](https://github.com/anthropics/claude-code/issues/14061), [#15672](https://github.com/anthropics/claude-code/issues/15672)). The "Update Now" button often doesn't work properly.

**Reliable update method:**

```bash
# 1. Delete the cache
rm -rf ~/.claude/plugins/cache/mannay-claude-code

# 2. Pull latest in marketplace
cd ~/.claude/plugins/marketplaces/mannay-claude-code
git pull origin main

# 3. Restart Claude Code
```

If that doesn't work, use the Nuclear Option above.

---

## Context Usage / Token Optimization

### High context usage at session start

**Symptoms:**
- 15-20%+ context used before asking any questions
- Status bar shows high token usage immediately
- Sessions fill up quickly

**Cause:**

MCP servers load ALL tool definitions into the system prompt at startup. Each server adds hundreds to thousands of tokens regardless of whether you use them.

---

### Solution 1: Enable Lazy Loading (Recommended)

Claude Code has an experimental mode that loads MCP tools on-demand instead of at startup.

**Setup (one-time):**

```bash
# For Zsh (default on macOS)
echo 'export ENABLE_EXPERIMENTAL_MCP_CLI=true' >> ~/.zshrc
source ~/.zshrc

# For Bash
echo 'export ENABLE_EXPERIMENTAL_MCP_CLI=true' >> ~/.bashrc
source ~/.bashrc

# For Fish
echo 'set -gx ENABLE_EXPERIMENTAL_MCP_CLI true' >> ~/.config/fish/config.fish
```

**Verify it's working:**

1. Restart Claude Code completely (Cmd+Q, then reopen)
2. Run `/context` command
3. MCP tools section should be minimal or absent
4. "Free space" should be significantly higher

**Expected improvement:** Context usage drops from ~60% to ~10% at startup.

---

### Solution 2: Remove Duplicate MCP Servers

MCP servers can be defined in multiple places, causing duplicates. Check all locations:

**Step 1: Check for duplicates**

```bash
# Check all possible MCP config locations
echo "=== Global configs ==="
cat ~/.mcp.json 2>/dev/null || echo "~/.mcp.json: not found"
cat ~/.claude/.mcp.json 2>/dev/null || echo "~/.claude/.mcp.json: not found"

echo ""
echo "=== Project config ==="
cat .mcp.json 2>/dev/null || echo ".mcp.json: not found"

echo ""
echo "=== In settings.json ==="
grep -A10 "mcpServers" ~/.claude/settings.json 2>/dev/null || echo "No mcpServers in settings.json"

echo ""
echo "=== From plugins ==="
find ~/.claude/plugins -name ".mcp.json" 2>/dev/null
```

**Step 2: Remove duplicates**

If the same server (e.g., `playwright`, `context7`) appears in multiple locations:

1. Keep it in ONE place only (recommend: `~/.mcp.json` for global, or `.mcp.json` for project-specific)
2. Delete from other locations
3. Restart Claude Code

**Common duplicate sources:**
- Plugins bundling MCP servers (this plugin no longer does this)
- Both global and project configs defining the same server
- Old configs left over from previous setups

---

### Solution 3: Disable Unused MCP Servers

Remove MCP servers you don't actively use:

```bash
# Edit your MCP config
nano ~/.mcp.json  # or .mcp.json in project root
```

Remove or comment out servers you don't need. Each server adds ~1-3K tokens.

**Solution 3: Use defer_loading (Advanced)**

For API-level control, mark tools with `defer_loading: true`:

```json
{
  "type": "mcp_toolset",
  "mcp_server_name": "playwright",
  "default_config": {"defer_loading": true}
}
```

**Note:** This plugin intentionally does NOT bundle MCP servers to avoid duplication and context bloat. Configure MCP servers separately based on your needs.

---

### Recommended MCP Servers

If you need MCP servers, add them to your global `~/.mcp.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "description": "Library documentation lookup"
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "description": "Browser automation"
    }
  }
}
```

Only add servers you actively use. Each server adds ~1-3K tokens to startup context.

---

## Getting Help

If you're still having issues:

1. Check the [GitHub Issues](https://github.com/MannayWorld/mannay-claude-code/issues)
2. Create a new issue with:
   - Your Claude Code version (`claude --version`)
   - Error message (full text)
   - Steps you've tried

---

## Known Claude Code Bugs

These are upstream issues in Claude Code itself:

| Issue | Status | Workaround |
|-------|--------|------------|
| [#15369](https://github.com/anthropics/claude-code/issues/15369) - Uninstall doesn't clear cache | Open | Manually delete cache |
| [#14061](https://github.com/anthropics/claude-code/issues/14061) - Update doesn't invalidate cache | Open | Manually delete cache |
| [#14815](https://github.com/anthropics/claude-code/issues/14815) - Plugin shows installed but doesn't appear | Open | Delete installed_plugins.json |
