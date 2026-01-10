/**
 * Language Configuration for Tree-sitter Signature Extraction
 * Defines supported languages and their AST query patterns
 */

export const LANGUAGES = {
  typescript: {
    extensions: ['.ts', '.tsx'],
    parserPackage: 'tree-sitter-typescript',
    parserFactory: (mod) => mod.typescript,
    queries: {
      // Functions and methods
      functions: `
        (function_declaration
          name: (identifier) @name) @def
        (method_definition
          name: (property_identifier) @name) @def
        (arrow_function
          parameters: (formal_parameters) @params) @def
      `,
      // Classes and interfaces
      classes: `
        (class_declaration
          name: (type_identifier) @name) @def
        (interface_declaration
          name: (type_identifier) @name) @def
        (type_alias_declaration
          name: (type_identifier) @name) @def
      `,
      // Exports
      exports: `
        (export_statement) @export
        (export_clause
          (export_specifier
            name: (identifier) @name))
      `,
      // Imports
      imports: `
        (import_statement) @import
      `
    }
  },

  javascript: {
    extensions: ['.js', '.jsx', '.mjs', '.cjs'],
    parserPackage: 'tree-sitter-javascript',
    parserFactory: (mod) => mod,
    queries: {
      functions: `
        (function_declaration
          name: (identifier) @name) @def
        (method_definition
          name: (property_identifier) @name) @def
        (arrow_function
          parameters: (formal_parameters) @params) @def
      `,
      classes: `
        (class_declaration
          name: (identifier) @name) @def
      `,
      exports: `
        (export_statement) @export
        (export_clause
          (export_specifier
            name: (identifier) @name))
      `,
      imports: `
        (import_statement) @import
      `
    }
  },

  python: {
    extensions: ['.py'],
    parserPackage: 'tree-sitter-python',
    parserFactory: (mod) => mod,
    queries: {
      functions: `
        (function_definition
          name: (identifier) @name) @def
      `,
      classes: `
        (class_definition
          name: (identifier) @name) @def
      `,
      exports: ``,
      imports: `
        (import_statement) @import
        (import_from_statement) @import
      `
    }
  }
};

/**
 * Get language config by file extension
 */
export function getLanguageByExtension(ext) {
  for (const [name, config] of Object.entries(LANGUAGES)) {
    if (config.extensions.includes(ext)) {
      return { name, ...config };
    }
  }
  return null;
}

/**
 * Get language config by name
 */
export function getLanguageByName(name) {
  return LANGUAGES[name] ? { name, ...LANGUAGES[name] } : null;
}

/**
 * Check if file extension is supported
 */
export function isSupported(ext) {
  return getLanguageByExtension(ext) !== null;
}
