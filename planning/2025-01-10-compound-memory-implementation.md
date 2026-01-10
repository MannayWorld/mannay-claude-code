# Compound Memory System - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use mannay:executing-plans to implement this plan task-by-task.

**Goal:** Implement automatic session continuity, 90%+ token savings, and cross-session learning with zero user setup.

**Architecture:** Shell script hooks as entry points calling Node.js modules for heavy lifting (Tree-sitter, SQLite, LanceDB). Data stored in project's `.claude/memory/` directory.

**Tech Stack:**
- Node.js (Tree-sitter, better-sqlite3, vectordb/lancedb)
- Shell scripts (hook entry points)
- SQLite (handoffs, signatures, state)
- LanceDB (vector search for learnings)

**Framework:** Claude Code Plugin (shell + Node.js)

**Quantified Standards:**
- Performance: less than 100ms hook execution, less than 500ms signature extraction
- Testing: Shell script tests using bats-core or basic assertions
- Token savings: at least 80% on cached file reads
- Reliability: Graceful fallback if Node.js modules fail

---

## Phase 1: Continuity (Handoffs and State)

### Task 1.1: Create Memory Directory Structure

**Files:**
- Create: `memory/package.json`
- Create: `memory/store/init.js`
- Create: `memory/store/sqlite.js`

**Step 1: Create memory module package.json**

Create file `memory/package.json` with Node.js dependencies for better-sqlite3 and optional tree-sitter packages.

**Step 2: Create SQLite initialization script**

Create file `memory/store/init.js` that:
- Initializes SQLite database with WAL mode
- Creates handoffs table for session continuity
- Creates file_signatures table for token savings cache
- Creates learnings table with FTS5 for semantic search

**Step 3: Create SQLite helper module**

Create file `memory/store/sqlite.js` with functions:
- saveHandoff, getLatestHandoff, markHandoffResumed
- getSignature, saveSignature, deleteSignature
- saveLearning, searchLearnings, getRecentLearnings

**Step 4: Test and commit**

Run: `cd memory && npm install && node store/init.js`

```bash
git add memory/
git commit -m "feat(memory): add SQLite store with handoffs, signatures, and learnings tables"
```

---

### Task 1.2: Create Session State Tracker

**Files:**
- Create: `memory/state/session-state.js`
- Create: `memory/state/index.js`

**Step 1: Create session state manager**

Create SessionState class with methods:
- load/save state to JSON file
- startSession, updateTask, addDecision
- addFileModified, addFileRead
- updateTodos, setLastAction, addBlocker
- getState, getSummary, clear

**Step 2: Commit**

```bash
git add memory/state/
git commit -m "feat(memory): add session state tracking module"
```

---

### Task 1.3: Create PreCompact Hook

**Files:**
- Create: `memory/hooks/pre-compact.js`
- Create: `hooks/pre-compact.sh`
- Modify: `hooks/hooks.json`

**Step 1: Create Node.js PreCompact handler**

Handler that:
- Reads current session state
- Saves handoff to SQLite with trigger type
- Returns JSON status

**Step 2: Create shell wrapper**

Shell script that checks for Node.js and runs the handler.

**Step 3: Update hooks.json**

Add PreCompact hook with matcher "auto|manual".

**Step 4: Commit**

```bash
chmod +x hooks/pre-compact.sh
git add memory/hooks/ hooks/pre-compact.sh hooks/hooks.json
git commit -m "feat(memory): add PreCompact hook for automatic handoff saving"
```

---

### Task 1.4: Update SessionStart Hook for Handoff Restore

**Files:**
- Create: `memory/hooks/session-start.js`
- Modify: `hooks/session-start.sh`

**Step 1: Create Node.js SessionStart handler**

Handler that:
- On compact matcher: loads and restores latest handoff
- Injects context with task, progress, decisions, todos
- Marks handoff as resumed
- Tries to recall relevant learnings

**Step 2: Update session-start.sh**

Combine existing using-mannay injection with memory context.

**Step 3: Commit**

```bash
git add memory/hooks/session-start.js hooks/session-start.sh
git commit -m "feat(memory): add SessionStart memory restoration for seamless continuity"
```

---

### Task 1.5: Create PostToolUse State Tracker

**Files:**
- Create: `memory/hooks/post-tool-track.js`
- Create: `hooks/post-tool-track.sh`
- Modify: `hooks/hooks.json`

**Step 1: Create Node.js PostToolUse tracker**

Handler that tracks:
- Write/Edit: adds to files_modified, invalidates signature cache
- Read: adds to files_read
- TodoWrite: updates todos
- Bash git commit: extracts commit message as decision

**Step 2: Create shell wrapper and update hooks.json**

Add PostToolUse hook with matcher "Write|Edit|Read|TodoWrite|Bash".

**Step 3: Commit**

```bash
chmod +x hooks/post-tool-track.sh
git add memory/hooks/post-tool-track.js hooks/post-tool-track.sh hooks/hooks.json
git commit -m "feat(memory): add PostToolUse state tracking for session continuity"
```

---

### Task 1.6: Install Dependencies and Test Phase 1

**Step 1: Install dependencies**

```bash
cd memory && npm install
```

**Step 2: Test database initialization**

```bash
node memory/store/init.js
```

**Step 3: Manual end-to-end test**

Verify handoff save on compact, restore on session start.

**Step 4: Commit Phase 1 complete**

```bash
git commit -m "feat(memory): complete Phase 1 - session continuity system"
```

---

## Phase 2: Token Optimization (Parser)

### Task 2.1: Create Tree-sitter Parser Module

**Files:**
- Create: `memory/parser/extract-signatures.js`
- Create: `memory/parser/languages.js`
- Create: `memory/parser/index.js`

**Step 1: Create language configuration**

Define supported languages (TypeScript, JavaScript, Python) with:
- File extensions
- Parser package name
- Tree-sitter queries for signatures

**Step 2: Create signature extractor**

Function that:
- Parses file with Tree-sitter
- Extracts function/class/interface signatures
- Returns signature text, hash, token counts, savings percentage

**Step 3: Test and commit**

```bash
node memory/parser/extract-signatures.js some/file.ts
git add memory/parser/
git commit -m "feat(memory): add Tree-sitter signature extraction for token savings"
```

---

### Task 2.2: Create PreToolUse Read Hook

**Files:**
- Create: `memory/hooks/pre-read.js`
- Create: `hooks/pre-read.sh`
- Modify: `hooks/hooks.json`

**Step 1: Create Node.js PreRead handler**

Handler that:
- Checks if file is large (more than 100 lines)
- Looks up signature cache
- On cache hit: blocks with signature
- On cache miss: extracts, caches, blocks with signature
- Small files: allows read

**Step 2: Create shell wrapper and update hooks.json**

Add PreToolUse(Read) hook.

**Step 3: Commit**

```bash
chmod +x hooks/pre-read.sh
git add memory/hooks/pre-read.js hooks/pre-read.sh hooks/hooks.json
git commit -m "feat(memory): add PreRead hook for signature caching and token savings"
```

---

### Task 2.3: Test Phase 2

**Step 1: Install Tree-sitter**

```bash
cd memory && npm install tree-sitter tree-sitter-typescript tree-sitter-python
```

**Step 2: Test signature extraction and caching**

**Step 3: Commit Phase 2 complete**

```bash
git commit -m "feat(memory): complete Phase 2 - token optimization with signature caching"
```

---

## Phase 3: Semantic Learning

### Task 3.1: Create Learning Extraction Module

**Files:**
- Create: `memory/learning/extract.js`
- Create: `memory/learning/index.js`

**Step 1: Create learning extractor**

Functions:
- extractKeywords: simple keyword extraction from text
- extractLearningsFromState: extracts decisions as learnings
- saveLearnings: saves to database

**Step 2: Commit**

```bash
git add memory/learning/
git commit -m "feat(memory): add learning extraction module"
```

---

### Task 3.2: Create SessionEnd Hook

**Files:**
- Create: `memory/hooks/session-end.js`
- Create: `hooks/session-end.sh`
- Modify: `hooks/hooks.json`

**Step 1: Create Node.js SessionEnd handler**

Handler that:
- Extracts learnings from session state
- Saves to database with tags
- Clears session state for next session

**Step 2: Create shell wrapper and update hooks.json**

**Step 3: Commit**

```bash
chmod +x hooks/session-end.sh
git add memory/hooks/session-end.js hooks/session-end.sh hooks/hooks.json
git commit -m "feat(memory): add SessionEnd hook for learning extraction"
```

---

### Task 3.3: Add Memory Search to SessionStart

**Files:**
- Modify: `memory/hooks/session-start.js`

**Step 1: Add FTS search for relevant learnings based on task**

**Step 2: Commit**

```bash
git add memory/hooks/session-start.js
git commit -m "feat(memory): add semantic learning recall to SessionStart"
```

---

### Task 3.4: Test Phase 3

Test learning extraction and recall.

```bash
git commit -m "feat(memory): complete Phase 3 - semantic learning system"
```

---

## Phase 4: Polish and Documentation

### Task 4.1: Add Memory CLI Commands

**Files:**
- Create: `commands/memory-status.md`
- Create: `commands/memory-learnings.md`

### Task 4.2: Add Error Handling

Wrap all handlers in try-catch with graceful fallback.

### Task 4.3: Update Documentation

Add Memory System section to README.

### Task 4.4: Final Testing and Merge

```bash
git checkout main
git merge feature/compound-memory
git push origin main
```

---

## Summary

**Total Tasks:** 16 across 4 phases
**Estimated Time:** 7-10 days

**Key Deliverables:**
1. Automatic handoff before compaction
2. Automatic restore after compaction
3. Token savings via signature caching
4. Cross-session learning recall
5. Zero user setup required
