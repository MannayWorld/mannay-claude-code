# Mannay Claude Code Plugin

This is the Mannay Claude Code plugin repository - a comprehensive toolkit of skills, agents, and commands for Claude Code.

## CRITICAL: Skill Activation Rules

**You MUST use the `Skill` tool to invoke skills. This is NOT optional.**

### Mandatory Skills (Auto-Activate)

| Trigger | Skill | When |
|---------|-------|------|
| Any code change | `mannay-claude-code:test-driven-development` | Writing/modifying ANY code |
| Any bug/error | `mannay-claude-code:systematic-debugging` | Fixing, troubleshooting, investigating |
| Any new feature | `mannay-claude-code:brainstorming` | Creating something new |
| Any git operation | `mannay-claude-code:git` | Commits, branches, PRs, push, merge |

### Git Operations - ALWAYS Use Git Skill

**Before ANY git operation (commit, push, branch, merge, PR), you MUST:**
```
Skill("mannay-claude-code:git")
```

**Key Git Rules (from the skill):**
- NO `Co-Authored-By` footers - EVER
- NO `Signed-off-by` footers
- NO credits or attributions in commits
- Use conventional commits: `type(scope): description`
- Subject line ≤50 characters

### How to Invoke Skills

```
Skill("mannay-claude-code:skill-name")
```

Examples:
- `Skill("mannay-claude-code:git")` - For any git operation
- `Skill("mannay-claude-code:test-driven-development")` - For any code changes
- `Skill("mannay-claude-code:brainstorming")` - For new features

## Project Structure

```
agents/           # Domain expert agents (15+)
skills/           # Process workflow skills (10+)
commands/         # Quick action commands
hooks/            # Session and prompt hooks
docs/             # Documentation site
```

## Common Commands

- Build docs: `cd docs && bundle exec jekyll serve`
- Run tests: `./tests/*/test.sh`

## Code Style

- TypeScript with strict mode
- Functional patterns preferred
- Descriptive variable names
- No unnecessary abstractions

## DO NOT

- Add Co-Authored-By to ANY commit message
- Skip using skills when they apply
- Write code without tests (TDD)
- Fix bugs without systematic debugging
- Start features without brainstorming
