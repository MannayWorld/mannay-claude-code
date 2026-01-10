/**
 * SQLite Database Initialization for Compound Memory System
 */

import Database from 'better-sqlite3';
import { existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

export function initDatabase(dbPath) {
  const dir = dirname(dbPath);
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }

  const db = new Database(dbPath);
  db.pragma('journal_mode = WAL');

  db.exec(`
    CREATE TABLE IF NOT EXISTS handoffs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT UNIQUE NOT NULL,
      created_at TEXT DEFAULT (datetime('now')),
      trigger TEXT NOT NULL,
      task TEXT,
      status TEXT DEFAULT 'in_progress',
      state_json TEXT NOT NULL,
      summary TEXT,
      resumed_at TEXT
    );

    CREATE INDEX IF NOT EXISTS idx_handoffs_created
    ON handoffs(created_at DESC);

    CREATE INDEX IF NOT EXISTS idx_handoffs_status
    ON handoffs(status) WHERE resumed_at IS NULL;

    CREATE TABLE IF NOT EXISTS file_signatures (
      path TEXT PRIMARY KEY,
      language TEXT NOT NULL,
      signature TEXT NOT NULL,
      hash TEXT NOT NULL,
      original_tokens INTEGER,
      signature_tokens INTEGER,
      created_at TEXT DEFAULT (datetime('now')),
      accessed_at TEXT DEFAULT (datetime('now'))
    );

    CREATE INDEX IF NOT EXISTS idx_signatures_accessed
    ON file_signatures(accessed_at DESC);

    CREATE TABLE IF NOT EXISTS learnings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT NOT NULL,
      tags TEXT,
      source_task TEXT,
      source_session TEXT,
      created_at TEXT DEFAULT (datetime('now')),
      recall_count INTEGER DEFAULT 0
    );

    CREATE VIRTUAL TABLE IF NOT EXISTS learnings_fts USING fts5(
      content,
      tags,
      content='learnings',
      content_rowid='id'
    );

    CREATE TRIGGER IF NOT EXISTS learnings_ai AFTER INSERT ON learnings BEGIN
      INSERT INTO learnings_fts(rowid, content, tags)
      VALUES (new.id, new.content, new.tags);
    END;

    CREATE TRIGGER IF NOT EXISTS learnings_ad AFTER DELETE ON learnings BEGIN
      INSERT INTO learnings_fts(learnings_fts, rowid, content, tags)
      VALUES ('delete', old.id, old.content, old.tags);
    END;

    CREATE TRIGGER IF NOT EXISTS learnings_au AFTER UPDATE ON learnings BEGIN
      INSERT INTO learnings_fts(learnings_fts, rowid, content, tags)
      VALUES ('delete', old.id, old.content, old.tags);
      INSERT INTO learnings_fts(rowid, content, tags)
      VALUES (new.id, new.content, new.tags);
    END;
  `);

  return db;
}

export function getDefaultDbPath(projectRoot) {
  return join(projectRoot, '.claude', 'memory', 'memory.db');
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const projectRoot = process.env.CLAUDE_PROJECT_ROOT || process.cwd();
  const dbPath = getDefaultDbPath(projectRoot);
  console.log('Initializing database at:', dbPath);
  try {
    const db = initDatabase(dbPath);
    console.log('Database initialized successfully');
    const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all();
    console.log('Tables created:', tables.map(t => t.name).join(', '));
    db.close();
  } catch (error) {
    console.error('Failed to initialize database:', error.message);
    process.exit(1);
  }
}
