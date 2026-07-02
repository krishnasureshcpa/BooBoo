#!/bin/bash
set -euo pipefail
if command -v swiftlint &>/dev/null; then
    swiftlint --strict
else
    echo "swiftlint not installed, skipping"
fi
