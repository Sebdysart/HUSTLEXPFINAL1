#!/bin/bash
# Patch RCTThirdPartyComponentsProvider.mm to use nil-safe dictionary creation
# This runs after codegen but before compilation

set -e

CODEGEN_FILE="ios/build/generated/ios/ReactCodegen/RCTThirdPartyComponentsProvider.mm"

if [ ! -f "$CODEGEN_FILE" ]; then
  echo "[Patch Codegen] File not found: $CODEGEN_FILE"
  echo "[Patch Codegen] Codegen may not have run yet. This is OK."
  exit 0
fi

# Check if already patched
if grep -q "NSMutableDictionary" "$CODEGEN_FILE"; then
  echo "[Patch Codegen] File already patched, skipping..."
  exit 0
fi

# Create backup
cp "$CODEGEN_FILE" "$CODEGEN_FILE.bak"

# Patch the file to use nil-safe dictionary creation
cat > "$CODEGEN_FILE" << 'EOF'
/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import <Foundation/Foundation.h>

#import "RCTThirdPartyComponentsProvider.h"
#import <React/RCTComponentViewProtocol.h>

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
EOF

echo "[Patch Codegen] Successfully patched $CODEGEN_FILE with nil-safe dictionary creation"
