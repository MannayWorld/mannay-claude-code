/**
 * SessionStart Hook Handler for Memory Module
 * Restores handoff after compaction and recalls relevant learnings
 */

import { join } from 'path';
import { existsSync } from 'fs';
import { fileURLToPath } from 'url';
import {
  getLatestHandoff,
  markHandoffResumed,
  searchLearnings,
  getRecentLearnings,
  getDatabase
} from '../store/index.js';
import { getCurrentSession } from '../state/index.js';

function extractKeywords(text) {
  if (!text) return '';
  const stopWords = new Set(['the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should',
    'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from', 'as', 'and', 'or',
    'but', 'if', 'this', 'that', 'these', 'those', 'i', 'you', 'we', 'they', 'it']);

  return text.toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter(w => w.length > 2 && !stopWords.has(w))
    .slice(0, 10)
    .join(' ');
}

export async function handleSessionStart(input) {
  try {
    const matcher = input?.matcher || 'startup';
    const projectRoot = process.env.CLAUDE_PROJECT_ROOT || process.cwd();
    const memoryDir = join(projectRoot, '.claude', 'memory');
    const dbPath = join(memoryDir, 'memory.db');
    const statePath = join(memoryDir, 'session-state.json');

    // Check if database exists
    if (!existsSync(dbPath)) {
      return { context: null, message: 'No memory database found' };
    }

    // Initialize database connection
    getDatabase(dbPath);

    let context = '';
    let task = null;

    // Handle based on matcher
    if (matcher === 'compact') {
      // After compaction, restore handoff
      const handoff = getLatestHandoff(dbPath);

      if (handoff && !handoff.resumed_at) {
        const state = handoff.state || {};
        task = state.task;

        context = `## Resumed Session (Auto-restored after compaction)

**Task:** ${state.task || 'Unknown task'}
**Progress:** ${state.files_modified?.length || 0} files modified, ${state.decisions?.length || 0} decisions made

**Files Modified:**
${state.files_modified?.map(f => '- ' + f).join('\n') || '- None yet'}

**Key Decisions:**
${state.decisions?.map(d => '- ' + d).join('\n') || '- None yet'}

**Pending Todos:**
${state.todos?.filter(t => t.status === 'pending').map(t => '- [ ] ' + t.content).join('\n') || '- None'}

**Continue from:** ${state.last_action || 'Beginning'}

---
`;

        // Mark as resumed
        markHandoffResumed(dbPath, handoff.session_id);

        // Restore session state
        const session = getCurrentSession(statePath);
        session.restore(state);
      }
    }

    // For all session starts, try to recall relevant learnings
    try {
      let learnings = [];

      // If we have a task, search for relevant learnings
      if (task) {
        const keywords = extractKeywords(task);
        if (keywords) {
          learnings = searchLearnings(dbPath, keywords, 3);
        }
      }

      // If no task-specific learnings, get recent ones
      if (learnings.length === 0) {
        learnings = getRecentLearnings(dbPath, 3);
      }

      if (learnings.length > 0) {
        context += '\n## Relevant Learnings from Previous Sessions\n';
        learnings.forEach(l => {
          context += '- ' + l.content + '\n';
        });
      }
    } catch (e) {
      // FTS might not be set up yet, ignore
    }

    return {
      context: context.trim() || null,
      message: context ? 'Memory context loaded' : 'No memory context available'
    };
  } catch (error) {
    return {
      context: null,
      message: 'Memory error: ' + error.message
    };
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
      const result = await handleSessionStart(parsed);
      console.log(JSON.stringify(result));
    } catch (e) {
      console.log(JSON.stringify({ context: null, message: e.message }));
    }
  });
}
