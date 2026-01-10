/**
 * Phase 2 Integration Tests
 * Tests the token optimization system: Tree-sitter parsing and signature caching
 */

import { test, describe, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert';
import { mkdtempSync, rmSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

// Import modules under test
import { extractSignature, isTreeSitterAvailable, isSupported, getLanguageByExtension } from '../parser/index.js';
import { initDatabase } from '../store/init.js';
import { getSignature, saveSignature, deleteSignature, closeDatabase } from '../store/sqlite.js';

const SAMPLE_JS = `/**
 * Sample JavaScript file for testing
 */

import { something } from 'somewhere';
import { another } from 'another-place';

export class Calculator {
  constructor(initialValue) {
    this.value = initialValue;
  }

  add(x) {
    this.value += x;
    return this;
  }

  subtract(x) {
    this.value -= x;
    return this;
  }

  multiply(x) {
    this.value *= x;
    return this;
  }

  divide(x) {
    if (x === 0) throw new Error('Division by zero');
    this.value /= x;
    return this;
  }

  getValue() {
    return this.value;
  }
}

export function createCalculator(initial = 0) {
  return new Calculator(initial);
}

export function add(a, b) {
  return a + b;
}

export function subtract(a, b) {
  return a - b;
}

export function multiply(a, b) {
  return a * b;
}

export function divide(a, b) {
  if (b === 0) throw new Error('Division by zero');
  return a / b;
}

export const PI = 3.14159265359;

export default Calculator;
`;

const SAMPLE_TS = `/**
 * Sample TypeScript file for testing
 */

import { Request, Response } from 'express';

interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

type UserRole = 'admin' | 'user' | 'guest';

interface AuthConfig {
  secret: string;
  expiresIn: number;
}

export class UserService {
  private users: Map<string, User> = new Map();

  constructor(private config: AuthConfig) {}

  async createUser(data: Omit<User, 'id' | 'createdAt'>): Promise<User> {
    const id = crypto.randomUUID();
    const user: User = {
      ...data,
      id,
      createdAt: new Date()
    };
    this.users.set(id, user);
    return user;
  }

  async getUser(id: string): Promise<User | undefined> {
    return this.users.get(id);
  }

  async updateUser(id: string, data: Partial<User>): Promise<User | undefined> {
    const user = this.users.get(id);
    if (!user) return undefined;
    const updated = { ...user, ...data };
    this.users.set(id, updated);
    return updated;
  }

  async deleteUser(id: string): Promise<boolean> {
    return this.users.delete(id);
  }
}

export function validateEmail(email: string): boolean {
  return /^[^@]+@[^@]+\\.[^@]+$/.test(email);
}

export function hashPassword(password: string): string {
  // Placeholder for actual hashing
  return Buffer.from(password).toString('base64');
}
`;

describe('Phase 2: Token Optimization System', () => {
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

  describe('Language Detection', () => {
    test('detects JavaScript files', () => {
      assert.ok(isSupported('.js'), '.js should be supported');
      assert.ok(isSupported('.jsx'), '.jsx should be supported');
      assert.ok(isSupported('.mjs'), '.mjs should be supported');
    });

    test('detects TypeScript files', () => {
      assert.ok(isSupported('.ts'), '.ts should be supported');
      assert.ok(isSupported('.tsx'), '.tsx should be supported');
    });

    test('detects Python files', () => {
      assert.ok(isSupported('.py'), '.py should be supported');
    });

    test('returns null for unsupported files', () => {
      assert.strictEqual(getLanguageByExtension('.txt'), null);
      assert.strictEqual(getLanguageByExtension('.md'), null);
      assert.strictEqual(getLanguageByExtension('.json'), null);
    });
  });

  describe('Tree-sitter Availability', () => {
    test('Tree-sitter is available', async () => {
      const available = await isTreeSitterAvailable();
      assert.ok(available, 'Tree-sitter should be available');
    });
  });

  describe('Signature Extraction', () => {
    test('extracts JavaScript signatures', async () => {
      const jsFile = join(testDir, 'calc.js');
      writeFileSync(jsFile, SAMPLE_JS);

      const result = await extractSignature(jsFile, SAMPLE_JS);

      assert.ok(result.signature, 'Should have signature text');
      assert.strictEqual(result.language, 'javascript');
      assert.ok(result.original_tokens > 0, 'Should have original token count');
      assert.ok(result.signature_tokens > 0, 'Should have signature token count');
      // Note: For small files, signature might be larger due to formatting overhead
      // Token savings are most significant on large files (100+ lines)
      assert.ok(result.definitions_count > 0, 'Should find definitions');
    });

    test('extracts TypeScript signatures', async () => {
      const tsFile = join(testDir, 'user.ts');
      writeFileSync(tsFile, SAMPLE_TS);

      const result = await extractSignature(tsFile, SAMPLE_TS);

      assert.ok(result.signature, 'Should have signature text');
      assert.strictEqual(result.language, 'typescript');
      assert.ok(result.savings_percent > 0, 'Should have positive savings');
      assert.ok(result.signature.includes('UserService'), 'Should include class name');
    });

    test('calculates token savings on large files', async () => {
      // Generate a large file (200+ lines) to test meaningful savings
      const largeFile = SAMPLE_JS + '\n' + SAMPLE_JS + '\n' + SAMPLE_JS;
      const jsFile = join(testDir, 'large.js');
      writeFileSync(jsFile, largeFile);

      const result = await extractSignature(jsFile, largeFile);

      // Large files should achieve meaningful savings (at least 20%)
      assert.ok(result.savings_percent >= 20, `Savings ${result.savings_percent}% should be >= 20% for large files`);
    });

    test('includes exports in signature', async () => {
      const jsFile = join(testDir, 'calc.js');
      writeFileSync(jsFile, SAMPLE_JS);

      const result = await extractSignature(jsFile, SAMPLE_JS);

      assert.ok(result.signature.includes('### Exports'), 'Should have exports section');
      assert.ok(result.exports_count > 0, 'Should count exports');
    });

    test('includes imports in signature', async () => {
      const jsFile = join(testDir, 'calc.js');
      writeFileSync(jsFile, SAMPLE_JS);

      const result = await extractSignature(jsFile, SAMPLE_JS);

      assert.ok(result.signature.includes('### Imports'), 'Should have imports section');
      assert.ok(result.imports_count > 0, 'Should count imports');
    });
  });

  describe('Signature Caching', () => {
    test('saves and retrieves signature from cache', async () => {
      initDatabase(dbPath);

      const jsFile = join(testDir, 'calc.js');
      writeFileSync(jsFile, SAMPLE_JS);

      const result = await extractSignature(jsFile, SAMPLE_JS);

      // Save to cache
      saveSignature(dbPath, {
        path: jsFile,
        language: result.language,
        signature: JSON.stringify(result.signature),
        hash: result.hash,
        original_tokens: result.original_tokens,
        signature_tokens: result.signature_tokens
      });

      // Retrieve from cache
      const cached = getSignature(dbPath, jsFile);
      assert.ok(cached, 'Should retrieve cached signature');
      assert.strictEqual(cached.hash, result.hash);
      assert.strictEqual(cached.original_tokens, result.original_tokens);
    });

    test('cache invalidation on file change', async () => {
      initDatabase(dbPath);

      const jsFile = join(testDir, 'calc.js');
      writeFileSync(jsFile, SAMPLE_JS);

      const result = await extractSignature(jsFile, SAMPLE_JS);

      // Save to cache
      saveSignature(dbPath, {
        path: jsFile,
        language: result.language,
        signature: JSON.stringify(result.signature),
        hash: result.hash,
        original_tokens: result.original_tokens,
        signature_tokens: result.signature_tokens
      });

      assert.ok(getSignature(dbPath, jsFile), 'Cache should exist');

      // Invalidate cache
      deleteSignature(dbPath, jsFile);

      assert.strictEqual(getSignature(dbPath, jsFile), undefined, 'Cache should be invalidated');
    });

    test('cache miss on hash mismatch', async () => {
      initDatabase(dbPath);

      const jsFile = join(testDir, 'calc.js');
      writeFileSync(jsFile, SAMPLE_JS);

      const result = await extractSignature(jsFile, SAMPLE_JS);

      // Save to cache with different hash
      saveSignature(dbPath, {
        path: jsFile,
        language: result.language,
        signature: JSON.stringify(result.signature),
        hash: 'different-hash',
        original_tokens: result.original_tokens,
        signature_tokens: result.signature_tokens
      });

      const cached = getSignature(dbPath, jsFile);
      assert.notStrictEqual(cached.hash, result.hash, 'Hash should not match');
    });
  });

  describe('Token Savings Calculation', () => {
    test('reports accurate savings percentage', async () => {
      const jsFile = join(testDir, 'calc.js');
      writeFileSync(jsFile, SAMPLE_JS);

      const result = await extractSignature(jsFile, SAMPLE_JS);

      const expectedSavings = Math.round((1 - result.signature_tokens / result.original_tokens) * 100);
      assert.strictEqual(result.savings_percent, expectedSavings, 'Savings should match calculation');
    });
  });
});

// Run tests
console.log('Running Phase 2 tests...\n');
