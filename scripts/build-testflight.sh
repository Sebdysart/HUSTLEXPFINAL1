#!/usr/bin/env bash
set -euo pipefail

# HustleXP TestFlight build + upload.
#   Archive (Release) -> export with method=app-store, destination=upload.
#   Auth uses an App Store Connect API key when ASC_* env vars are set (CI);
#   otherwise falls back to the Apple ID signed into Xcode (local use).
#
#   Bundle ID: taskme.hustleXP-final1   Team: V85B8S6KA2
#
# Raw xcodebuild output is tee'd to build/*.log (uploaded as a CI artifact) and
# printed in full — no xcpretty, so signing/compile errors are never hidden.

SCHEME="${1:-hustleXP final1}"
CONFIGURATION="${2:-Release}"
PROJECT="hustleXP final1.xcodeproj"
EXPORT_OPTIONS="ExportOptions.plist"
ARCHIVE_PATH="build/HustleXP.xcarchive"
EXPORT_PATH="build/export"
mkdir -p build

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
  echo "ERROR: $EXPORT_OPTIONS still contains TEAM_ID_PLACEHOLDER (CI replaces this from APPLE_TEAM_ID)."
  exit 1
fi

echo "=== Archiving ($SCHEME / $CONFIGURATION) ==="
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  "${AUTH_FLAGS[@]}" \
  2>&1 | tee build/archive.log

echo "=== Exporting + uploading to TestFlight ==="
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates \
  "${AUTH_FLAGS[@]}" \
  2>&1 | tee build/export.log

echo "Done. Build submitted to App Store Connect; it appears in TestFlight after processing."
