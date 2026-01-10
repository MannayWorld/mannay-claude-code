/**
 * PreCompact Hook Handler
 * Saves session state as handoff before context compaction
 */

import { join } from 'path';
import { fileURLToPath } from 'url';
import { saveHandoff, getDatabase } from '../store/index.js';
import { getCurrentSession } from '../state/index.js';

export async function handlePreCompact(input) {
  try {
    const trigger = input?.matcher || 'auto';

    // Determine paths
    const projectRoot = process.env.CLAUDE_PROJECT_ROOT || process.cwd();
    const memoryDir = join(projectRoot, '.claude', 'memory');
    const dbPath = join(memoryDir, 'memory.db');
    const statePath = join(memoryDir, 'session-state.json');

    // Get current session state
    const session = getCurrentSession(statePath);
    const state = session.getState();

    // Only save if there's meaningful activity
    if (!state.session_id || state.action_count === 0) {
      return {
        status: 'skipped',
        message: 'No meaningful session state to save'
      };
    }

    // Initialize database if needed
    getDatabase(dbPath);

    // Save handoff
    const handoff = {
      session_id: state.session_id,
      trigger: trigger,
      task: state.task,
      status: state.status,
      state: state,
      summary: session.getSummary()
    };

    saveHandoff(dbPath, handoff);

    return {
      status: 'ok',
      message: `Handoff saved: ${handoff.summary}`
    };
  } catch (error) {
    return {
      status: 'error',
      message: error.message
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
      const result = await handlePreCompact(parsed);
      console.log(JSON.stringify(result));
    } catch (e) {
      console.log(JSON.stringify({ status: 'error', message: e.message }));
    }
  });
}
