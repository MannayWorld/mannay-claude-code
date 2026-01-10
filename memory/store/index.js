/**
 * Store Module Index
 * Re-exports all database operations
 */

export { initDatabase, getDefaultDbPath } from './init.js';

export {
  getDatabase,
  closeDatabase,
  // Handoff operations
  saveHandoff,
  getLatestHandoff,
  markHandoffResumed,
  getHandoffCount,
  // Signature operations
  getSignature,
  saveSignature,
  deleteSignature,
  getSignatureCount,
  getSignatureStats,
  cleanOldSignatures,
  // Learning operations
  saveLearning,
  searchLearnings,
  getRecentLearnings,
  getLearningCount,
  deleteLearning
} from './sqlite.js';
