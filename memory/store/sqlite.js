/**
 * SQLite Helper Module for Compound Memory System
 * Provides CRUD operations for handoffs, signatures, and learnings
 */

import { initDatabase } from './init.js';

let dbInstance = null;

export function getDatabase(dbPath) {
  if (!dbInstance) {
    dbInstance = initDatabase(dbPath);
  }
  return dbInstance;
}

export function closeDatabase() {
  if (dbInstance) {
    dbInstance.close();
    dbInstance = null;
  }
}

// ============ Handoff Operations ============

export function saveHandoff(dbPath, handoff) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    INSERT OR REPLACE INTO handoffs
    (session_id, trigger, task, status, state_json, summary)
    VALUES (?, ?, ?, ?, ?, ?)
  `);
  return stmt.run(
    handoff.session_id,
    handoff.trigger,
    handoff.task,
    handoff.status || 'in_progress',
    JSON.stringify(handoff.state),
    handoff.summary
  );
}

export function getLatestHandoff(dbPath) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    SELECT * FROM handoffs
    WHERE resumed_at IS NULL
    ORDER BY created_at DESC
    LIMIT 1
  `);
  const row = stmt.get();
  if (row && row.state_json) {
    try {
      row.state = JSON.parse(row.state_json);
    } catch (e) {
      row.state = {};
    }
  }
  return row;
}

export function markHandoffResumed(dbPath, sessionId) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    UPDATE handoffs
    SET resumed_at = datetime('now')
    WHERE session_id = ?
  `);
  return stmt.run(sessionId);
}

export function getHandoffCount(dbPath) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`SELECT COUNT(*) as count FROM handoffs`);
  return stmt.get().count;
}

// ============ Signature Cache Operations ============

export function getSignature(dbPath, filePath) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`SELECT * FROM file_signatures WHERE path = ?`);
  const row = stmt.get(filePath);
  if (row) {
    db.prepare(`UPDATE file_signatures SET accessed_at = datetime('now') WHERE path = ?`).run(filePath);
  }
  return row;
}

export function saveSignature(dbPath, signature) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    INSERT OR REPLACE INTO file_signatures
    (path, language, signature, hash, original_tokens, signature_tokens)
    VALUES (?, ?, ?, ?, ?, ?)
  `);
  return stmt.run(
    signature.path,
    signature.language,
    signature.signature,
    signature.hash,
    signature.original_tokens,
    signature.signature_tokens
  );
}

export function deleteSignature(dbPath, filePath) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`DELETE FROM file_signatures WHERE path = ?`);
  return stmt.run(filePath);
}

export function getSignatureCount(dbPath) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`SELECT COUNT(*) as count FROM file_signatures`);
  return stmt.get().count;
}

export function getSignatureStats(dbPath) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    SELECT
      COUNT(*) as count,
      SUM(original_tokens) as total_original,
      SUM(signature_tokens) as total_signature
    FROM file_signatures
  `);
  return stmt.get();
}

export function cleanOldSignatures(dbPath, daysOld = 30) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    DELETE FROM file_signatures
    WHERE accessed_at < datetime('now', '-' || ? || ' days')
  `);
  return stmt.run(daysOld);
}

// ============ Learning Operations ============

export function saveLearning(dbPath, learning) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    INSERT INTO learnings (content, tags, source_task, source_session)
    VALUES (?, ?, ?, ?)
  `);
  return stmt.run(
    learning.content,
    learning.tags || '',
    learning.source_task || '',
    learning.source_session || ''
  );
}

export function searchLearnings(dbPath, query, limit = 5) {
  const db = getDatabase(dbPath);
  try {
    const ftsQuery = query.split(/\s+/).map(w => w + '*').join(' OR ');
    const stmt = db.prepare(`
      SELECT l.*, learnings_fts.rank
      FROM learnings l
      JOIN learnings_fts ON l.id = learnings_fts.rowid
      WHERE learnings_fts MATCH ?
      ORDER BY learnings_fts.rank
      LIMIT ?
    `);
    const results = stmt.all(ftsQuery, limit);
    results.forEach(r => {
      db.prepare(`UPDATE learnings SET recall_count = recall_count + 1 WHERE id = ?`).run(r.id);
    });
    return results;
  } catch (e) {
    return [];
  }
}

export function getRecentLearnings(dbPath, limit = 10) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`
    SELECT * FROM learnings ORDER BY created_at DESC LIMIT ?
  `);
  return stmt.all(limit);
}

export function getLearningCount(dbPath) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`SELECT COUNT(*) as count FROM learnings`);
  return stmt.get().count;
}

export function deleteLearning(dbPath, id) {
  const db = getDatabase(dbPath);
  const stmt = db.prepare(`DELETE FROM learnings WHERE id = ?`);
  return stmt.run(id);
}
