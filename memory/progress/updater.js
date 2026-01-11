/**
 * Plan File Updater
 * Updates plan markdown files with completion markers
 */

import { existsSync, readFileSync, writeFileSync } from 'fs';

/**
 * Mark a task as complete in the plan file
 * Adds ✅ prefix and commit reference to task heading
 *
 * Matches patterns like:
 * - #### Task 1.1: Title
 * - ### Task 1: Title
 * - ## Task: Title
 * - - [ ] Task 1.1: Title (checkbox style)
 */
export function markTaskComplete(planFile, taskId, commit = null) {
  if (!existsSync(planFile)) {
    throw new Error(`Plan file not found: ${planFile}`);
  }

  const content = readFileSync(planFile, 'utf-8');

  // Patterns to match task headings
  const patterns = [
    // Heading style: #### Task 1.1: Title or ### Task 1.1: Title
    {
      regex: new RegExp(`^(#{2,6})\\s*(Task\\s*${escapeRegex(taskId)}[:\\s].*)$`, 'gim'),
      replace: (match, hashes, rest) => {
        if (rest.startsWith('✅')) return match; // Already marked
        const commitRef = commit ? ` (commit: ${commit})` : '';
        return `${hashes} ✅ ${rest}${commitRef}`;
      }
    },
    // Checkbox style: - [ ] Task 1.1: Title
    {
      regex: new RegExp(`^(\\s*)-\\s*\\[\\s*\\]\\s*(Task\\s*${escapeRegex(taskId)}[:\\s].*)$`, 'gim'),
      replace: (match, indent, rest) => {
        const commitRef = commit ? ` (commit: ${commit})` : '';
        return `${indent}- [x] ✅ ${rest}${commitRef}`;
      }
    },
    // Already checked but no emoji: - [x] Task 1.1: Title
    {
      regex: new RegExp(`^(\\s*)-\\s*\\[x\\]\\s*(?!✅)(Task\\s*${escapeRegex(taskId)}[:\\s].*)$`, 'gim'),
      replace: (match, indent, rest) => {
        if (rest.includes('(commit:')) return match; // Already has commit
        const commitRef = commit ? ` (commit: ${commit})` : '';
        return `${indent}- [x] ✅ ${rest}${commitRef}`;
      }
    },
    // Numbered list: 1. Task 1.1: Title or 1. **Task 1.1:** Title
    {
      regex: new RegExp(`^(\\s*\\d+\\.)\\s*(?!✅)(\\**Task\\s*${escapeRegex(taskId)}[:\\s].*)$`, 'gim'),
      replace: (match, num, rest) => {
        const commitRef = commit ? ` (commit: ${commit})` : '';
        return `${num} ✅ ${rest}${commitRef}`;
      }
    }
  ];

  let updatedContent = content;
  let matched = false;

  for (const pattern of patterns) {
    const newContent = updatedContent.replace(pattern.regex, (...args) => {
      matched = true;
      return pattern.replace(...args);
    });
    if (newContent !== updatedContent) {
      updatedContent = newContent;
      break; // Only apply first matching pattern
    }
  }

  if (!matched) {
    // Try a more lenient match - just the task ID anywhere in a heading
    const lenientRegex = new RegExp(`^(#{2,6}\\s*)(.*)\\b${escapeRegex(taskId)}\\b(.*)$`, 'gim');
    updatedContent = content.replace(lenientRegex, (match, prefix, before, after) => {
      if (before.includes('✅')) return match;
      const commitRef = commit ? ` (commit: ${commit})` : '';
      return `${prefix}✅ ${before}${taskId}${after}${commitRef}`;
    });
  }

  if (updatedContent !== content) {
    writeFileSync(planFile, updatedContent);
    return true;
  }

  return false;
}

/**
 * Mark a task as in progress in the plan file
 * Adds 🔄 prefix to task heading
 */
export function markTaskInProgress(planFile, taskId) {
  if (!existsSync(planFile)) {
    throw new Error(`Plan file not found: ${planFile}`);
  }

  const content = readFileSync(planFile, 'utf-8');

  // Pattern for heading style
  const regex = new RegExp(`^(#{2,6})\\s*(?!✅|🔄)(Task\\s*${escapeRegex(taskId)}[:\\s].*)$`, 'gim');

  const updatedContent = content.replace(regex, (match, hashes, rest) => {
    return `${hashes} 🔄 ${rest}`;
  });

  if (updatedContent !== content) {
    writeFileSync(planFile, updatedContent);
    return true;
  }

  return false;
}

/**
 * Remove in-progress marker (when completing or resetting)
 */
export function clearInProgressMarker(planFile, taskId) {
  if (!existsSync(planFile)) return false;

  const content = readFileSync(planFile, 'utf-8');

  const regex = new RegExp(`^(#{2,6})\\s*🔄\\s*(Task\\s*${escapeRegex(taskId)}[:\\s].*)$`, 'gim');

  const updatedContent = content.replace(regex, (match, hashes, rest) => {
    return `${hashes} ${rest}`;
  });

  if (updatedContent !== content) {
    writeFileSync(planFile, updatedContent);
    return true;
  }

  return false;
}

/**
 * Extract task list from a plan file
 * Returns array of { id, title } objects
 */
export function extractTasks(planFile) {
  if (!existsSync(planFile)) {
    throw new Error(`Plan file not found: ${planFile}`);
  }

  const content = readFileSync(planFile, 'utf-8');
  const tasks = [];

  // Match various task patterns
  const patterns = [
    // #### Task 1.1: Title
    /^#{2,6}\s*(?:✅\s*|🔄\s*)?Task\s*(\d+(?:\.\d+)?)[:\s]+(.+?)(?:\s*\(commit:[^)]+\))?$/gim,
    // - [ ] Task 1.1: Title or - [x] Task 1.1: Title
    /^\s*-\s*\[[x\s]\]\s*(?:✅\s*)?Task\s*(\d+(?:\.\d+)?)[:\s]+(.+?)(?:\s*\(commit:[^)]+\))?$/gim
  ];

  for (const pattern of patterns) {
    let match;
    while ((match = pattern.exec(content)) !== null) {
      const id = match[1];
      const title = match[2].trim();

      // Avoid duplicates
      if (!tasks.find(t => t.id === id)) {
        tasks.push({ id, title });
      }
    }
  }

  // Sort by ID
  tasks.sort((a, b) => {
    const aParts = a.id.split('.').map(Number);
    const bParts = b.id.split('.').map(Number);

    for (let i = 0; i < Math.max(aParts.length, bParts.length); i++) {
      const aNum = aParts[i] || 0;
      const bNum = bParts[i] || 0;
      if (aNum !== bNum) return aNum - bNum;
    }
    return 0;
  });

  return tasks;
}

// Helper to escape special regex characters
function escapeRegex(str) {
  return String(str).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
