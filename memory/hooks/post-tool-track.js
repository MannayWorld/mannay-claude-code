/**
 * PostToolUse Hook Handler
 * Tracks state changes for session continuity
 */

import { join } from 'path';
import { existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { getCurrentSession } from '../state/index.js';
import { deleteSignature, getDatabase } from '../store/index.js';

export async function handlePostToolUse(input) {
  try {
    const toolName = input?.tool_name || input?.toolName || '';
    const toolInput = input?.tool_input || input?.toolInput || {};
    const toolResult = input?.tool_result || input?.toolResult;

    const projectRoot = process.env.CLAUDE_PROJECT_ROOT || process.cwd();
    const memoryDir = join(projectRoot, '.claude', 'memory');
    const statePath = join(memoryDir, 'session-state.json');
    const dbPath = join(memoryDir, 'memory.db');

    const session = getCurrentSession(statePath);

    // Track based on tool type
    switch (toolName) {
      case 'Write':
      case 'Edit': {
        const modifiedPath = toolInput.file_path || toolInput.path || '';
        if (modifiedPath) {
          session.addFileModified(modifiedPath);
          session.setLastAction('Modified ' + modifiedPath.split('/').pop());
          // Invalidate signature cache
          if (existsSync(dbPath)) {
            try {
              getDatabase(dbPath);
              deleteSignature(dbPath, modifiedPath);
            } catch (e) {
              // DB might not be ready
            }
          }
        }
        break;
      }

      case 'Read': {
        const readPath = toolInput.file_path || toolInput.path || '';
        if (readPath) {
          session.addFileRead(readPath);
          session.setLastAction('Read ' + readPath.split('/').pop());
        }
        break;
      }

      case 'TodoWrite': {
        const todos = toolInput.todos || [];
        session.updateTodos(todos);
        session.setLastAction('Updated todos');
        break;
      }

      case 'Bash': {
        const command = toolInput.command || '';
        // Track git commits as decisions
        if (command.includes('git commit')) {
          const match = command.match(/-m\s+["']([^"']+)["']/);
          if (match && match[1]) {
            session.addDecision('Committed: ' + match[1].slice(0, 50));
          }
        }
        // Track npm/pnpm installs
        if (command.match(/npm\s+install|pnpm\s+(install|add)/)) {
          session.setLastAction('Installed dependencies');
        } else {
          const shortCmd = command.slice(0, 40).replace(/\s+/g, ' ');
          session.setLastAction('Ran: ' + shortCmd + (command.length > 40 ? '...' : ''));
        }
        break;
      }

      case 'Task': {
        const prompt = toolInput.prompt || '';
        session.setLastAction('Launched subagent');
        break;
      }

      default:
        if (toolName) {
          session.setLastAction('Used ' + toolName);
        }
    }

    return { status: 'ok' };
  } catch (error) {
    // Don't fail the hook on errors
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
      const result = await handlePostToolUse(parsed);
      console.log(JSON.stringify(result));
    } catch (e) {
      console.log(JSON.stringify({ status: 'error', message: e.message }));
    }
  });
}
