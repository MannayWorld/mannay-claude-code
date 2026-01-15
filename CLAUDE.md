# Mannay Claude Code Plugin

Plugin with skills, agents, and commands. Use `Skill` tool to invoke skills when relevant.

## Key Skills

| Skill | When to Use |
|-------|-------------|
| `mannay-claude-code:git` | Any git operation (commit, push, PR) |
| `mannay-claude-code:brainstorming` | New features, design decisions |
| `mannay-claude-code:systematic-debugging` | Bugs, errors, investigations |
| `mannay-claude-code:test-driven-development` | Writing/modifying code |
| `mannay-claude-code:adaptive-design` | **MANDATORY** for visual components - real data, edge cases, responsive |
| `mannay-claude-code:ui-animation` | **MANDATORY** for visual components - animations, timing, easing |

## Git Rules

- Use conventional commits: `type(scope): description`
- NO Co-Authored-By or Signed-off-by footers
- Subject line ≤50 characters

## Code Style

- TypeScript strict mode
- Functional patterns
- No unnecessary abstractions
