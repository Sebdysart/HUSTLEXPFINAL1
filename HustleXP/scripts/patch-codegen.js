/**
 * Postinstall patch:
 * React Native codegen (RCTThirdPartyComponentsProvider.mm) sometimes needs a nil-safe
 * dictionary creation fix for downstream builds.
 *
 * Node-only implementation so Windows users don't need WSL/bash.
 */

const fs = require('fs');
const path = require('path');

const CODEGEN_FILE_REL = path.join(
  'ios',
  'build',
  'generated',
  'ios',
  'ReactCodegen',
  'RCTThirdPartyComponentsProvider.mm',
);

const CODEGEN_FILE = path.join(process.cwd(), CODEGEN_FILE_REL);

const TEMPLATE = `/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


//#import <Foundation/Foundation.h>

//#import "RCTThirdPartyComponentsProvider.h"
//#import <React/RCTComponentViewProtocol.h>

@implementation RCTThirdPartyComponentsProvider

+ (NSDictionary<NSString *, Class<RCTComponentViewProtocol>> *)thirdPartyFabricComponents
{
  static NSDictionary<NSString *, Class<RCTComponentViewProtocol>> *thirdPartyComponents = nil;
  static dispatch_once_t nativeComponentsToken;

  dispatch_once(&nativeComponentsToken, ^{
    NSMutableDictionary<NSString *, Class<RCTComponentViewProtocol>> *components = [NSMutableDictionary dictionary];
    
    // react-native-safe-area-context
    Class rncsafeareaproviderClass = NSClassFromString(@"RNCSafeAreaProviderComponentView");
    if (rncsafeareaproviderClass) {
      components[@"RNCSafeAreaProvider"] = rncsafeareaproviderClass;
    }
    
    Class rncsafeareaClass = NSClassFromString(@"RNCSafeAreaViewComponentView");
    if (rncsafeareaClass) {
      components[@"RNCSafeAreaView"] = rncsafeareaClass;
    }
    
    thirdPartyComponents = [components copy];
  });

  return thirdPartyComponents;
}

@end
`;

function log(msg) {
  // Keep output short; install logs get noisy already.
  // eslint-disable-next-line no-console
  console.log(`[Patch Codegen] ${msg}`);
}

try {
  if (!fs.existsSync(CODEGEN_FILE)) {
    log(`File not found: ${CODEGEN_FILE_REL}. Codegen may not have run yet.`);
    process.exit(0);
  }

  const current = fs.readFileSync(CODEGEN_FILE, 'utf8');
  if (current.includes('NSMutableDictionary') && current.includes('RCTThirdPartyComponentsProvider')) {
    log('File already patched, skipping...');
    process.exit(0);
  }

  const bak = `${CODEGEN_FILE}.bak`;
  fs.copyFileSync(CODEGEN_FILE, bak);
  fs.writeFileSync(CODEGEN_FILE, TEMPLATE, 'utf8');
  log(`Successfully patched ${CODEGEN_FILE_REL}`);
  process.exit(0);
} catch (err) {
  // Never fail installation.
  // eslint-disable-next-line no-console
  console.warn('[Patch Codegen] Warning:', err instanceof Error ? err.message : String(err));
  process.exit(0);
}

