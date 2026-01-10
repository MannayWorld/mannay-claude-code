/**
 * Phase 1 Integration Tests
 * Tests the core continuity system: SQLite, session state, handoffs
 */

import { test, describe, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert';
import { mkdtempSync, rmSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

// Import modules under test
import { initDatabase } from '../store/init.js';
import {
  getDatabase,
  closeDatabase,
  saveHandoff,
  getLatestHandoff,
  markHandoffResumed,
  getSignature,
  saveSignature,
  deleteSignature,
  saveLearning,
  searchLearnings,
  getRecentLearnings
} from '../store/sqlite.js';
import { SessionState } from '../state/session-state.js';

describe('Phase 1: Core Continuity System', () => {
  let testDir;
  let dbPath;
  let statePath;

  beforeEach(() => {
    testDir = mkdtempSync(join(tmpdir(), 'memory-test-'));
    dbPath = join(testDir, 'memory.db');
    statePath = join(testDir, 'session-state.json');
  });

  afterEach(() => {
    try {
      closeDatabase();
    } catch (e) {}
    rmSync(testDir, { recursive: true, force: true });
  });

  describe('Database Initialization', () => {
    test('creates database with all tables', () => {
      const db = initDatabase(dbPath);
      assert.ok(existsSync(dbPath), 'Database file should exist');

      // Check tables exist
      const tables = db.prepare(`
        SELECT name FROM sqlite_master
        WHERE type='table'
        ORDER BY name
      `).all().map(t => t.name);

      assert.ok(tables.includes('handoffs'), 'handoffs table should exist');
      assert.ok(tables.includes('file_signatures'), 'file_signatures table should exist');
      assert.ok(tables.includes('learnings'), 'learnings table should exist');
      assert.ok(tables.includes('learnings_fts'), 'learnings_fts FTS table should exist');

      db.close();
    });

    test('uses WAL mode for concurrency', () => {
      const db = initDatabase(dbPath);
      const mode = db.pragma('journal_mode', { simple: true });
      assert.strictEqual(mode, 'wal', 'Should use WAL mode');
      db.close();
    });
  });

  describe('Session State', () => {
    test('creates and tracks session state', () => {
      const session = new SessionState(statePath);
      session.startSession();

      assert.ok(session.getState().session_id, 'Should have session ID');
      assert.ok(session.getState().started_at, 'Should have start time');
    });

    test('tracks file modifications', () => {
      const session = new SessionState(statePath);
      session.startSession();
      session.addFileModified('/path/to/file.ts');
      session.addFileModified('/path/to/other.ts');

      const state = session.getState();
      assert.strictEqual(state.files_modified.length, 2, 'Should track 2 files');
      assert.ok(state.files_modified.includes('/path/to/file.ts'));
    });

    test('tracks decisions', () => {
      const session = new SessionState(statePath);
      session.startSession();
      session.addDecision('Used SQLite for storage');
      session.addDecision('Implemented hook pattern');

      const state = session.getState();
      assert.strictEqual(state.decisions.length, 2, 'Should track 2 decisions');
    });

    test('persists state to disk', () => {
      const session1 = new SessionState(statePath);
      session1.startSession();
      session1.updateTask('Implement feature X');
      session1.addFileModified('/test.ts');

      // Load from disk
      const session2 = new SessionState(statePath);
      session2.load();
      const state = session2.getState();

      assert.strictEqual(state.task, 'Implement feature X');
      assert.ok(state.files_modified.includes('/test.ts'));
    });

    test('generates meaningful summary', () => {
      const session = new SessionState(statePath);
      session.startSession();
      session.updateTask('Build login system');
      session.addFileModified('/auth.ts');
      session.addDecision('Used JWT');

      const summary = session.getSummary();
      assert.ok(summary.includes('Build login system'), 'Summary should include task');
    });
  });

  describe('Handoffs', () => {
    test('saves and retrieves handoff', () => {
      initDatabase(dbPath);

      const handoff = {
        session_id: 'test-session-123',
        trigger: 'auto',
        task: 'Implement feature',
        status: 'in_progress',
        state: {
          files_modified: ['/a.ts', '/b.ts'],
          decisions: ['Used pattern X']
        },
        summary: 'Working on feature implementation'
      };

      saveHandoff(dbPath, handoff);
      const retrieved = getLatestHandoff(dbPath);

      assert.ok(retrieved, 'Should retrieve handoff');
      assert.strictEqual(retrieved.session_id, 'test-session-123');
      assert.strictEqual(retrieved.task, 'Implement feature');
      assert.deepStrictEqual(retrieved.state.files_modified, ['/a.ts', '/b.ts']);
    });

    test('marks handoff as resumed', () => {
      const db = initDatabase(dbPath);

      saveHandoff(dbPath, {
        session_id: 'resume-test',
        trigger: 'compact',
        task: 'Test task',
        status: 'in_progress',
        state: {},
        summary: 'Test'
      });

      const before = getLatestHandoff(dbPath);
      assert.strictEqual(before.resumed_at, null, 'Should not be resumed yet');

      markHandoffResumed(dbPath, 'resume-test');

      // After marking resumed, getLatestHandoff won't return it (by design)
      // So we query directly to verify resumed_at was set
      const after = db.prepare('SELECT * FROM handoffs WHERE session_id = ?').get('resume-test');
      assert.ok(after.resumed_at, 'Should have resumed_at timestamp');
    });
  });

  describe('File Signatures', () => {
    test('saves and retrieves signature', () => {
      initDatabase(dbPath);

      saveSignature(dbPath, {
        path: '/src/app.ts',
        language: 'typescript',
        signature: JSON.stringify({ exports: ['App', 'main'], functions: ['handleRequest'] }),
        hash: 'abc123hash',
        original_tokens: 500,
        signature_tokens: 50
      });

      const sig = getSignature(dbPath, '/src/app.ts');
      assert.ok(sig, 'Should retrieve signature');
      assert.strictEqual(sig.hash, 'abc123hash');
      const parsed = JSON.parse(sig.signature);
      assert.deepStrictEqual(parsed.exports, ['App', 'main']);
    });

    test('deletes signature on file change', () => {
      initDatabase(dbPath);

      saveSignature(dbPath, {
        path: '/src/test.ts',
        language: 'typescript',
        signature: JSON.stringify({ exports: [] }),
        hash: 'oldhash',
        original_tokens: 100,
        signature_tokens: 10
      });
      assert.ok(getSignature(dbPath, '/src/test.ts'), 'Signature should exist');

      deleteSignature(dbPath, '/src/test.ts');
      assert.strictEqual(getSignature(dbPath, '/src/test.ts'), undefined, 'Signature should be deleted');
    });
  });

  describe('Learnings', () => {
    test('saves and searches learnings', () => {
      initDatabase(dbPath);

      saveLearning(dbPath, {
        content: 'Always use TypeScript strict mode for better type safety',
        category: 'pattern',
        source_session: 'session-1',
        importance: 8
      });

      saveLearning(dbPath, {
        content: 'The database uses SQLite with WAL mode for concurrency',
        category: 'architecture',
        source_session: 'session-2',
        importance: 7
      });

      const results = searchLearnings(dbPath, 'TypeScript strict', 5);
      assert.ok(results.length > 0, 'Should find learnings');
      assert.ok(results[0].content.includes('TypeScript'), 'Should match search');
    });

    test('retrieves recent learnings', () => {
      initDatabase(dbPath);

      saveLearning(dbPath, {
        content: 'First learning',
        category: 'tip',
        source_session: 's1',
        importance: 5
      });

      saveLearning(dbPath, {
        content: 'Second learning',
        category: 'tip',
        source_session: 's2',
        importance: 5
      });

      const recent = getRecentLearnings(dbPath, 10);
      assert.strictEqual(recent.length, 2, 'Should have 2 learnings');
    });
  });

  describe('Hook Integration', () => {
    test('pre-compact handler saves state correctly', async () => {
      // Simulate what pre-compact.js does
      initDatabase(dbPath);
      const session = new SessionState(statePath);
      session.startSession();
      session.updateTask('Testing pre-compact');
      session.addFileModified('/test.ts');
      session.setLastAction('Modified test.ts');

      const state = session.getState();
      saveHandoff(dbPath, {
        session_id: state.session_id,
        trigger: 'auto',
        task: state.task,
        status: 'in_progress',
        state: state,
        summary: session.getSummary()
      });

      const handoff = getLatestHandoff(dbPath);
      assert.strictEqual(handoff.task, 'Testing pre-compact');
      assert.ok(handoff.state.files_modified.includes('/test.ts'));
    });
  });
});

// Run tests
console.log('Running Phase 1 tests...\n');
