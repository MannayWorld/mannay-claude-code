# Contributing

## Release Checklist

When releasing a new version, update ALL of these:

1. `.claude-plugin/plugin.json` - version field
2. `.claude-plugin/marketplace.json` - version field
3. `CHANGELOG.md` - add new version section
4. `README.md` - version badge
5. `docs/_layouts/default.html` - sidebar version
6. `docs/index.md` - version number

Then commit and push to GitHub.

**Why all these files?** Claude Code reads version from plugin.json and marketplace.json. The others are for user visibility.
