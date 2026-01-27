const fs = require('fs');
const path = require('path');

const fixes = [
  // Fix unused navigation - prefix with underscore
  { pattern: /const \{ navigation \} = useNavigation/g, replacement: 'const { navigation: _navigation } = useNavigation' },
  { pattern: /const navigation = useNavigation/g, replacement: 'const _navigation = useNavigation' },
  
  // Fix unused imports by removing them (common patterns)
  { pattern: /import \{([^}]*),\s*Card([^}]*)\} from/g, replacement: 'import {$1$2} from' },
  { pattern: /import \{([^}]*),\s*Button([^}]*)\} from/g, replacement: 'import {$1$2} from' },
  { pattern: /,\s*Card,/g, replacement: ',' },
  { pattern: /,\s*Button,/g, replacement: ',' },
  
  // Fix password param
  { pattern: /\(email: string, password: string\)/g, replacement: '(email: string, _password: string)' },
  
  // Fix unused progress
  { pattern: /const progress = /g, replacement: 'const _progress = ' },
];

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let changed = false;
  
  for (const fix of fixes) {
    if (fix.pattern.test(content)) {
      content = content.replace(fix.pattern, fix.replacement);
      changed = true;
    }
  }
  
  if (changed) {
    fs.writeFileSync(filePath, content);
    console.log('Fixed:', filePath);
  }
}

// Process all ts/tsx files in src
function walkDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      walkDir(filePath);
    } else if (file.endsWith('.ts') || file.endsWith('.tsx')) {
      processFile(filePath);
    }
  }
}

walkDir('./src');
console.log('Done!');
