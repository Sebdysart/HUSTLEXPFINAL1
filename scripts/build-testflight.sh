#!/usr/bin/env bash
set -euo pipefail

# HustleXP TestFlight build + upload.
#   1) Archive (Release) with AUTOMATIC signing via the App Store Connect API key
#      (xcodebuild picks a development identity — this succeeds and embeds the
#      SPM frameworks correctly; provisioning profiles are NOT forced globally).
#   2) Export with MANUAL distribution signing via ExportOptions.plist, which
#      re-signs ONLY the app with the imported "Apple Distribution" cert + the
#      "HustleXP App Store CI" profile, then uploads (destination=upload),
#      authenticated by the same API key.
#
#   Bundle ID: taskme.hustleXP-final1   Team: V85B8S6KA2
#
# Env from the workflow:
#   ASC_KEY_PATH / ASC_KEY_ID / ASC_ISSUER_ID   (signing-asset fetch + upload)
# Raw xcodebuild output is tee'd to build/*.log (uploaded as a CI artifact).

SCHEME="${1:-hustleXP final1}"
CONFIGURATION="${2:-Release}"
PROJECT="hustleXP final1.xcodeproj"
EXPORT_OPTIONS="ExportOptions.plist"
ARCHIVE_PATH="build/HustleXP.xcarchive"
EXPORT_PATH="build/export"
mkdir -p build

if grep -q "TEAM_ID_PLACEHOLDER" "$EXPORT_OPTIONS" 2>/dev/null; then
  echo "ERROR: $EXPORT_OPTIONS still contains TEAM_ID_PLACEHOLDER (CI replaces this from APPLE_TEAM_ID)."
  exit 1
fi

AUTH=()
if [[ -n "${ASC_KEY_PATH:-}" && -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]]; then
  AUTH=(-authenticationKeyPath "$ASC_KEY_PATH" \
        -authenticationKeyID "$ASC_KEY_ID" \
        -authenticationKeyIssuerID "$ASC_ISSUER_ID")
fi

echo "=== Archiving ($SCHEME / $CONFIGURATION) — automatic signing ==="
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  "${AUTH[@]}" \
  2>&1 | tee build/archive.log

echo "=== Exporting (manual dist signing) + uploading to TestFlight ==="
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  "${AUTH[@]}" \
  2>&1 | tee build/export.log

echo "Done. Build submitted to App Store Connect; it appears in TestFlight after processing."
