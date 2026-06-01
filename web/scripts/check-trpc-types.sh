#!/usr/bin/env bash
# Verify the vendored AppRouter.d.ts has NOT drifted from the backend.
#
# This is a READ-ONLY check (it never writes the vendored file). It exits
# non-zero on drift so it can gate CI / pre-push and stop the web client from
# silently compiling against a stale backend contract.
#
# Source-of-truth resolution (first that works wins):
#   1. Local backend checkout  — set HUSTLEXP_BACKEND_DIR to the backend repo
#      root (the dir containing dist-types/AppRouter.d.ts). Preferred: it
#      reflects the on-machine backend, including unpushed work.
#   2. GitHub (fallback)        — fetched via `gh` from $REPO@$REF. NOTE: this
#      only sees COMMITTED+PUSHED backend state, so it can report a false
#      "drift" when local backend has unpushed type changes. The script says
#      which source it used so the result is never ambiguous.
#
# Usage:
#   ./scripts/check-trpc-types.sh            # check, exit 1 on drift
#   HUSTLEXP_BACKEND_DIR=/path/to/backend ./scripts/check-trpc-types.sh

set -euo pipefail

REPO="${HUSTLEXP_BACKEND_REPO:-Sebdysart/hustlexp-ai-backend}"
REF="${HUSTLEXP_BACKEND_REF:-claude/audit-backend-workflow-mFb7a}"
SRC_PATH="dist-types/AppRouter.d.ts"
DEST_PATH="types/trpc/AppRouter.d.ts"

cd "$(dirname "$0")/.."

if [[ ! -f "$DEST_PATH" ]]; then
  echo "FATAL: vendored $DEST_PATH does not exist" >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

SOURCE=""
if [[ -n "${HUSTLEXP_BACKEND_DIR:-}" && -f "$HUSTLEXP_BACKEND_DIR/$SRC_PATH" ]]; then
  cp "$HUSTLEXP_BACKEND_DIR/$SRC_PATH" "$TMP"
  SOURCE="local backend checkout: $HUSTLEXP_BACKEND_DIR/$SRC_PATH"
else
  if ! command -v gh >/dev/null 2>&1; then
    echo "FATAL: HUSTLEXP_BACKEND_DIR not set/usable and 'gh' not installed." >&2
    echo "       Set HUSTLEXP_BACKEND_DIR to your local backend repo root." >&2
    exit 2
  fi
  echo "Fetching $REPO@$REF:$SRC_PATH (committed+pushed state only) ..."
  gh api "repos/$REPO/contents/$SRC_PATH?ref=$REF" \
    -H "Accept: application/vnd.github.raw" > "$TMP"
  SOURCE="GitHub $REPO@$REF (committed+pushed only)"
fi

if ! grep -q "export type AppRouter" "$TMP"; then
  echo "FATAL: source ($SOURCE) does not export AppRouter — refusing to compare." >&2
  exit 1
fi

if diff -q "$TMP" "$DEST_PATH" >/dev/null; then
  echo "OK: $DEST_PATH is in sync with $SOURCE"
  exit 0
fi

echo "DRIFT: $DEST_PATH differs from $SOURCE" >&2
echo "  source lines: $(wc -l < "$TMP" | tr -d ' '), vendored lines: $(wc -l < "$DEST_PATH" | tr -d ' ')" >&2
echo "  Run ./scripts/sync-trpc-types.sh to update the vendored copy," >&2
echo "  but first confirm the backend types you want are pushed to $REF" >&2
echo "  (or sync from a local checkout via HUSTLEXP_BACKEND_DIR)." >&2
exit 1
