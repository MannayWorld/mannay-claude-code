/**
 * Progress File Templates
 * Generates JSON and Markdown progress files
 */

/**
 * Generate initial progress.json structure
 */
export function generateProgressJson(planFile, projectName, tasks = []) {
  const now = new Date().toISOString();

  return {
    planFile,
    projectName,
    startedAt: now,
    updatedAt: now,
    status: 'pending',
    tasks: tasks.map((task, index) => ({
      id: task.id || `${index + 1}`,
      title: task.title || task,
      status: 'pending',
      startedAt: null,
      completedAt: null,
      commit: null,
      notes: null
    })),
    stats: {
      total: tasks.length,
      completed: 0,
      inProgress: 0,
      pending: tasks.length,
      blocked: 0
    }
  };
}

/**
 * Generate progress.md from progress data
 */
export function generateProgressMd(progressData) {
  const { planFile, projectName, startedAt, status, tasks, stats } = progressData;

  const startDate = formatDate(startedAt);
  const percentage = stats.total > 0
    ? Math.round((stats.completed / stats.total) * 100)
    : 0;

  let md = `# Progress: ${projectName}

**Plan:** ${planFile}
**Started:** ${startDate}
**Status:** ${stats.completed}/${stats.total} tasks completed (${percentage}%)

---

`;

  // Completed tasks
  const completed = tasks.filter(t => t.status === 'completed');
  if (completed.length > 0) {
    md += `## Completed

`;
    for (const task of completed) {
      md += formatCompletedTask(task);
    }
    md += `
`;
  }

  // In Progress tasks
  const inProgress = tasks.filter(t => t.status === 'in_progress');
  if (inProgress.length > 0) {
    md += `## In Progress

`;
    for (const task of inProgress) {
      md += formatInProgressTask(task);
    }
    md += `
`;
  }

  // Blocked tasks
  const blocked = tasks.filter(t => t.status === 'blocked');
  if (blocked.length > 0) {
    md += `## Blocked

`;
    for (const task of blocked) {
      md += formatBlockedTask(task);
    }
    md += `
`;
  }

  // Pending tasks
  const pending = tasks.filter(t => t.status === 'pending');
  if (pending.length > 0) {
    md += `## Pending

`;
    for (const task of pending) {
      md += `### ⬜ ${task.id}: ${task.title}

`;
    }
  }

  // Session log section
  md += `---

## Session Log

`;

  return md;
}

/**
 * Generate a log entry line
 */
export function generateLogEntry(message) {
  const now = new Date();
  const timestamp = formatTimestamp(now);
  return `[${timestamp}] ${message}\n`;
}

// Helper functions

function formatDate(isoString) {
  if (!isoString) return 'Unknown';
  const date = new Date(isoString);
  return date.toISOString().slice(0, 16).replace('T', ' ');
}

function formatTimestamp(date) {
  return date.toISOString().slice(0, 16).replace('T', ' ');
}

function formatCompletedTask(task) {
  let md = `### ✅ ${task.id}: ${task.title}`;
  if (task.commit) {
    md += ` (commit: ${task.commit})`;
  }
  md += `
`;
  if (task.completedAt) {
    md += `- **Completed:** ${formatDate(task.completedAt)}
`;
  }
  if (task.commit) {
    md += `- **Commit:** ${task.commit}
`;
  }
  if (task.notes) {
    md += `- **Notes:** ${task.notes}
`;
  }
  md += `
`;
  return md;
}

function formatInProgressTask(task) {
  let md = `### 🔄 ${task.id}: ${task.title}
`;
  if (task.startedAt) {
    md += `- **Started:** ${formatDate(task.startedAt)}
`;
  }
  if (task.notes) {
    md += `- **Last Action:** ${task.notes}
`;
  }
  md += `
`;
  return md;
}

function formatBlockedTask(task) {
  let md = `### 🚫 ${task.id}: ${task.title}
`;
  if (task.notes) {
    md += `- **Blocked:** ${task.notes}
`;
  }
  md += `
`;
  return md;
}
