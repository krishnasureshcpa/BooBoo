#!/bin/bash
set -euo pipefail
CONFIGURATION="${1:-Debug}"
swift build -c "$CONFIGURATION"
