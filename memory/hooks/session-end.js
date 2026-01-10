/**
 * SessionEnd Hook Handler
 * Extracts learnings from session and clears state
 */

import { join } from 'path';
import { existsSync } from 'fs';
import { fileURLToPath } from 'url';

import { getDatabase, saveLearning, getRecentLearnings } from '../store/index.js';
import { getCurrentSession, clearSessionCache } from '../state/index.js';
import {
  extractLearningsFromState,
  deduplicateLearnings,
  formatForStorage
} from '../learning/index.js';

export async function handleSessionEnd(input) {
  try {
    const projectRoot = process.env.CLAUDE_PROJECT_ROOT || process.cwd();
    const memoryDir = join(projectRoot, '.claude', 'memory');
    const dbPath = join(memoryDir, 'memory.db');
    const statePath = join(memoryDir, 'session-state.json');

    // Check if database exists
    if (!existsSync(dbPath)) {
      return { status: 'skipped', message: 'No memory database' };
    }

    // Get current session state
    const session = getCurrentSession(statePath);
    const state = session.getState();

    // Skip if no meaningful activity
    if (!state.session_id || state.action_count < 3) {
      clearSessionCache();
      session.clear();
      return { status: 'skipped', message: 'No meaningful session activity' };
    }

    // Initialize database
    getDatabase(dbPath);

    // Extract learnings from session
    const extracted = extractLearningsFromState(state);

    if (extracted.length === 0) {
      clearSessionCache();
      session.clear();
      return { status: 'skipped', message: 'No learnings to extract' };
    }

    // Get existing learnings to avoid duplicates
    const existing = getRecentLearnings(dbPath, 50);

    // Deduplicate
    const unique = deduplicateLearnings(extracted, existing);

    if (unique.length === 0) {
      clearSessionCache();
      session.clear();
      return { status: 'skipped', message: 'All learnings already recorded' };
    }

    // Save new learnings
    const formatted = formatForStorage(unique);
    let saved = 0;

    for (const learning of formatted) {
      try {
        saveLearning(dbPath, learning);
        saved++;
      } catch (e) {
        // Skip individual failures
      }
    }

    // Clear session state for next session
    clearSessionCache();
    session.clear();

    return {
      status: 'ok',
      message: `Saved ${saved} learnings from session`,
      learnings_saved: saved,
      learnings_extracted: extracted.length,
      learnings_deduplicated: unique.length
    };
  } catch (error) {
    // Always try to clear session on error
    try {
      const projectRoot = process.env.CLAUDE_PROJECT_ROOT || process.cwd();
      const memoryDir = join(projectRoot, '.claude', 'memory');
      const statePath = join(memoryDir, 'session-state.json');
      const session = getCurrentSession(statePath);
      clearSessionCache();
      session.clear();
    } catch (e) {}

    return { status: 'error', message: error.message };
  }
}

// CLI entry point
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  let input = '';

  process.stdin.setEncoding('utf8');
  process.stdin.on('readable', () => {
    let chunk;
    while ((chunk = process.stdin.read()) !== null) {
      input += chunk;
    }
  });

  process.stdin.on('end', async () => {
    try {
      const parsed = input.trim() ? JSON.parse(input) : {};
      const result = await handleSessionEnd(parsed);
      console.log(JSON.stringify(result));
    } catch (e) {
      console.log(JSON.stringify({ status: 'error', message: e.message }));
    }
  });
}
