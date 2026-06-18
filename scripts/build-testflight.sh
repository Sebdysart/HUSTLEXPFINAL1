#!/usr/bin/env bash
set -euo pipefail

# HustleXP TestFlight build + upload.
#   Archive (Release) -> export with method=app-store, destination=upload.
#   Signing & upload authenticate with an App Store Connect API key when the
#   ASC_* env vars are set (CI). Locally, if they are unset, xcodebuild falls
#   back to the Apple ID signed into Xcode.
#
#   Bundle ID: taskme.hustleXP-final1   Team: V85B8S6KA2
#
# Env (set by the GitHub Actions workflow):
#   ASC_KEY_PATH    absolute path to the decoded AuthKey_XXXX.p8
#   ASC_KEY_ID      App Store Connect API Key ID
#   ASC_ISSUER_ID   App Store Connect API Issuer ID

SCHEME="${1:-hustleXP final1}"
CONFIGURATION="${2:-Release}"
PROJECT="hustleXP final1.xcodeproj"
EXPORT_OPTIONS="ExportOptions.plist"
ARCHIVE_PATH="build/HustleXP.xcarchive"
EXPORT_PATH="build/export"

if command -v xcpretty &>/dev/null; then PRETTY="xcpretty"; else PRETTY="cat"; fi

# Build the optional App Store Connect API auth flags as an array.
AUTH_FLAGS=()
if [[ -n "${ASC_KEY_PATH:-}" && -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]]; then
  echo "Using App Store Connect API key auth (Key ID: ${ASC_KEY_ID})"
  AUTH_FLAGS=(-authenticationKeyPath "$ASC_KEY_PATH" \
              -authenticationKeyID "$ASC_KEY_ID" \
              -authenticationKeyIssuerID "$ASC_ISSUER_ID")
else
  echo "No ASC_* env vars set — relying on the Apple ID signed into Xcode (local use)."
fi

if grep -q "TEAM_ID_PLACEHOLDER" "$EXPORT_OPTIONS" 2>/dev/null; then
  echo "ERROR: $EXPORT_OPTIONS still contains TEAM_ID_PLACEHOLDER."
  echo "       In CI this is replaced from the APPLE_TEAM_ID secret; locally run:"
  echo "       sed -i '' 's/TEAM_ID_PLACEHOLDER/V85B8S6KA2/' $EXPORT_OPTIONS"
  exit 1
fi

echo "=== Archiving ($SCHEME / $CONFIGURATION) ==="
set -o pipefail
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  "${AUTH_FLAGS[@]}" \
  | $PRETTY

echo "=== Exporting + uploading to TestFlight ==="
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates \
  "${AUTH_FLAGS[@]}" \
  | $PRETTY

echo "Done. Build submitted to App Store Connect; it appears in TestFlight after processing."
