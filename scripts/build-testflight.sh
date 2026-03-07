#!/usr/bin/env bash
set -euo pipefail

# HustleXP TestFlight Build Script
# Usage: ./scripts/build-testflight.sh [SCHEME] [CONFIGURATION]
# Defaults: SCHEME="hustleXP final1", CONFIGURATION=Release
#
# Bundle ID: taskme.hustleXP-final1
# Team ID:   V85B8S6KA2 (confirm at https://developer.apple.com/account)
#
# Prerequisites:
#   - Xcode 16+ installed
#   - xcpretty: gem install xcpretty
#   - Apple Developer account signed in to Xcode (for automatic signing)
#   - ExportOptions.plist has TEAM_ID_PLACEHOLDER replaced with real Team ID

SCHEME="${1:-hustleXP final1}"
CONFIGURATION="${2:-Release}"
PROJECT="hustleXP final1.xcodeproj"
EXPORT_OPTIONS="ExportOptions.plist"
ARCHIVE_PATH="build/HustleXP.xcarchive"
IPA_PATH="build/ipa"

# Resolve xcpretty — if not found, fall back to cat so the script still works
if command -v xcpretty &>/dev/null; then
    PRETTY="xcpretty"
else
    echo "Warning: xcpretty not found. Run 'gem install xcpretty' for cleaner output."
    PRETTY="cat"
fi

echo "Building HustleXP for TestFlight"
echo "  Project:       $PROJECT"
echo "  Scheme:        $SCHEME"
echo "  Configuration: $CONFIGURATION"
echo "  Archive path:  $ARCHIVE_PATH"

# Verify ExportOptions.plist is configured
if grep -q "TEAM_ID_PLACEHOLDER" "$EXPORT_OPTIONS" 2>/dev/null; then
    echo ""
    echo "ERROR: ExportOptions.plist still contains TEAM_ID_PLACEHOLDER."
    echo "       Replace it with your Apple Developer Team ID (e.g. V85B8S6KA2)."
    echo "       See TESTFLIGHT_SETUP.md for instructions."
    exit 1
fi

# Clean
echo ""
echo "--- Cleaning ---"
xcodebuild clean \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    | $PRETTY || true

# Archive
echo ""
echo "--- Archiving ---"
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    CODE_SIGNING_ALLOWED=YES \
    | $PRETTY

echo "Archive created at $ARCHIVE_PATH"

# Export IPA for TestFlight
echo ""
echo "--- Exporting IPA ---"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$IPA_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    | $PRETTY

echo "IPA exported to $IPA_PATH"
echo ""
echo "Next step — upload to TestFlight:"
echo "  xcrun altool --upload-app --type ios \\"
echo "    --file \"$IPA_PATH/*.ipa\" \\"
echo "    --apiKey YOUR_API_KEY \\"
echo "    --apiIssuer YOUR_ISSUER_ID \\"
echo "    --private-key-path AuthKey_KEYID.p8"
echo ""
echo "Or via the GitHub Actions workflow: push to main or use workflow_dispatch."
