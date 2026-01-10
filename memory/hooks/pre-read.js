/**
 * PreToolUse(Read) Hook Handler
 * Intercepts file reads and returns signatures for large files
 */

import { join, extname } from 'path';
import { existsSync, readFileSync, statSync } from 'fs';
import { fileURLToPath } from 'url';
import { createHash } from 'crypto';

import { getDatabase, getSignature, saveSignature } from '../store/index.js';
import { extractSignature, isSupported, isTreeSitterAvailable } from '../parser/index.js';

const MIN_LINES_FOR_SIGNATURE = 100;
const SUPPORTED_EXTENSIONS = ['.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs', '.py'];

function hashContent(content) {
  return createHash('sha256').update(content).digest('hex').slice(0, 16);
}

function countLines(content) {
  return content.split('\n').length;
}

export async function handlePreRead(input) {
  try {
    const filePath = input?.tool_input?.file_path || input?.tool_input?.path;
    if (!filePath) {
      return { decision: 'allow' };
    }

    const ext = extname(filePath);

    // Only process supported file types
    if (!SUPPORTED_EXTENSIONS.includes(ext)) {
      return { decision: 'allow' };
    }

    // Check if Tree-sitter is available
    const treeSitterAvailable = await isTreeSitterAvailable();
    if (!treeSitterAvailable) {
      return { decision: 'allow' };
    }

    // Check if file exists
    if (!existsSync(filePath)) {
      return { decision: 'allow' };
    }

    // Read file content
    const content = readFileSync(filePath, 'utf-8');
    const lineCount = countLines(content);

    // Only use signatures for large files
    if (lineCount < MIN_LINES_FOR_SIGNATURE) {
      return { decision: 'allow' };
    }

    // Get database path
    const projectRoot = process.env.CLAUDE_PROJECT_ROOT || process.cwd();
    const dbPath = join(projectRoot, '.claude', 'memory', 'memory.db');

    // Check if database exists
    if (!existsSync(dbPath)) {
      return { decision: 'allow' };
    }

    // Initialize database
    getDatabase(dbPath);

    // Check cache
    const currentHash = hashContent(content);
    const cached = getSignature(dbPath, filePath);

    if (cached && cached.hash === currentHash) {
      // Cache hit - return signature instead of full file
      return {
        decision: 'block',
        reason: 'signature_cache_hit',
        message: `📝 Using cached signature for ${filePath.split('/').pop()} (${cached.signature_tokens} tokens saved from ${cached.original_tokens})`,
        output: {
          type: 'signature',
          content: JSON.parse(cached.signature),
          original_tokens: cached.original_tokens,
          signature_tokens: cached.signature_tokens,
          savings_percent: Math.round((1 - cached.signature_tokens / cached.original_tokens) * 100)
        }
      };
    }

    // Cache miss - extract and cache
    try {
      const result = await extractSignature(filePath, content);

      // Save to cache
      saveSignature(dbPath, {
        path: filePath,
        language: result.language,
        signature: JSON.stringify(result.signature),
        hash: result.hash,
        original_tokens: result.original_tokens,
        signature_tokens: result.signature_tokens
      });

      return {
        decision: 'block',
        reason: 'signature_extracted',
        message: `📝 Extracted signature for ${filePath.split('/').pop()} (${result.savings_percent}% token savings)`,
        output: {
          type: 'signature',
          content: result.signature,
          original_tokens: result.original_tokens,
          signature_tokens: result.signature_tokens,
          savings_percent: result.savings_percent
        }
      };
    } catch (parseError) {
      // Parsing failed, allow normal read
      return {
        decision: 'allow',
        message: `Could not parse ${filePath.split('/').pop()}: ${parseError.message}`
      };
    }
  } catch (error) {
    // On any error, allow normal read
    return {
      decision: 'allow',
      error: error.message
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
      const result = await handlePreRead(parsed);
      console.log(JSON.stringify(result));
    } catch (e) {
      console.log(JSON.stringify({ decision: 'allow', error: e.message }));
    }
  });
}
