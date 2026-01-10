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

## For Plugin Developers

### Version must be updated in plugin.json

When releasing a new version, you **MUST** update the version in `.claude-plugin/plugin.json`:

```json
{
  "name": "mannay-claude-code",
  "version": "1.5.0",  // <-- UPDATE THIS!
  ...
}
```

Claude Code uses this version number to determine if an update is available. If you only update README/CHANGELOG but not plugin.json, users won't get the update.

**Checklist for releases:**
1. Update `.claude-plugin/plugin.json` version
2. Update `.claude-plugin/marketplace.json` version
3. Update `CHANGELOG.md`
4. Update `README.md` version badge
5. Update `docs/_layouts/default.html` sidebar version
6. Update `docs/index.md` version
7. Commit and push to GitHub

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
