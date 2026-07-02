#!/bin/bash
set -euo pipefail
VERSION="${1:-1.0.0}"
CONFIGURATION="${2:-Release}"
swift build -c "$CONFIGURATION"
# Archive .app bundle
mkdir -p dist
cp -r .build/"$CONFIGURATION"/BooBooGUI.app dist/
cp -r .build/"$CONFIGURATION"/booboo dist/
echo "Archived to dist/"
