/**
 * Learning Extraction Module
 * Extracts and categorizes learnings from session state
 */

const STOP_WORDS = new Set([
  'the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
  'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should',
  'may', 'might', 'must', 'shall', 'can', 'need', 'dare', 'ought', 'used',
  'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from', 'as', 'into',
  'through', 'during', 'before', 'after', 'above', 'below', 'between',
  'and', 'or', 'but', 'if', 'then', 'else', 'when', 'where', 'why', 'how',
  'this', 'that', 'these', 'those', 'i', 'you', 'we', 'they', 'it', 'he', 'she',
  'my', 'your', 'our', 'their', 'its', 'his', 'her',
  'all', 'each', 'every', 'both', 'few', 'more', 'most', 'other', 'some', 'such',
  'no', 'nor', 'not', 'only', 'same', 'so', 'than', 'too', 'very',
  'just', 'also', 'now', 'here', 'there'
]);

const LEARNING_PATTERNS = {
  pattern: [
    /use[ds]?\s+(.+?)\s+pattern/i,
    /implement[ed]?\s+(.+?)\s+approach/i,
    /follow[ed]?\s+(.+?)\s+convention/i,
    /adopt[ed]?\s+(.+?)\s+strategy/i
  ],
  architecture: [
    /structur[ed]?\s+(.+)/i,
    /organiz[ed]?\s+(.+)/i,
    /architect[ed]?\s+(.+)/i,
    /design[ed]?\s+(.+)/i
  ],
  decision: [
    /decid[ed]?\s+to\s+(.+)/i,
    /chos[e]?\s+(.+)/i,
    /select[ed]?\s+(.+)/i,
    /pick[ed]?\s+(.+)/i
  ],
  fix: [
    /fix[ed]?\s+(.+)/i,
    /resolv[ed]?\s+(.+)/i,
    /solv[ed]?\s+(.+)/i,
    /repair[ed]?\s+(.+)/i
  ],
  tip: [
    /remember\s+to\s+(.+)/i,
    /note:\s+(.+)/i,
    /important:\s+(.+)/i,
    /always\s+(.+)/i,
    /never\s+(.+)/i
  ]
};

/**
 * Extract keywords from text
 */
export function extractKeywords(text, limit = 10) {
  if (!text) return [];

  const words = text.toLowerCase()
    .replace(/[^a-z0-9\s-]/g, ' ')
    .split(/\s+/)
    .filter(w => w.length > 2 && !STOP_WORDS.has(w));

  // Count word frequency
  const freq = {};
  for (const word of words) {
    freq[word] = (freq[word] || 0) + 1;
  }

  // Sort by frequency and return top keywords
  return Object.entries(freq)
    .sort((a, b) => b[1] - a[1])
    .slice(0, limit)
    .map(([word]) => word);
}

/**
 * Categorize a learning based on content
 */
export function categorizeLearning(content) {
  const lower = content.toLowerCase();

  for (const [category, patterns] of Object.entries(LEARNING_PATTERNS)) {
    for (const pattern of patterns) {
      if (pattern.test(lower)) {
        return category;
      }
    }
  }

  // Default categorization based on keywords
  if (lower.includes('error') || lower.includes('bug') || lower.includes('issue')) {
    return 'fix';
  }
  if (lower.includes('test') || lower.includes('spec')) {
    return 'testing';
  }
  if (lower.includes('refactor') || lower.includes('clean')) {
    return 'refactoring';
  }
  if (lower.includes('config') || lower.includes('setup') || lower.includes('install')) {
    return 'configuration';
  }

  return 'general';
}

/**
 * Calculate importance score for a learning (1-10)
 */
export function calculateImportance(learning) {
  let score = 5; // Base score

  const content = learning.content.toLowerCase();

  // Boost for specific patterns
  if (content.includes('always') || content.includes('never')) score += 2;
  if (content.includes('important') || content.includes('critical')) score += 2;
  if (content.includes('bug') || content.includes('error')) score += 1;
  if (content.includes('security') || content.includes('vulnerability')) score += 2;
  if (content.includes('performance') || content.includes('optimization')) score += 1;

  // Boost for decisions that involve trade-offs
  if (content.includes('instead of') || content.includes('rather than')) score += 1;
  if (content.includes('because') || content.includes('since')) score += 1;

  // Cap at 10
  return Math.min(10, score);
}

/**
 * Extract learnings from session state
 */
export function extractLearningsFromState(state) {
  const learnings = [];

  // Extract from decisions
  if (state.decisions && state.decisions.length > 0) {
    for (const decision of state.decisions) {
      // Skip git commit messages (they're tracked elsewhere)
      if (decision.startsWith('Committed:')) continue;

      const category = categorizeLearning(decision);
      const keywords = extractKeywords(decision);

      learnings.push({
        content: decision,
        category,
        tags: keywords.join(','),
        source_task: state.task || '',
        source_session: state.session_id || '',
        importance: calculateImportance({ content: decision })
      });
    }
  }

  // Extract patterns from file modifications
  if (state.files_modified && state.files_modified.length > 3) {
    const extensions = state.files_modified.map(f => {
      const parts = f.split('.');
      return parts.length > 1 ? '.' + parts.pop() : '';
    }).filter(Boolean);

    const extCounts = {};
    for (const ext of extensions) {
      extCounts[ext] = (extCounts[ext] || 0) + 1;
    }

    const mainExt = Object.entries(extCounts).sort((a, b) => b[1] - a[1])[0];
    if (mainExt && mainExt[1] >= 3) {
      learnings.push({
        content: `Worked primarily with ${mainExt[0]} files (${mainExt[1]} modified)`,
        category: 'pattern',
        tags: 'files,modification,pattern',
        source_task: state.task || '',
        source_session: state.session_id || '',
        importance: 3
      });
    }
  }

  // Extract blockers as learnings (things to avoid)
  if (state.blockers && state.blockers.length > 0) {
    for (const blocker of state.blockers) {
      learnings.push({
        content: `Encountered blocker: ${blocker}`,
        category: 'tip',
        tags: 'blocker,issue,obstacle',
        source_task: state.task || '',
        source_session: state.session_id || '',
        importance: 6
      });
    }
  }

  return learnings;
}

/**
 * Deduplicate learnings based on content similarity
 */
export function deduplicateLearnings(learnings, existingLearnings = []) {
  const seen = new Set(existingLearnings.map(l => l.content.toLowerCase().trim()));
  const unique = [];

  for (const learning of learnings) {
    const normalized = learning.content.toLowerCase().trim();
    if (!seen.has(normalized)) {
      seen.add(normalized);
      unique.push(learning);
    }
  }

  return unique;
}

/**
 * Format learnings for storage
 */
export function formatForStorage(learnings) {
  return learnings.map(l => ({
    content: l.content,
    tags: l.tags || '',
    source_task: l.source_task || '',
    source_session: l.source_session || ''
  }));
}
