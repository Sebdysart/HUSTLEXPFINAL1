#!/bin/bash
# iOS SwiftLint check script
# Usage: ./scripts/lint-ios.sh [--strict]
# --strict: exit non-zero on warnings (CI mode)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! command -v swiftlint &> /dev/null; then
    echo "⚠️  SwiftLint not installed. Run: brew install swiftlint"
    exit 0
fi

echo "Running SwiftLint..."
cd "$REPO_ROOT"

if [ "$1" == "--strict" ]; then
    swiftlint lint --config .swiftlint.yml --strict
else
    swiftlint lint --config .swiftlint.yml
fi

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ SwiftLint passed"
else
    echo "❌ SwiftLint found violations (exit code: $EXIT_CODE)"
fi
exit $EXIT_CODE
