/**
 * Session State Tracker
 * Tracks current session state for handoff persistence
 */

import { existsSync, readFileSync, writeFileSync, mkdirSync } from 'fs';
import { dirname } from 'path';

const DEFAULT_STATE = {
  session_id: null,
  task: null,
  status: 'idle',
  started_at: null,
  files_modified: [],
  files_read: [],
  decisions: [],
  todos: [],
  blockers: [],
  last_action: null,
  action_count: 0
};

export class SessionState {
  constructor(statePath) {
    this.statePath = statePath;
    this.state = this.load();
  }

  load() {
    if (existsSync(this.statePath)) {
      try {
        const content = readFileSync(this.statePath, 'utf-8');
        return { ...DEFAULT_STATE, ...JSON.parse(content) };
      } catch (e) {
        // Corrupted state file, start fresh
        return { ...DEFAULT_STATE };
      }
    }
    return { ...DEFAULT_STATE };
  }

  save() {
    try {
      const dir = dirname(this.statePath);
      if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
      }
      writeFileSync(this.statePath, JSON.stringify(this.state, null, 2));
    } catch (e) {
      console.error('Failed to save session state:', e.message);
    }
  }

  startSession(task = null) {
    const now = new Date().toISOString();
    this.state = {
      ...DEFAULT_STATE,
      session_id: now.replace(/[:.]/g, '-').slice(0, 19),
      task: task,
      status: 'in_progress',
      started_at: now
    };
    this.save();
    return this.state;
  }

  updateTask(task) {
    if (!this.state.session_id) {
      this.startSession(task);
    } else {
      this.state.task = task;
      this.save();
    }
  }

  addDecision(decision) {
    if (!decision) return;
    if (!this.state.decisions.includes(decision)) {
      this.state.decisions.push(decision);
      this.save();
    }
  }

  addFileModified(filePath) {
    if (!filePath) return;
    if (!this.state.files_modified.includes(filePath)) {
      this.state.files_modified.push(filePath);
      this.save();
    }
  }

  addFileRead(filePath) {
    if (!filePath) return;
    if (!this.state.files_read.includes(filePath)) {
      this.state.files_read.push(filePath);
      this.save();
    }
  }

  updateTodos(todos) {
    this.state.todos = todos || [];
    this.save();
  }

  setLastAction(action) {
    this.state.last_action = action;
    this.state.action_count++;
    if (!this.state.session_id) {
      this.startSession();
    }
    this.save();
  }

  addBlocker(blocker) {
    if (!blocker) return;
    if (!this.state.blockers.includes(blocker)) {
      this.state.blockers.push(blocker);
      this.save();
    }
  }

  removeBlocker(blocker) {
    const idx = this.state.blockers.indexOf(blocker);
    if (idx !== -1) {
      this.state.blockers.splice(idx, 1);
      this.save();
    }
  }

  setStatus(status) {
    this.state.status = status;
    this.save();
  }

  getState() {
    return { ...this.state };
  }

  getSummary() {
    const s = this.state;
    const task = s.task || 'Unknown task';
    const files = s.files_modified?.length || 0;
    const decisions = s.decisions?.length || 0;
    return `${task} - ${files} files modified, ${decisions} decisions`;
  }

  hasActivity() {
    return this.state.action_count > 0;
  }

  clear() {
    this.state = { ...DEFAULT_STATE };
    this.save();
  }

  restore(savedState) {
    this.state = { ...DEFAULT_STATE, ...savedState };
    this.save();
  }
}

// Singleton instance cache
const instances = new Map();

export function getCurrentSession(statePath) {
  if (!instances.has(statePath)) {
    instances.set(statePath, new SessionState(statePath));
  }
  return instances.get(statePath);
}

export function clearSessionCache() {
  instances.clear();
}
