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

## Nuclear Option

If nothing else works, completely reset the plugin system:

```bash
# Remove ALL mannay-claude-code traces
rm -rf ~/.claude/plugins/cache/mannay-claude-code
rm -rf ~/.claude/plugins/marketplaces/mannay-claude-code
rm ~/.claude/plugins/installed_plugins.json

# Edit settings.json to remove the plugin entry
# Remove: "mannay-claude-code@mannay-claude-code": true
```

Then:
1. Quit Claude Code
2. Reopen Claude Code
3. Add marketplace: `/plugin marketplace add MannayWorld/mannay-claude-code`
4. Install: `/plugin install mannay-claude-code@mannay-claude-code`

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
