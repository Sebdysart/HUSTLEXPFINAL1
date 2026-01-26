#!/usr/bin/env node
/**
 * HustleXP Screen Status Tracker
 *
 * Usage:
 *   node scripts/status.js              # Show progress summary
 *   node scripts/status.js complete X   # Mark screen X as complete
 *   node scripts/status.js incomplete X # Mark screen X as incomplete
 *   node scripts/status.js list         # List all screens
 *   node scripts/status.js search X     # Search for screen
 */

const fs = require('fs');
const path = require('path');

// Colors for terminal output
const colors = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m',
};

const STATUS_FILE = path.join(__dirname, '..', 'screens', 'STATUS.md');

// Parse STATUS.md and extract screens
function parseStatus() {
  if (!fs.existsSync(STATUS_FILE)) {
    console.error(`${colors.red}Error: STATUS.md not found at ${STATUS_FILE}${colors.reset}`);
    process.exit(1);
  }

  const content = fs.readFileSync(STATUS_FILE, 'utf-8');
  const lines = content.split('\n');

  const screens = [];
  let currentCategory = '';

  for (const line of lines) {
    // Match category headers (## Something)
    const categoryMatch = line.match(/^## .+ \((\d+)\)$|^## (.+)$/);
    if (categoryMatch) {
      currentCategory = line.replace(/^## /, '').replace(/[🚀🔐🏠👷📋⚙️🔗⚠️]/g, '').trim();
      continue;
    }

    // Match screen items (- [ ] ScreenName or - [x] ScreenName)
    const screenMatch = line.match(/^- \[([ x])\] (.+)$/);
    if (screenMatch && currentCategory) {
      screens.push({
        name: screenMatch[2].trim(),
        complete: screenMatch[1] === 'x',
        category: currentCategory,
        line: line,
      });
    }
  }

  return { content, lines, screens };
}

// Update STATUS.md content
function updateStatus(content, screenName, complete) {
  const checkbox = complete ? '[x]' : '[ ]';
  const oppositeCheckbox = complete ? '[ ]' : '[x]';

  // Update the screen checkbox
  const regex = new RegExp(`^(- )\\[[ x]\\]( ${escapeRegex(screenName)})$`, 'gm');
  let updated = content.replace(regex, `$1${checkbox}$2`);

  // Recalculate progress table
  updated = updateProgressTable(updated);

  // Update last updated date
  const dateRegex = /Last updated: .+$/m;
  const today = new Date().toISOString().split('T')[0];
  updated = updated.replace(dateRegex, `Last updated: ${today}`);

  return updated;
}

function escapeRegex(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// Update the progress table in STATUS.md
function updateProgressTable(content) {
  const { screens } = parseStatusFromContent(content);

  // Group by category
  const categories = {};
  for (const screen of screens) {
    if (!categories[screen.category]) {
      categories[screen.category] = { complete: 0, total: 0 };
    }
    categories[screen.category].total++;
    if (screen.complete) {
      categories[screen.category].complete++;
    }
  }

  // Build new table
  const categoryOrder = [
    'Bootstrap (BLOCKING)',
    'Auth (3)',
    'Onboarding (12)',
    'Hustler Flow (9)',
    'Poster Flow (4)',
    'Settings (3)',
    'Shared (4)',
    'Edge Cases (3)',
  ];

  let totalComplete = 0;
  let totalScreens = 0;

  const tableRows = categoryOrder.map(cat => {
    const key = Object.keys(categories).find(k => k.includes(cat.split(' ')[0]));
    if (key && categories[key]) {
      totalComplete += categories[key].complete;
      totalScreens += categories[key].total;
      return `| ${cat.split(' ')[0]} | ${categories[key].complete} | ${categories[key].total} |`;
    }
    return null;
  }).filter(Boolean);

  const newTable = `## Progress

| Category | Complete | Total |
|----------|----------|-------|
${tableRows.join('\n')}
| **TOTAL** | **${totalComplete}** | **${totalScreens}** |`;

  // Replace old table
  const tableRegex = /## Progress[\s\S]*?\| \*\*TOTAL\*\* \| \*\*\d+\*\* \| \*\*\d+\*\* \|/;
  return content.replace(tableRegex, newTable);
}

function parseStatusFromContent(content) {
  const lines = content.split('\n');
  const screens = [];
  let currentCategory = '';

  for (const line of lines) {
    const categoryMatch = line.match(/^## .+ \((\d+)\)$|^## (.+)$/);
    if (categoryMatch) {
      currentCategory = line.replace(/^## /, '').replace(/[🚀🔐🏠👷📋⚙️🔗⚠️]/g, '').trim();
      continue;
    }

    const screenMatch = line.match(/^- \[([ x])\] (.+)$/);
    if (screenMatch && currentCategory) {
      screens.push({
        name: screenMatch[2].trim(),
        complete: screenMatch[1] === 'x',
        category: currentCategory,
      });
    }
  }

  return { screens };
}

// Display progress summary
function showSummary() {
  const { screens } = parseStatus();

  const complete = screens.filter(s => s.complete);
  const incomplete = screens.filter(s => !s.complete);

  const percentage = Math.round((complete.length / screens.length) * 100);

  // Progress bar
  const barWidth = 30;
  const filled = Math.round((complete.length / screens.length) * barWidth);
  const bar = '█'.repeat(filled) + '░'.repeat(barWidth - filled);

  console.log('');
  console.log(`${colors.bold}${colors.cyan}╔═══════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}║          HustleXP Screen Status                   ║${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}╚═══════════════════════════════════════════════════╝${colors.reset}`);
  console.log('');

  // Progress bar
  const barColor = percentage < 30 ? colors.red : percentage < 70 ? colors.yellow : colors.green;
  console.log(`  ${colors.gray}Progress:${colors.reset} ${barColor}${bar}${colors.reset} ${percentage}%`);
  console.log('');

  // Stats
  console.log(`  ${colors.green}✓ Complete:${colors.reset}   ${complete.length}`);
  console.log(`  ${colors.yellow}○ Remaining:${colors.reset}  ${incomplete.length}`);
  console.log(`  ${colors.blue}◉ Total:${colors.reset}      ${screens.length}`);
  console.log('');

  // By category
  const categories = {};
  for (const screen of screens) {
    if (!categories[screen.category]) {
      categories[screen.category] = { complete: 0, total: 0, screens: [] };
    }
    categories[screen.category].total++;
    categories[screen.category].screens.push(screen);
    if (screen.complete) {
      categories[screen.category].complete++;
    }
  }

  console.log(`  ${colors.bold}By Category:${colors.reset}`);
  for (const [cat, data] of Object.entries(categories)) {
    const catPercent = Math.round((data.complete / data.total) * 100);
    const status = data.complete === data.total
      ? `${colors.green}✓${colors.reset}`
      : data.complete > 0
        ? `${colors.yellow}◐${colors.reset}`
        : `${colors.gray}○${colors.reset}`;
    console.log(`    ${status} ${cat}: ${data.complete}/${data.total}`);
  }

  console.log('');

  // Next up
  if (incomplete.length > 0) {
    console.log(`  ${colors.bold}Next up:${colors.reset}`);
    incomplete.slice(0, 3).forEach(s => {
      console.log(`    ${colors.gray}○${colors.reset} ${s.name} ${colors.gray}(${s.category})${colors.reset}`);
    });
    if (incomplete.length > 3) {
      console.log(`    ${colors.gray}... and ${incomplete.length - 3} more${colors.reset}`);
    }
    console.log('');
  }
}

// Mark a screen as complete/incomplete
function markScreen(screenName, complete) {
  const { content, screens } = parseStatus();

  // Find the screen (case-insensitive partial match)
  const matches = screens.filter(s =>
    s.name.toLowerCase().includes(screenName.toLowerCase())
  );

  if (matches.length === 0) {
    console.error(`${colors.red}Error: No screen found matching "${screenName}"${colors.reset}`);
    console.log(`${colors.gray}Use "node scripts/status.js list" to see all screens${colors.reset}`);
    process.exit(1);
  }

  if (matches.length > 1) {
    console.error(`${colors.yellow}Multiple matches found:${colors.reset}`);
    matches.forEach(m => console.log(`  - ${m.name}`));
    console.log(`${colors.gray}Please be more specific${colors.reset}`);
    process.exit(1);
  }

  const screen = matches[0];

  if (screen.complete === complete) {
    console.log(`${colors.yellow}${screen.name} is already ${complete ? 'complete' : 'incomplete'}${colors.reset}`);
    return;
  }

  const updated = updateStatus(content, screen.name, complete);
  fs.writeFileSync(STATUS_FILE, updated);

  const emoji = complete ? '✓' : '○';
  const color = complete ? colors.green : colors.yellow;
  console.log(`${color}${emoji} ${screen.name} marked as ${complete ? 'complete' : 'incomplete'}${colors.reset}`);

  // Show updated stats
  showSummary();
}

// List all screens
function listScreens() {
  const { screens } = parseStatus();

  console.log('');
  console.log(`${colors.bold}All Screens (${screens.length}):${colors.reset}`);
  console.log('');

  let currentCategory = '';
  for (const screen of screens) {
    if (screen.category !== currentCategory) {
      currentCategory = screen.category;
      console.log(`  ${colors.bold}${colors.cyan}${currentCategory}${colors.reset}`);
    }
    const status = screen.complete
      ? `${colors.green}✓${colors.reset}`
      : `${colors.gray}○${colors.reset}`;
    console.log(`    ${status} ${screen.name}`);
  }
  console.log('');
}

// Search for a screen
function searchScreen(query) {
  const { screens } = parseStatus();

  const matches = screens.filter(s =>
    s.name.toLowerCase().includes(query.toLowerCase()) ||
    s.category.toLowerCase().includes(query.toLowerCase())
  );

  if (matches.length === 0) {
    console.log(`${colors.yellow}No screens found matching "${query}"${colors.reset}`);
    return;
  }

  console.log('');
  console.log(`${colors.bold}Found ${matches.length} screen(s):${colors.reset}`);
  console.log('');

  for (const screen of matches) {
    const status = screen.complete
      ? `${colors.green}✓${colors.reset}`
      : `${colors.gray}○${colors.reset}`;
    console.log(`  ${status} ${screen.name} ${colors.gray}(${screen.category})${colors.reset}`);
  }
  console.log('');
}

// Main
const args = process.argv.slice(2);
const command = args[0];

switch (command) {
  case 'complete':
  case 'done':
    if (!args[1]) {
      console.error(`${colors.red}Usage: node scripts/status.js complete <ScreenName>${colors.reset}`);
      process.exit(1);
    }
    markScreen(args[1], true);
    break;

  case 'incomplete':
  case 'undo':
    if (!args[1]) {
      console.error(`${colors.red}Usage: node scripts/status.js incomplete <ScreenName>${colors.reset}`);
      process.exit(1);
    }
    markScreen(args[1], false);
    break;

  case 'list':
  case 'ls':
    listScreens();
    break;

  case 'search':
  case 'find':
    if (!args[1]) {
      console.error(`${colors.red}Usage: node scripts/status.js search <query>${colors.reset}`);
      process.exit(1);
    }
    searchScreen(args[1]);
    break;

  case 'help':
  case '--help':
  case '-h':
    console.log(`
${colors.bold}HustleXP Screen Status Tracker${colors.reset}

${colors.cyan}Usage:${colors.reset}
  node scripts/status.js              Show progress summary
  node scripts/status.js complete X   Mark screen X as complete
  node scripts/status.js incomplete X Mark screen X as incomplete
  node scripts/status.js list         List all screens
  node scripts/status.js search X     Search for screen

${colors.cyan}Examples:${colors.reset}
  node scripts/status.js complete Login
  node scripts/status.js complete HustlerHome
  node scripts/status.js search Task
`);
    break;

  default:
    showSummary();
}
