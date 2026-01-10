# Changelog

All notable changes to mannay-claude-code plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2026-01-10

### Added

**Compound Memory System - Zero-Infrastructure Persistent Memory**
- **Session Continuity** - Automatic state preservation across context compactions via PreCompact/SessionStart hooks
- **Token Optimization** - Tree-sitter-powered signature extraction for large files (60-80% token savings)
- **Semantic Learning** - Cross-session knowledge accumulation with FTS5 full-text search

**New Hooks:**
- `pre-compact.sh` - Saves session state before context compaction
- `session-start.sh` - Restores state and recalls relevant learnings
- `post-tool-track.sh` - Tracks file modifications and decisions
- `pre-read.sh` - Intercepts file reads for signature caching
- `session-end.sh` - Extracts learnings from session

**New Commands:**
- `/memory-status` - Show memory system statistics
- `/memory-learnings` - Display recent cross-session learnings

**New Files:**
- `memory/` directory with SQLite store, Tree-sitter parsers, and learning extraction
- `planning/` directory for internal PRDs and design documents
- `docs/memory-system.md` - Comprehensive memory system documentation

### Changed
- Migrated internal planning documents from `docs/plans/` to `planning/`
- Updated skills to save plans to `planning/` instead of `docs/plans/`
- Documentation website now exclusively in `docs/` folder

### Fixed
- `docs/` folder now cleanly separated from internal planning materials

---

## [1.3.0] - 2026-01-09

### Added

**New Skills:**
- `frontend-design` - Create distinctive, production-grade interfaces avoiding generic AI aesthetics. Includes tone palette, typography guidelines, and anti-patterns to avoid
- `compound-engineering` - Plan (40%) → Work (20%) → Review (20%) → Compound (20%) loop where each unit of work makes future work easier

**Smart Multi-Agent Orchestration:**
- **Mandatory Behaviors** - TDD, debugging, and brainstorming are now ALWAYS ON for their respective task types (no keyword needed)
- **Multi-Agent Chaining** - Tasks now use ALL relevant agents, not just one. Example: "auth feature" → security + backend + api + typescript + TDD
- **Intent-Based Detection** - Analyzes WHAT user wants, not just keyword matching
- **Full Chain Examples** - Complete examples showing 6-8 agents working together

**PRD Builder Improvements:**
- Added "The Job" one-liner section for clarity
- Added "Story Size: The #1 Rule" section (stories must fit one context window)
- Added validation checklist before saving prd.json
- Added lettered options format for clarifying questions (A, B, C, D)

### Changed

**Core Skills Made Mandatory:**
- `test-driven-development` - Now MANDATORY for ALL code changes. Activates automatically when writing code. User does NOT need to ask for tests.
- `systematic-debugging` - Now MANDATORY for ANY bug/problem. Activates automatically when fixing issues.
- `brainstorming` - Now MANDATORY before ANY new feature. Activates automatically for new functionality.

**Orchestrator Completely Rewritten:**
- Removed keyword-only matching (was too narrow)
- Added "Task Type Detection" table
- Added "Domain Detection" table (which agents to include for each domain)
- Added "Agent Chains by Task Type" with full chains for features, UI, API, bugs, performance
- Added "Short Prompt Handling" with smart inference examples
- New "Final Rules" section emphasizing: mandatory skills, multi-agent chains, intent over keywords

**Skills Now Explicitly Invoke Agents:**
- `test-driven-development` - Added "INVOKE Agents During TDD (MANDATORY)" with domain-to-agent mapping
- `systematic-debugging` - Added "INVOKE Agents During Debugging (MANDATORY)" with issue-to-agent mapping
- `brainstorming` - Added "INVOKE Relevant Agents (MANDATORY)" with feature-to-agent mapping
- `task-analysis` - Replaced agent recommendations with explicit Task tool invocation instructions
- `feature-planning` - Added "INVOKE Agents (MANDATORY)" section with examples
- Skills no longer just mention agents - they provide explicit instructions to INVOKE them via Task tool

### Fixed
- Skills no longer require specific keywords to activate
- Multi-agent responses now happen automatically (was only using one agent before)
- TDD no longer optional - always on for implementation

### Credits
- **snarktank/amp-skills** - Inspiration for skill design, frontend-design, and compound-engineering methodology

---

## [1.2.0] - 2026-01-09

### Added

**Ralph Mode v2.0 - 7-Phase Explicit Workflow**
- Complete rewrite of `prompt.md` template with 7 mandatory phases
- Phase 5: COMMIT (MANDATORY) ensures every story results in a git commit
- Branch verification in Phase 1 (Context Loading)
- AGENTS.md integration for codebase-specific guidance
- Structured progress.txt entries with commit hash and file changes
- 2-second sleep between iterations to prevent API rate issues

**New/Updated Files:**
- `scripts/ralph/templates/prompt.md` - 7-phase autonomous execution workflow
- `scripts/ralph/templates/AGENTS.md` - Enhanced codebase guidance template
- `scripts/ralph/templates/progress.txt` - Structured entry format with Status, Commit, Files Changed
- `scripts/ralph/ralph-loop.sh` - Added 2-second sleep, version 1.2.0

### Changed
- Updated `commands/ralph/ralph-init.md` - Copies AGENTS.md during initialization
- Updated `commands/ralph/ralph-start.md` - Added Commit Expectations section, 7-phase workflow documentation
- Updated `skills/ralph-mode/SKILL.md` - 7-phase workflow overview, emphasized commit requirement
- Updated `README.md` references to v1.2.0

### Fixed
- **Critical:** Ralph now commits after each story (was not committing before)
- Explicit step-by-step commit instructions in prompt.md
- Commit format enforced: `feat(ralph): [STORY_ID] - [Title]`

### Credits
- **snarktank/ralph** - Reference for explicit workflow structure

---

## [1.1.0] - 2026-01-09

### Added

**Safety Net - Command Protection System**
- PreToolUse hook intercepts all Bash commands before execution
- Blocks dangerous git operations: `reset --hard`, `push --force`, `clean -f`, `branch -D`, `stash drop/clear`
- Blocks dangerous file operations: `rm -rf /`, `rm -rf ~`, `rm -rf .`, system paths
- Blocks system dangers: `eval`, `exec`, `curl | bash`, `chmod 777/000`, `mkfs`, fork bombs
- Allows safe operations: relative paths, `/tmp/*`, `--force-with-lease`, `--dry-run`
- User-customizable via `.safety-net.json` configuration
- Audit logging to `.safety-net.log`
- Environment variables: `SAFETY_NET_ENABLED`, `SAFETY_NET_STRICT`, `SAFETY_NET_PARANOID`

**New Files:**
- `hooks/safety-net.sh` - Main orchestrator
- `hooks/lib/utils.sh` - JSON parsing, logging utilities
- `hooks/lib/rules-git.sh` - Git safety rules
- `hooks/lib/rules-rm.sh` - File deletion rules
- `hooks/lib/rules-system.sh` - System command rules
- `hooks/lib/rules-custom.sh` - Custom rules loader
- `templates/safety-net.json` - Configuration template

### Changed
- Updated `ralph-init.md` to create `.safety-net.json` during initialization
- Updated `ralph-start.md` with safety net documentation
- Updated `README.md` with Safety Net section
- Updated `hooks/hooks.json` to register PreToolUse hook

### Credits
- **kenryu42** - Inspiration from [claude-code-safety-net](https://github.com/kenryu42/claude-code-safety-net)

---

## [1.0.0] - 2026-01-09

### Initial Release

Professional Claude Code plugin with autonomous development capabilities and specialized AI agents.

#### Features

**Commands (19 Total)**
- Development: `/new-task`, `/code-explain`, `/code-optimize`, `/code-cleanup`, `/feature-plan`, `/lint`, `/docs-generate`
- API: `/api-new`, `/api-backend-setup`, `/api-test`, `/api-protect`
- UI: `/component-new`, `/page-new`, `/page-new-react`
- Supabase: `/types-gen`, `/edge-function-new`
- Ralph: `/ralph-init`, `/ralph-build`, `/ralph-start`, `/ralph-status`, `/ralph-stop`

**Agents (15 Specialists)**
- Architecture: `tech-stack-researcher`, `system-architect`, `backend-architect`, `frontend-architect`, `api-designer`, `requirements-analyst`
- Quality: `code-reviewer`, `typescript-pro`, `accessibility-specialist`, `refactoring-expert`, `performance-engineer`, `security-engineer`
- Documentation: `technical-writer`, `learning-guide`, `deep-research-agent`

**Skills (11 Workflows)**
- `test-driven-development` - RED-GREEN-REFACTOR cycle
- `systematic-debugging` - 4-phase root cause analysis
- `ralph-mode` - Autonomous loop execution
- `prd-builder` - Interactive PRD generation
- `brainstorming` - Creative exploration
- `writing-plans` - Implementation planning
- `executing-plans` - Plan execution
- `requesting-code-review` - Code review workflow
- `task-analysis` - Complexity analysis
- `feature-planning` - Feature specification
- `api-testing` - API endpoint testing
- `using-mannay` - Meta-skill for discovery

**Ralph Mode - Autonomous Development**
- External wrapper script for reliable autonomous execution
- Circuit breaker pattern prevents infinite loops
- Multi-layered completion detection
- Rate limiting with hourly reset
- PRD-based execution with user story tracking

**MCP Servers (3)**
- context7 - Up-to-date library documentation
- playwright - Browser automation
- supabase - Database operations

#### Credits

- **Geoffrey Huntley** - Ralph Wiggum autonomous loop technique
- **Michael Nygard** - Circuit Breaker pattern
- **Mannay** - Plugin development
