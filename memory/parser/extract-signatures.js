/**
 * Signature Extraction using Tree-sitter
 * Extracts function/class signatures for token-efficient context
 */

import { createHash } from 'crypto';
import { extname } from 'path';
import { getLanguageByExtension } from './languages.js';

let Parser = null;
const parserCache = new Map();

/**
 * Lazy load Tree-sitter (optional dependency)
 */
async function getParser() {
  if (Parser) return Parser;
  try {
    const mod = await import('tree-sitter');
    Parser = mod.default;
    return Parser;
  } catch (e) {
    throw new Error('Tree-sitter not available. Install with: npm install tree-sitter');
  }
}

/**
 * Get or create parser for language
 */
async function getParserForLanguage(langConfig) {
  const cacheKey = langConfig.name;
  if (parserCache.has(cacheKey)) {
    return parserCache.get(cacheKey);
  }

  const ParserClass = await getParser();
  const parser = new ParserClass();

  try {
    const langMod = await import(langConfig.parserPackage);
    const language = langConfig.parserFactory(langMod.default || langMod);
    parser.setLanguage(language);
    parserCache.set(cacheKey, parser);
    return parser;
  } catch (e) {
    throw new Error(`Language parser ${langConfig.parserPackage} not available`);
  }
}

/**
 * Estimate token count (rough approximation)
 * GPT-style tokenization: ~4 chars per token for code
 */
function estimateTokens(text) {
  return Math.ceil(text.length / 4);
}

/**
 * Compute content hash
 */
function hashContent(content) {
  return createHash('sha256').update(content).digest('hex').slice(0, 16);
}

/**
 * Extract signature line from node
 */
function extractSignatureLine(node, sourceCode) {
  const startIndex = node.startIndex;
  const lines = sourceCode.slice(0, startIndex).split('\n');
  const lineNumber = lines.length;

  // Get the first line of the definition (signature line)
  const nodeText = sourceCode.slice(node.startIndex, node.endIndex);
  const firstLine = nodeText.split('\n')[0];

  return {
    line: lineNumber,
    signature: firstLine.trim()
  };
}

/**
 * Extract function and class definitions with their signatures
 */
function extractDefinitions(tree, sourceCode, langConfig) {
  const definitions = [];
  const root = tree.rootNode;
  const visited = new Set();

  // Walk the tree to find definitions
  function walk(node) {
    // Avoid processing the same node twice
    if (visited.has(node.id)) return;
    visited.add(node.id);

    const type = node.type;

    // Functions (skip anonymous arrow functions inside expressions)
    if (
      type === 'function_declaration' ||
      type === 'function_definition' ||
      type === 'method_definition'
    ) {
      const nameNode = node.childForFieldName('name');
      const name = nameNode ? sourceCode.slice(nameNode.startIndex, nameNode.endIndex) : '<anonymous>';

      // Skip anonymous functions
      if (name !== '<anonymous>') {
        definitions.push({
          type: type === 'method_definition' ? 'method' : 'function',
          name,
          ...extractSignatureLine(node, sourceCode)
        });
      }
    }

    // Classes
    if (type === 'class_declaration' || type === 'class_definition') {
      const nameNode = node.childForFieldName('name');
      const name = nameNode ? sourceCode.slice(nameNode.startIndex, nameNode.endIndex) : '<anonymous>';

      definitions.push({
        type: 'class',
        name,
        ...extractSignatureLine(node, sourceCode)
      });
    }

    // TypeScript interfaces and type aliases
    if (type === 'interface_declaration') {
      const nameNode = node.childForFieldName('name');
      const name = nameNode ? sourceCode.slice(nameNode.startIndex, nameNode.endIndex) : '<anonymous>';

      definitions.push({
        type: 'interface',
        name,
        ...extractSignatureLine(node, sourceCode)
      });
    }

    if (type === 'type_alias_declaration') {
      const nameNode = node.childForFieldName('name');
      const name = nameNode ? sourceCode.slice(nameNode.startIndex, nameNode.endIndex) : '<anonymous>';

      definitions.push({
        type: 'type',
        name,
        ...extractSignatureLine(node, sourceCode)
      });
    }

    // Recurse into children
    for (const child of node.children) {
      walk(child);
    }
  }

  walk(root);
  return definitions;
}

/**
 * Extract exports
 */
function extractExports(tree, sourceCode) {
  const exports = [];
  const root = tree.rootNode;

  function walk(node) {
    if (node.type === 'export_statement' || node.type === 'export_declaration') {
      const text = sourceCode.slice(node.startIndex, node.endIndex);
      const firstLine = text.split('\n')[0].trim();
      exports.push(firstLine);
    }

    for (const child of node.children) {
      walk(child);
    }
  }

  walk(root);
  return exports;
}

/**
 * Extract imports
 */
function extractImports(tree, sourceCode) {
  const imports = [];
  const root = tree.rootNode;

  function walk(node) {
    if (
      node.type === 'import_statement' ||
      node.type === 'import_from_statement'
    ) {
      const text = sourceCode.slice(node.startIndex, node.endIndex);
      imports.push(text.trim());
    }

    for (const child of node.children) {
      walk(child);
    }
  }

  walk(root);
  return imports;
}

/**
 * Format signature output for context injection
 */
function formatSignature(filePath, definitions, exports, imports) {
  let output = `## ${filePath}\n\n`;

  if (imports.length > 0) {
    output += `### Imports\n\`\`\`\n${imports.slice(0, 5).join('\n')}\n\`\`\`\n\n`;
  }

  if (exports.length > 0) {
    output += `### Exports\n\`\`\`\n${exports.join('\n')}\n\`\`\`\n\n`;
  }

  if (definitions.length > 0) {
    output += `### Definitions\n`;
    const grouped = {};

    for (const def of definitions) {
      if (!grouped[def.type]) grouped[def.type] = [];
      grouped[def.type].push(def);
    }

    for (const [type, defs] of Object.entries(grouped)) {
      output += `\n**${type.charAt(0).toUpperCase() + type.slice(1)}s:**\n`;
      for (const def of defs) {
        output += `- L${def.line}: \`${def.signature}\`\n`;
      }
    }
  }

  return output;
}

/**
 * Main extraction function
 * @param {string} filePath - Path to file
 * @param {string} content - File content
 * @returns {object} Signature data
 */
export async function extractSignature(filePath, content) {
  const ext = extname(filePath);
  const langConfig = getLanguageByExtension(ext);

  if (!langConfig) {
    throw new Error(`Unsupported file type: ${ext}`);
  }

  const parser = await getParserForLanguage(langConfig);
  const tree = parser.parse(content);

  const definitions = extractDefinitions(tree, content, langConfig);
  const exports = extractExports(tree, content);
  const imports = extractImports(tree, content);

  const signatureText = formatSignature(filePath, definitions, exports, imports);
  const originalTokens = estimateTokens(content);
  const signatureTokens = estimateTokens(signatureText);
  const savings = Math.round((1 - signatureTokens / originalTokens) * 100);

  return {
    path: filePath,
    language: langConfig.name,
    hash: hashContent(content),
    signature: signatureText,
    original_tokens: originalTokens,
    signature_tokens: signatureTokens,
    savings_percent: savings,
    definitions_count: definitions.length,
    exports_count: exports.length,
    imports_count: imports.length
  };
}

/**
 * Check if Tree-sitter is available
 */
export async function isTreeSitterAvailable() {
  try {
    await getParser();
    return true;
  } catch (e) {
    return false;
  }
}

// CLI entry point
if (process.argv[1] && process.argv[1].endsWith('extract-signatures.js')) {
  const filePath = process.argv[2];
  if (!filePath) {
    console.error('Usage: node extract-signatures.js <file-path>');
    process.exit(1);
  }

  import('fs').then(async (fs) => {
    try {
      const content = fs.readFileSync(filePath, 'utf-8');
      const result = await extractSignature(filePath, content);
      console.log('=== Signature Extraction Result ===\n');
      console.log(result.signature);
      console.log('\n=== Statistics ===');
      console.log(`Original tokens: ${result.original_tokens}`);
      console.log(`Signature tokens: ${result.signature_tokens}`);
      console.log(`Savings: ${result.savings_percent}%`);
      console.log(`Definitions: ${result.definitions_count}`);
      console.log(`Exports: ${result.exports_count}`);
      console.log(`Imports: ${result.imports_count}`);
    } catch (e) {
      console.error('Error:', e.message);
      process.exit(1);
    }
  });
}
