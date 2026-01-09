/**
 * Mannay Documentation - Main JavaScript
 * Handles theme toggling and mobile navigation
 */

(function() {
  'use strict';

  // ==========================================================================
  // Theme Management
  // ==========================================================================

  const THEME_KEY = 'mannay-docs-theme';

  function getStoredTheme() {
    return localStorage.getItem(THEME_KEY);
  }

  function setStoredTheme(theme) {
    localStorage.setItem(THEME_KEY, theme);
  }

  function getPreferredTheme() {
    const stored = getStoredTheme();
    if (stored) {
      return stored;
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    setStoredTheme(theme);
  }

  function toggleTheme() {
    const current = document.documentElement.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    setTheme(next);
  }

  // Initialize theme
  setTheme(getPreferredTheme());

  // Listen for system preference changes
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
    if (!getStoredTheme()) {
      setTheme(e.matches ? 'dark' : 'light');
    }
  });

  // ==========================================================================
  // Mobile Navigation
  // ==========================================================================

  function toggleSidebar() {
    var sidebar = document.querySelector('.sidebar');
    var overlay = document.querySelector('.overlay');

    if (sidebar && overlay) {
      var isOpen = sidebar.classList.contains('open');

      if (isOpen) {
        sidebar.classList.remove('open');
        overlay.classList.remove('active');
        document.body.style.overflow = '';
      } else {
        sidebar.classList.add('open');
        overlay.classList.add('active');
        document.body.style.overflow = 'hidden';
      }
    }
  }

  function closeSidebar() {
    var sidebar = document.querySelector('.sidebar');
    var overlay = document.querySelector('.overlay');

    if (sidebar && overlay) {
      sidebar.classList.remove('open');
      overlay.classList.remove('active');
      document.body.style.overflow = '';
    }
  }

  // ==========================================================================
  // SVG Icon Creators (Safe DOM methods)
  // ==========================================================================

  function createCopyIcon() {
    var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('width', '14');
    svg.setAttribute('height', '14');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.setAttribute('fill', 'none');
    svg.setAttribute('stroke', 'currentColor');
    svg.setAttribute('stroke-width', '2');

    var rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    rect.setAttribute('x', '9');
    rect.setAttribute('y', '9');
    rect.setAttribute('width', '13');
    rect.setAttribute('height', '13');
    rect.setAttribute('rx', '2');
    rect.setAttribute('ry', '2');

    var path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', 'M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1');

    svg.appendChild(rect);
    svg.appendChild(path);
    return svg;
  }

  function createCheckIcon() {
    var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('width', '14');
    svg.setAttribute('height', '14');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.setAttribute('fill', 'none');
    svg.setAttribute('stroke', 'currentColor');
    svg.setAttribute('stroke-width', '2');

    var polyline = document.createElementNS('http://www.w3.org/2000/svg', 'polyline');
    polyline.setAttribute('points', '20 6 9 17 4 12');

    svg.appendChild(polyline);
    return svg;
  }

  // ==========================================================================
  // Event Listeners
  // ==========================================================================

  document.addEventListener('DOMContentLoaded', function() {
    // Theme toggle buttons
    var themeToggles = document.querySelectorAll('.theme-toggle');
    themeToggles.forEach(function(button) {
      button.addEventListener('click', toggleTheme);
    });

    // Mobile menu toggle
    var menuToggle = document.querySelector('.menu-toggle');
    if (menuToggle) {
      menuToggle.addEventListener('click', toggleSidebar);
    }

    // Overlay click to close sidebar
    var overlay = document.querySelector('.overlay');
    if (overlay) {
      overlay.addEventListener('click', closeSidebar);
    }

    // Close sidebar on nav link click (mobile)
    var navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(function(link) {
      link.addEventListener('click', function() {
        if (window.innerWidth <= 768) {
          closeSidebar();
        }
      });
    });

    // Close sidebar on escape key
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        closeSidebar();
      }
    });

    // Handle resize - close sidebar if switching to desktop
    var resizeTimer;
    window.addEventListener('resize', function() {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(function() {
        if (window.innerWidth > 768) {
          closeSidebar();
        }
      }, 100);
    });

    // ==========================================================================
    // Copy Code Button (Enhancement)
    // ==========================================================================

    var codeBlocks = document.querySelectorAll('pre');

    codeBlocks.forEach(function(pre) {
      // Create copy button
      var button = document.createElement('button');
      button.className = 'copy-button';
      button.title = 'Copy code';
      button.appendChild(createCopyIcon());

      // Add click handler
      button.addEventListener('click', function() {
        var code = pre.querySelector('code');
        var text = code ? code.textContent : pre.textContent;

        navigator.clipboard.writeText(text).then(function() {
          // Clear and add check icon
          while (button.firstChild) {
            button.removeChild(button.firstChild);
          }
          button.appendChild(createCheckIcon());
          button.classList.add('copied');

          setTimeout(function() {
            // Clear and restore copy icon
            while (button.firstChild) {
              button.removeChild(button.firstChild);
            }
            button.appendChild(createCopyIcon());
            button.classList.remove('copied');
          }, 2000);
        }).catch(function(err) {
          console.error('Failed to copy:', err);
        });
      });

      // Add wrapper and button
      pre.style.position = 'relative';
      pre.appendChild(button);
    });

    // Add copy button styles dynamically
    var style = document.createElement('style');
    style.textContent = [
      '.copy-button {',
      '  position: absolute;',
      '  top: 8px;',
      '  right: 8px;',
      '  display: flex;',
      '  align-items: center;',
      '  justify-content: center;',
      '  width: 32px;',
      '  height: 32px;',
      '  background: var(--bg-hover);',
      '  border: 1px solid var(--border-primary);',
      '  border-radius: var(--radius-md);',
      '  color: var(--text-tertiary);',
      '  cursor: pointer;',
      '  opacity: 0;',
      '  transition: all var(--transition-fast);',
      '}',
      'pre:hover .copy-button {',
      '  opacity: 1;',
      '}',
      '.copy-button:hover {',
      '  background: var(--bg-active);',
      '  color: var(--text-primary);',
      '}',
      '.copy-button.copied {',
      '  color: #22c55e;',
      '}'
    ].join('\n');
    document.head.appendChild(style);
  });

  // ==========================================================================
  // Smooth Scrolling for Anchor Links
  // ==========================================================================

  document.addEventListener('click', function(e) {
    if (e.target.matches('a[href^="#"]')) {
      var href = e.target.getAttribute('href');
      if (href === '#') return;

      var target = document.querySelector(href);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });

        // Update URL without scrolling
        history.pushState(null, null, href);
      }
    }
  });

})();
