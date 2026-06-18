#!/usr/bin/env bash
set -euo pipefail

# HustleXP TestFlight build + upload — MANUAL distribution signing.
#   Archive (Release) signed with the Apple Distribution identity + the
#   "HustleXP App Store CI" profile (imported by the CI workflow), then export
#   with method=app-store / destination=upload (xcodebuild uploads to TestFlight,
#   authenticated by the App Store Connect API key).
#
#   Bundle ID: taskme.hustleXP-final1   Team: V85B8S6KA2
#
# Env from the workflow:
#   SIGN_IDENTITY  e.g. "Apple Distribution"
#   PROFILE_NAME   e.g. "HustleXP App Store CI"
#   TEAM_ID        e.g. V85B8S6KA2
#   ASC_KEY_PATH/ASC_KEY_ID/ASC_ISSUER_ID  (upload auth)
#
# Raw xcodebuild output is tee'd to build/*.log (uploaded as a CI artifact).

SCHEME="${1:-hustleXP final1}"
CONFIGURATION="${2:-Release}"
PROJECT="hustleXP final1.xcodeproj"
EXPORT_OPTIONS="ExportOptions.plist"
ARCHIVE_PATH="build/HustleXP.xcarchive"
EXPORT_PATH="build/export"
SIGN_IDENTITY="${SIGN_IDENTITY:-Apple Distribution}"
PROFILE_NAME="${PROFILE_NAME:-HustleXP App Store CI}"
TEAM_ID="${TEAM_ID:-V85B8S6KA2}"
mkdir -p build

if grep -q "TEAM_ID_PLACEHOLDER" "$EXPORT_OPTIONS" 2>/dev/null; then
  echo "ERROR: $EXPORT_OPTIONS still contains TEAM_ID_PLACEHOLDER (CI replaces this from APPLE_TEAM_ID)."
  exit 1
fi

echo "=== Archiving ($SCHEME / $CONFIGURATION) — manual signing ==="
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -archivePath "$ARCHIVE_PATH" \
  -destination "generic/platform=iOS" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_IDENTITY="$SIGN_IDENTITY" \
  PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" \
  2>&1 | tee build/archive.log

echo "=== Exporting + uploading to TestFlight ==="
AUTH_FLAGS=()
if [[ -n "${ASC_KEY_PATH:-}" && -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" ]]; then
  AUTH_FLAGS=(-authenticationKeyPath "$ASC_KEY_PATH" \
              -authenticationKeyID "$ASC_KEY_ID" \
              -authenticationKeyIssuerID "$ASC_ISSUER_ID")
fi
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  "${AUTH_FLAGS[@]}" \
  2>&1 | tee build/export.log

echo "Done. Build submitted to App Store Connect; it appears in TestFlight after processing."
