/**
 * Progress File Manager
 * Creates and updates progress tracking files for plan execution
 */

import { existsSync, readFileSync, writeFileSync, mkdirSync } from 'fs';
import { dirname, basename, join } from 'path';
import {
  generateProgressJson,
  generateProgressMd,
  generateLogEntry
} from './templates.js';

/**
 * Get progress file paths from a plan file path
 */
export function getProgressPaths(planFile) {
  const dir = dirname(planFile);
  const base = basename(planFile, '.md');

  return {
    json: join(dir, `${base}-progress.json`),
    md: join(dir, `${base}-progress.md`)
  };
}

/**
 * Initialize progress tracking for a plan
 * Creates progress.json and progress.md files
 */
export function initProgress(planFile, projectName, tasks = []) {
  const paths = getProgressPaths(planFile);

  // Ensure directory exists
  const dir = dirname(paths.json);
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }

  // Generate initial data
  const progressData = generateProgressJson(planFile, projectName, tasks);

  // Write JSON file
  writeFileSync(paths.json, JSON.stringify(progressData, null, 2));

  // Generate and write MD file
  let md = generateProgressMd(progressData);
  md += generateLogEntry('Progress tracking initialized');
  writeFileSync(paths.md, md);

  return { paths, data: progressData };
}

/**
 * Load existing progress data
 */
export function getProgress(planFile) {
  const paths = getProgressPaths(planFile);

  if (!existsSync(paths.json)) {
    return null;
  }

  try {
    const content = readFileSync(paths.json, 'utf-8');
    return JSON.parse(content);
  } catch (e) {
    return null;
  }
}

/**
 * Check if progress files exist for a plan
 */
export function hasProgress(planFile) {
  const paths = getProgressPaths(planFile);
  return existsSync(paths.json);
}

/**
 * Update a task's status
 */
export function updateTaskStatus(planFile, taskId, status, options = {}) {
  const paths = getProgressPaths(planFile);
  const progressData = getProgress(planFile);

  if (!progressData) {
    throw new Error(`No progress file found for ${planFile}`);
  }

  // Find and update the task
  const task = progressData.tasks.find(t => t.id === taskId || t.id === String(taskId));
  if (!task) {
    throw new Error(`Task ${taskId} not found in progress`);
  }

  const now = new Date().toISOString();
  const oldStatus = task.status;

  task.status = status;

  if (status === 'in_progress' && !task.startedAt) {
    task.startedAt = now;
  }

  if (status === 'completed') {
    task.completedAt = now;
    if (options.commit) {
      task.commit = options.commit;
    }
  }

  if (options.notes) {
    task.notes = options.notes;
  }

  // Update stats
  progressData.stats = calculateStats(progressData.tasks);
  progressData.updatedAt = now;

  // Update overall status
  if (progressData.stats.completed === progressData.stats.total) {
    progressData.status = 'completed';
  } else if (progressData.stats.inProgress > 0 || progressData.stats.completed > 0) {
    progressData.status = 'in_progress';
  }

  // Write updated JSON
  writeFileSync(paths.json, JSON.stringify(progressData, null, 2));

  // Regenerate MD file
  let md = generateProgressMd(progressData);

  // Preserve existing session log if any
  if (existsSync(paths.md)) {
    const existingMd = readFileSync(paths.md, 'utf-8');
    const logMatch = existingMd.match(/## Session Log\n\n([\s\S]*?)$/);
    if (logMatch && logMatch[1]) {
      md = md.replace(/## Session Log\n\n$/, `## Session Log\n\n${logMatch[1]}`);
    }
  }

  writeFileSync(paths.md, md);

  return progressData;
}

/**
 * Append a message to the session log
 */
export function appendLog(planFile, message) {
  const paths = getProgressPaths(planFile);

  if (!existsSync(paths.md)) {
    throw new Error(`No progress file found for ${planFile}`);
  }

  const logEntry = generateLogEntry(message);
  const content = readFileSync(paths.md, 'utf-8');

  // Append to end of file
  writeFileSync(paths.md, content + logEntry);

  // Also update the JSON updatedAt
  const progressData = getProgress(planFile);
  if (progressData) {
    progressData.updatedAt = new Date().toISOString();
    writeFileSync(paths.json, JSON.stringify(progressData, null, 2));
  }
}

/**
 * Mark the entire progress as completed
 */
export function markComplete(planFile) {
  const paths = getProgressPaths(planFile);
  const progressData = getProgress(planFile);

  if (!progressData) {
    throw new Error(`No progress file found for ${planFile}`);
  }

  progressData.status = 'completed';
  progressData.updatedAt = new Date().toISOString();

  writeFileSync(paths.json, JSON.stringify(progressData, null, 2));

  appendLog(planFile, 'All tasks completed - execution finished');

  return progressData;
}

/**
 * Get summary stats
 */
export function getStats(planFile) {
  const progressData = getProgress(planFile);
  if (!progressData) return null;
  return progressData.stats;
}

// Helper function

function calculateStats(tasks) {
  const stats = {
    total: tasks.length,
    completed: 0,
    inProgress: 0,
    pending: 0,
    blocked: 0
  };

  for (const task of tasks) {
    switch (task.status) {
      case 'completed':
        stats.completed++;
        break;
      case 'in_progress':
        stats.inProgress++;
        break;
      case 'blocked':
        stats.blocked++;
        break;
      default:
        stats.pending++;
    }
  }

  return stats;
}
