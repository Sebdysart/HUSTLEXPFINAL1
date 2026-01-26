#!/usr/bin/env node

/**
 * HustleXP Screen Spec Loader CLI
 * 
 * Usage:
 *   node scripts/spec.js list              # List all screens
 *   node scripts/spec.js HomeScreen        # Show details for one screen
 *   node scripts/spec.js --json TaskActive # Output as JSON
 *   node scripts/spec.js --rebuild         # Force rebuild cache
 */

const fs = require('fs');
const path = require('path');

const SCREENS_DIR = path.join(process.env.HOME, 'hustlexp-api', 'screens');
const CACHE_PATH = path.join(__dirname, 'specs.json');

// ─────────────────────────────────────────────────────────────────────────────
// Parser Functions
// ─────────────────────────────────────────────────────────────────────────────

function parseScreenSpec(content, filename) {
  const screens = [];
  
  // Check if this is a multi-screen file (like DISPUTE_FLOW.md)
  const subScreenMatches = [...content.matchAll(/^#\s+[A-D]\)\s+SCR-([A-Z0-9-]+)/gm)];
  
  if (subScreenMatches.length > 0) {
    // Multi-screen file - parse each sub-screen
    const sections = content.split(/^(?=#\s+[A-D]\)\s+SCR-)/m);
    const fileHeader = sections[0]; // Content before first sub-screen
    
    for (let i = 1; i < sections.length; i++) {
      const section = sections[i];
      const screen = parseScreenSection(section, filename);
      if (screen) {
        // Inherit file-level properties if not defined
        screen.fileContext = parseFileHeader(fileHeader);
        screens.push(screen);
      }
    }
  } else {
    // Single screen file
    const screen = parseScreenSection(content, filename);
    if (screen) {
      screens.push(screen);
    }
  }
  
  return screens;
}

function parseFileHeader(content) {
  const principles = extractSection(content, 'Principles', 'State Model');
  const stateModel = extractCodeBlock(content, 'State Model');
  
  return {
    principles: principles ? parseBulletList(principles) : [],
    stateModel: stateModel || null
  };
}

function parseScreenSection(content, filename) {
  // Extract screen ID and name from header
  // Handles: "# SCR-HOME-HUSTLER-001: Name" and "# A) SCR-DISPUTE-ENTRY-POSTER-001"
  const headerMatch = content.match(/^#\s+(?:[A-D]\)\s*)?(SCR-[A-Z0-9-]+)(?::\s*(.+))?$/m);
  if (!headerMatch && !content.match(/^#\s+.+/m)) {
    return null;
  }
  
  const screenId = headerMatch?.[1] || null;
  const screenName = headerMatch?.[2]?.trim() || (screenId ? null : extractTitle(content));
  
  // Derive a friendly name for lookup
  const friendlyName = deriveFriendlyName(screenId, screenName, filename);
  
  return {
    id: screenId,
    name: screenName,
    friendlyName,
    filename: path.basename(filename),
    status: extractField(content, 'Status'),
    entry: extractField(content, 'Entry'),
    purpose: extractField(content, 'Primary Purpose') || extractField(content, 'Purpose'),
    
    // Layout & Components
    layoutHierarchy: extractLayoutHierarchy(content),
    components: extractComponents(content),
    
    // Behavior
    rules: extractRules(content),
    states: extractStates(content),
    
    // Motion
    motionSpec: extractMotionSpec(content),
    
    // API
    apiEndpoints: extractApiEndpoints(content),
    
    // Errors & Accessibility
    errorHandling: extractTable(content, 'Error Handling'),
    accessibility: extractSection(content, 'Accessibility')
  };
}

function extractTitle(content) {
  const match = content.match(/^#\s+(.+)$/m);
  return match ? match[1].trim() : 'Unknown';
}

function extractField(content, fieldName) {
  const regex = new RegExp(`\\*\\*${fieldName}:\\*\\*\\s*(.+?)(?:\\n|$)`, 'i');
  const match = content.match(regex);
  return match ? match[1].trim() : null;
}

function extractSection(content, sectionName, endSection = null) {
  const startRegex = new RegExp(`^##\\s+${sectionName}[\\s\\S]*?\\n`, 'm');
  const startMatch = content.match(startRegex);
  if (!startMatch) return null;
  
  const startIdx = startMatch.index + startMatch[0].length;
  
  // Find the end of this section (next ## or end of content)
  let endIdx;
  if (endSection) {
    const endRegex = new RegExp(`^##\\s+${endSection}`, 'm');
    const endMatch = content.slice(startIdx).match(endRegex);
    endIdx = endMatch ? startIdx + endMatch.index : content.length;
  } else {
    const nextSectionMatch = content.slice(startIdx).match(/^##\s+/m);
    endIdx = nextSectionMatch ? startIdx + nextSectionMatch.index : content.length;
  }
  
  return content.slice(startIdx, endIdx).trim();
}

function extractCodeBlock(content, afterSection) {
  const sectionContent = extractSection(content, afterSection);
  if (!sectionContent) return null;
  
  const codeBlockMatch = sectionContent.match(/```[\w]*\n([\s\S]*?)```/);
  return codeBlockMatch ? codeBlockMatch[1].trim() : null;
}

function extractLayoutHierarchy(content) {
  // First try the section-based approach
  let hierarchy = extractCodeBlock(content, 'Layout Hierarchy');
  
  // If not found, look for any code block that looks like a component tree
  if (!hierarchy) {
    const codeBlocks = [...content.matchAll(/```(?:\w*)\n([\s\S]*?)```/g)];
    for (const match of codeBlocks) {
      const block = match[1].trim();
      // Check if this looks like a component hierarchy (has tree characters or indentation + component names)
      if (block.match(/^[\w]+(?:Screen|View|Layout)?\s*(?:\([^)]*\))?$/m) || 
          block.match(/[├└│─]/) ||
          block.match(/^\s+[├└│─]/m)) {
        hierarchy = block;
        break;
      }
    }
  }
  
  return hierarchy;
}

function extractComponents(content) {
  const hierarchy = extractLayoutHierarchy(content);
  if (!hierarchy) return [];
  
  // Extract component names from the ASCII tree
  const components = new Set();
  const lines = hierarchy.split('\n');
  
  for (const line of lines) {
    // Match component names like "Header", "TaskRow (HX-TaskRow/Available, repeat)"
    const match = line.match(/[├└│─\s]*([\w]+)(?:\s*\(([^)]+)\))?/);
    if (match && match[1]) {
      const componentName = match[1];
      const extras = match[2];
      
      if (componentName && !['repeat'].includes(componentName.toLowerCase())) {
        components.add(componentName);
        
        // Also extract HX-* component references
        if (extras) {
          const hxMatches = extras.match(/HX-[\w/]+/g);
          if (hxMatches) {
            hxMatches.forEach(hx => components.add(hx));
          }
        }
      }
    }
  }
  
  return [...components].sort();
}

function extractRules(content) {
  const rules = [];
  
  // Find all "Rules:" or "**Rules:**" sections
  const rulesMatches = [...content.matchAll(/(?:^|\n)\*\*?Rules:?\*\*?\s*\n((?:[-•]\s*.+\n?)+)/gm)];
  
  for (const match of rulesMatches) {
    const rulesList = parseBulletList(match[1]);
    rules.push(...rulesList);
  }
  
  // Also look for inline rules in various sections
  const rulePatterns = [
    /Must\s+\*\*not\*\*\s+(.+)/gi,
    /Never\s+(.+)/gi,
    /Always\s+(.+)/gi,
    /Cannot\s+(.+)/gi
  ];
  
  for (const pattern of rulePatterns) {
    const matches = [...content.matchAll(pattern)];
    for (const m of matches) {
      rules.push(m[0].trim());
    }
  }
  
  return [...new Set(rules)];
}

function extractStates(content) {
  const states = [];
  
  // Look for state tables
  const tableMatch = content.match(/\|\s*State\s*\|[\s\S]*?\n\n/);
  if (tableMatch) {
    const rows = tableMatch[0].split('\n').slice(2); // Skip header and separator
    for (const row of rows) {
      const cols = row.split('|').filter(c => c.trim());
      if (cols.length >= 2) {
        states.push({
          state: cols[0]?.trim(),
          description: cols.slice(1).join(' ').trim()
        });
      }
    }
  }
  
  // Also extract state model if present
  const stateModelMatch = content.match(/```\n((?:\w+\s*→\s*)+\w+)\n```/);
  if (stateModelMatch) {
    states.push({ flow: stateModelMatch[1].trim() });
  }
  
  return states;
}

function extractMotionSpec(content) {
  const section = extractSection(content, 'Motion Spec');
  if (!section) return null;
  
  const allowed = [];
  const forbidden = [];
  let haptic = null;
  
  // Parse Allowed section
  const allowedMatch = section.match(/\*\*Allowed:\*\*\s*\n((?:[-•]\s*.+\n?)+)/);
  if (allowedMatch) {
    allowed.push(...parseBulletList(allowedMatch[1]));
  }
  
  // Parse Forbidden section
  const forbiddenMatch = section.match(/\*\*Forbidden:\*\*\s*\n((?:[-•]\s*.+\n?)+)/);
  if (forbiddenMatch) {
    forbidden.push(...parseBulletList(forbiddenMatch[1]));
  }
  
  // Parse Haptic
  const hapticMatch = section.match(/\*\*Haptic:\*\*\s*(.+)/);
  if (hapticMatch) {
    haptic = hapticMatch[1].trim();
  }
  
  return { allowed, forbidden, haptic };
}

function extractApiEndpoints(content) {
  const endpoints = [];
  
  // Match patterns like "POST /tasks/:id/accept" or "GET /users/:id"
  const apiMatches = [...content.matchAll(/(GET|POST|PUT|PATCH|DELETE)\s+(\/[\w/:]+)/g)];
  
  for (const match of apiMatches) {
    endpoints.push({
      method: match[1],
      path: match[2]
    });
  }
  
  return [...new Map(endpoints.map(e => [`${e.method} ${e.path}`, e])).values()];
}

function extractTable(content, sectionName) {
  const section = extractSection(content, sectionName);
  if (!section) return [];
  
  const rows = [];
  const lines = section.split('\n').filter(l => l.startsWith('|') && !l.includes('---'));
  
  if (lines.length < 2) return [];
  
  // Get headers
  const headers = lines[0].split('|').filter(h => h.trim()).map(h => h.trim().toLowerCase());
  
  // Parse data rows
  for (let i = 1; i < lines.length; i++) {
    const cols = lines[i].split('|').filter(c => c.trim()).map(c => c.trim());
    const row = {};
    headers.forEach((h, idx) => {
      row[h] = cols[idx] || '';
    });
    rows.push(row);
  }
  
  return rows;
}

function parseBulletList(text) {
  return text
    .split('\n')
    .filter(l => l.match(/^[-•]\s+/))
    .map(l => l.replace(/^[-•]\s+/, '').trim())
    .filter(l => l);
}

function deriveFriendlyName(screenId, screenName, filename) {
  // Generate a camelCase friendly name for easy lookup
  if (screenId) {
    // SCR-HOME-HUSTLER-001 -> HomeHustler
    const parts = screenId.replace(/^SCR-/, '').replace(/-\d+$/, '').split('-');
    return parts.map(p => p.charAt(0).toUpperCase() + p.slice(1).toLowerCase()).join('');
  }
  
  if (screenName) {
    // "Home (Hustler Mode)" -> HomeHustlerMode
    return screenName.replace(/[()]/g, '').replace(/\s+/g, '');
  }
  
  // Fallback to filename
  return path.basename(filename, '.md').replace(/_/g, '');
}

// ─────────────────────────────────────────────────────────────────────────────
// Cache Management
// ─────────────────────────────────────────────────────────────────────────────

function buildCache() {
  const files = fs.readdirSync(SCREENS_DIR).filter(f => f.endsWith('.md'));
  const allScreens = [];
  
  for (const file of files) {
    const filepath = path.join(SCREENS_DIR, file);
    const content = fs.readFileSync(filepath, 'utf-8');
    const screens = parseScreenSpec(content, file);
    allScreens.push(...screens);
  }
  
  const cache = {
    version: 1,
    generatedAt: new Date().toISOString(),
    screens: allScreens
  };
  
  fs.writeFileSync(CACHE_PATH, JSON.stringify(cache, null, 2));
  return cache;
}

function loadCache(forceRebuild = false) {
  // Check if cache exists and is fresh
  if (!forceRebuild && fs.existsSync(CACHE_PATH)) {
    try {
      const cache = JSON.parse(fs.readFileSync(CACHE_PATH, 'utf-8'));
      const cacheTime = new Date(cache.generatedAt).getTime();
      
      // Check if any source files are newer than cache
      const files = fs.readdirSync(SCREENS_DIR).filter(f => f.endsWith('.md'));
      let needsRebuild = false;
      
      for (const file of files) {
        const stat = fs.statSync(path.join(SCREENS_DIR, file));
        if (stat.mtimeMs > cacheTime) {
          needsRebuild = true;
          break;
        }
      }
      
      if (!needsRebuild) {
        return cache;
      }
    } catch (e) {
      // Cache corrupted, rebuild
    }
  }
  
  return buildCache();
}

// ─────────────────────────────────────────────────────────────────────────────
// Output Formatting
// ─────────────────────────────────────────────────────────────────────────────

function formatScreen(screen, compact = false) {
  const lines = [];
  
  lines.push(`\n${'═'.repeat(60)}`);
  lines.push(`📱 ${screen.name || screen.friendlyName}`);
  lines.push(`   ID: ${screen.id || 'N/A'}`);
  lines.push(`${'═'.repeat(60)}\n`);
  
  if (screen.status) lines.push(`📊 Status: ${screen.status}`);
  if (screen.entry) lines.push(`🚪 Entry: ${screen.entry}`);
  if (screen.purpose) lines.push(`🎯 Purpose: ${screen.purpose}`);
  
  if (screen.components?.length > 0) {
    lines.push(`\n🧩 Components (${screen.components.length}):`);
    const cols = 3;
    for (let i = 0; i < screen.components.length; i += cols) {
      const row = screen.components.slice(i, i + cols).map(c => c.padEnd(25)).join('');
      lines.push(`   ${row}`);
    }
  }
  
  if (screen.apiEndpoints?.length > 0) {
    lines.push(`\n🔗 API Endpoints:`);
    for (const ep of screen.apiEndpoints) {
      lines.push(`   ${ep.method.padEnd(6)} ${ep.path}`);
    }
  }
  
  if (screen.motionSpec && !compact) {
    lines.push(`\n✨ Motion Spec:`);
    if (screen.motionSpec.allowed?.length) {
      lines.push(`   ✅ Allowed: ${screen.motionSpec.allowed.join(', ')}`);
    }
    if (screen.motionSpec.forbidden?.length) {
      lines.push(`   ❌ Forbidden: ${screen.motionSpec.forbidden.join(', ')}`);
    }
    if (screen.motionSpec.haptic) {
      lines.push(`   📳 Haptic: ${screen.motionSpec.haptic}`);
    }
  }
  
  if (screen.rules?.length > 0 && !compact) {
    lines.push(`\n📋 Rules:`);
    for (const rule of screen.rules.slice(0, 8)) {
      lines.push(`   • ${rule}`);
    }
    if (screen.rules.length > 8) {
      lines.push(`   ... and ${screen.rules.length - 8} more`);
    }
  }
  
  if (screen.layoutHierarchy && !compact) {
    lines.push(`\n🌳 Layout Hierarchy:`);
    lines.push('```');
    lines.push(screen.layoutHierarchy);
    lines.push('```');
  }
  
  return lines.join('\n');
}

function formatList(screens) {
  const lines = [];
  lines.push(`\n📱 HustleXP Screen Specs (${screens.length} screens)\n`);
  lines.push('─'.repeat(60));
  
  // Group by file
  const byFile = {};
  for (const s of screens) {
    const file = s.filename || 'Unknown';
    if (!byFile[file]) byFile[file] = [];
    byFile[file].push(s);
  }
  
  for (const [file, fileScreens] of Object.entries(byFile)) {
    lines.push(`\n📄 ${file}`);
    for (const s of fileScreens) {
      const name = s.friendlyName || s.name || s.id;
      const id = s.id ? ` (${s.id})` : '';
      lines.push(`   → ${name}${id}`);
    }
  }
  
  lines.push('\n' + '─'.repeat(60));
  lines.push('Use: node scripts/spec.js <ScreenName> for details\n');
  
  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────────────────────
// Search
// ─────────────────────────────────────────────────────────────────────────────

function findScreen(screens, query) {
  const q = query.toLowerCase();
  
  // Exact match on ID
  let match = screens.find(s => s.id?.toLowerCase() === q);
  if (match) return match;
  
  // Exact match on friendly name
  match = screens.find(s => s.friendlyName?.toLowerCase() === q);
  if (match) return match;
  
  // Partial match on friendly name
  match = screens.find(s => s.friendlyName?.toLowerCase().includes(q));
  if (match) return match;
  
  // Partial match on name
  match = screens.find(s => s.name?.toLowerCase().includes(q));
  if (match) return match;
  
  // Partial match on ID
  match = screens.find(s => s.id?.toLowerCase().includes(q));
  if (match) return match;
  
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// CLI Entry Point
// ─────────────────────────────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);
  
  // Parse flags
  let jsonOutput = false;
  let forceRebuild = false;
  const positionalArgs = [];
  
  for (const arg of args) {
    if (arg === '--json' || arg === '-j') {
      jsonOutput = true;
    } else if (arg === '--rebuild' || arg === '-r') {
      forceRebuild = true;
    } else if (arg === '--help' || arg === '-h') {
      console.log(`
HustleXP Screen Spec Loader

Usage:
  node scripts/spec.js list              List all screens
  node scripts/spec.js <name>            Show screen details
  node scripts/spec.js --json <name>     Output as JSON
  node scripts/spec.js --rebuild         Force rebuild cache

Examples:
  node scripts/spec.js HomeHustler
  node scripts/spec.js TaskActive
  node scripts/spec.js --json DisputeEntryPoster
  node scripts/spec.js SCR-TASK-ACTIVE-HUSTLER-001
`);
      process.exit(0);
    } else if (!arg.startsWith('-')) {
      positionalArgs.push(arg);
    }
  }
  
  // Load cache
  const cache = loadCache(forceRebuild);
  
  if (forceRebuild && positionalArgs.length === 0) {
    console.log(`✅ Cache rebuilt: ${cache.screens.length} screens indexed`);
    return;
  }
  
  const command = positionalArgs[0]?.toLowerCase();
  
  if (!command || command === 'list') {
    // List all screens
    if (jsonOutput) {
      console.log(JSON.stringify(cache.screens.map(s => ({
        id: s.id,
        name: s.name,
        friendlyName: s.friendlyName,
        filename: s.filename
      })), null, 2));
    } else {
      console.log(formatList(cache.screens));
    }
    return;
  }
  
  // Find specific screen
  const screen = findScreen(cache.screens, positionalArgs.join(' '));
  
  if (!screen) {
    console.error(`❌ Screen not found: "${positionalArgs.join(' ')}"`);
    console.error(`\nAvailable screens:`);
    for (const s of cache.screens) {
      console.error(`  - ${s.friendlyName} (${s.id || 'no ID'})`);
    }
    process.exit(1);
  }
  
  if (jsonOutput) {
    console.log(JSON.stringify(screen, null, 2));
  } else {
    console.log(formatScreen(screen));
  }
}

main();
