/**
 * Phase 3 Integration Tests
 * Tests the semantic learning system: extraction, storage, and recall
 */

import { test, describe, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert';
import { mkdtempSync, rmSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

// Import modules under test
import {
  extractKeywords,
  categorizeLearning,
  calculateImportance,
  extractLearningsFromState,
  deduplicateLearnings
} from '../learning/index.js';
import { initDatabase } from '../store/init.js';
import {
  saveLearning,
  searchLearnings,
  getRecentLearnings,
  getLearningCount,
  closeDatabase
} from '../store/sqlite.js';

describe('Phase 3: Semantic Learning System', () => {
  let testDir;
  let dbPath;

  beforeEach(() => {
    testDir = mkdtempSync(join(tmpdir(), 'memory-test-'));
    dbPath = join(testDir, 'memory.db');
  });

  afterEach(() => {
    try {
      closeDatabase();
    } catch (e) {}
    rmSync(testDir, { recursive: true, force: true });
  });

  describe('Keyword Extraction', () => {
    test('extracts meaningful keywords', () => {
      const text = 'We implemented the authentication module using JWT tokens';
      const keywords = extractKeywords(text);

      assert.ok(keywords.includes('authentication'), 'Should extract authentication');
      assert.ok(keywords.includes('jwt'), 'Should extract jwt');
      assert.ok(keywords.includes('tokens'), 'Should extract tokens');
    });

    test('filters stopwords', () => {
      const text = 'The quick brown fox jumps over the lazy dog';
      const keywords = extractKeywords(text);

      assert.ok(!keywords.includes('the'), 'Should filter "the"');
      assert.ok(!keywords.includes('over'), 'Should filter "over"');
      assert.ok(keywords.includes('quick'), 'Should keep "quick"');
      assert.ok(keywords.includes('brown'), 'Should keep "brown"');
    });

    test('limits keyword count', () => {
      const text = 'one two three four five six seven eight nine ten eleven twelve';
      const keywords = extractKeywords(text, 5);

      assert.strictEqual(keywords.length, 5, 'Should limit to 5 keywords');
    });

    test('handles empty input', () => {
      assert.deepStrictEqual(extractKeywords(''), []);
      assert.deepStrictEqual(extractKeywords(null), []);
    });
  });

  describe('Learning Categorization', () => {
    test('categorizes patterns', () => {
      assert.strictEqual(categorizeLearning('Used the singleton pattern'), 'pattern');
      assert.strictEqual(categorizeLearning('Implemented observer approach'), 'pattern');
    });

    test('categorizes architecture', () => {
      assert.strictEqual(categorizeLearning('Structured the app with MVC'), 'architecture');
      assert.strictEqual(categorizeLearning('Organized code into modules'), 'architecture');
    });

    test('categorizes decisions', () => {
      assert.strictEqual(categorizeLearning('Decided to use TypeScript'), 'decision');
      assert.strictEqual(categorizeLearning('Chose React over Vue'), 'decision');
    });

    test('categorizes fixes', () => {
      assert.strictEqual(categorizeLearning('Fixed the memory leak'), 'fix');
      assert.strictEqual(categorizeLearning('Resolved the race condition'), 'fix');
    });

    test('categorizes tips', () => {
      assert.strictEqual(categorizeLearning('Remember to close connections'), 'tip');
      assert.strictEqual(categorizeLearning('Always validate input'), 'tip');
    });

    test('defaults to general', () => {
      assert.strictEqual(categorizeLearning('Something happened'), 'general');
    });
  });

  describe('Importance Calculation', () => {
    test('boosts always/never statements', () => {
      const high = calculateImportance({ content: 'Always validate user input' });
      const low = calculateImportance({ content: 'Used a function' });

      assert.ok(high > low, 'Always statements should score higher');
    });

    test('boosts security-related learnings', () => {
      const security = calculateImportance({ content: 'Security vulnerability found' });
      const normal = calculateImportance({ content: 'Added a button' });

      assert.ok(security > normal, 'Security learnings should score higher');
    });

    test('caps at 10', () => {
      const maxed = calculateImportance({
        content: 'Always remember this critical security vulnerability because it\'s important'
      });

      assert.ok(maxed <= 10, 'Score should not exceed 10');
    });
  });

  describe('Learning Extraction from State', () => {
    test('extracts from decisions', () => {
      const state = {
        session_id: 'test-123',
        task: 'Implement auth',
        decisions: [
          'Decided to use JWT for authentication',
          'Chose bcrypt for password hashing'
        ]
      };

      const learnings = extractLearningsFromState(state);

      assert.strictEqual(learnings.length, 2, 'Should extract 2 learnings');
      assert.ok(learnings[0].content.includes('JWT'), 'Should include JWT decision');
    });

    test('skips git commit messages', () => {
      const state = {
        session_id: 'test-123',
        decisions: [
          'Committed: feat: add login page',
          'Used React hooks'
        ]
      };

      const learnings = extractLearningsFromState(state);

      assert.strictEqual(learnings.length, 1, 'Should skip commit message');
      assert.ok(learnings[0].content.includes('hooks'), 'Should keep non-commit decision');
    });

    test('extracts from blockers', () => {
      const state = {
        session_id: 'test-123',
        blockers: ['Missing API key', 'Database connection failed']
      };

      const learnings = extractLearningsFromState(state);

      assert.strictEqual(learnings.length, 2, 'Should extract blocker learnings');
      assert.ok(learnings[0].content.includes('blocker'), 'Should mark as blocker');
    });

    test('includes task context', () => {
      const state = {
        session_id: 'test-123',
        task: 'Build authentication',
        decisions: ['Used OAuth']
      };

      const learnings = extractLearningsFromState(state);

      assert.strictEqual(learnings[0].source_task, 'Build authentication');
      assert.strictEqual(learnings[0].source_session, 'test-123');
    });
  });

  describe('Deduplication', () => {
    test('removes exact duplicates', () => {
      const learnings = [
        { content: 'Use TypeScript' },
        { content: 'Use TypeScript' },
        { content: 'Use React' }
      ];

      const unique = deduplicateLearnings(learnings);

      assert.strictEqual(unique.length, 2, 'Should remove duplicate');
    });

    test('case insensitive matching', () => {
      const learnings = [
        { content: 'Use TypeScript' },
        { content: 'use typescript' }
      ];

      const unique = deduplicateLearnings(learnings);

      assert.strictEqual(unique.length, 1, 'Should match case-insensitive');
    });

    test('skips existing learnings', () => {
      const learnings = [
        { content: 'New learning' },
        { content: 'Already known' }
      ];
      const existing = [{ content: 'Already known' }];

      const unique = deduplicateLearnings(learnings, existing);

      assert.strictEqual(unique.length, 1, 'Should skip existing');
      assert.strictEqual(unique[0].content, 'New learning');
    });
  });

  describe('Learning Storage and Recall', () => {
    test('saves and retrieves learnings', () => {
      initDatabase(dbPath);

      saveLearning(dbPath, {
        content: 'Always use strict mode in TypeScript',
        tags: 'typescript,strict,best-practice',
        source_task: 'Setup project',
        source_session: 'session-1'
      });

      const count = getLearningCount(dbPath);
      assert.strictEqual(count, 1, 'Should have 1 learning');

      const recent = getRecentLearnings(dbPath, 10);
      assert.strictEqual(recent.length, 1);
      assert.ok(recent[0].content.includes('strict mode'));
    });

    test('FTS search finds learnings', () => {
      initDatabase(dbPath);

      saveLearning(dbPath, {
        content: 'Use TypeScript strict mode for better type safety',
        tags: 'typescript,types',
        source_task: '',
        source_session: ''
      });

      saveLearning(dbPath, {
        content: 'React hooks simplify state management',
        tags: 'react,hooks',
        source_task: '',
        source_session: ''
      });

      saveLearning(dbPath, {
        content: 'Always validate API input',
        tags: 'api,validation',
        source_task: '',
        source_session: ''
      });

      const tsResults = searchLearnings(dbPath, 'TypeScript', 10);
      assert.ok(tsResults.length >= 1, 'Should find TypeScript learning');
      assert.ok(tsResults[0].content.includes('TypeScript'));

      const reactResults = searchLearnings(dbPath, 'React hooks', 10);
      assert.ok(reactResults.length >= 1, 'Should find React learning');
    });

    test('updates recall count on search', () => {
      initDatabase(dbPath);

      saveLearning(dbPath, {
        content: 'Important TypeScript tip',
        tags: 'typescript',
        source_task: '',
        source_session: ''
      });

      // Search twice
      searchLearnings(dbPath, 'TypeScript', 10);
      searchLearnings(dbPath, 'TypeScript', 10);

      const recent = getRecentLearnings(dbPath, 10);
      assert.ok(recent[0].recall_count >= 2, 'Recall count should be updated');
    });
  });

  describe('End-to-End Learning Flow', () => {
    test('complete extraction and storage flow', () => {
      initDatabase(dbPath);

      // Simulate session state
      const state = {
        session_id: 'e2e-test',
        task: 'Build authentication system',
        decisions: [
          'Decided to use JWT for stateless auth',
          'Chose bcrypt with 12 rounds for hashing'
        ],
        files_modified: ['/auth.ts', '/login.ts', '/middleware.ts', '/types.ts'],
        blockers: []
      };

      // Extract learnings
      const extracted = extractLearningsFromState(state);
      assert.ok(extracted.length > 0, 'Should extract learnings');

      // Save to database
      for (const learning of extracted) {
        saveLearning(dbPath, {
          content: learning.content,
          tags: learning.tags,
          source_task: learning.source_task,
          source_session: learning.source_session
        });
      }

      // Verify storage
      const count = getLearningCount(dbPath);
      assert.ok(count > 0, 'Should have saved learnings');

      // Verify recall
      const recalled = searchLearnings(dbPath, 'JWT authentication', 10);
      assert.ok(recalled.length > 0, 'Should recall JWT learning');
    });
  });
});

// Run tests
console.log('Running Phase 3 tests...\n');
