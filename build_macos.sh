#!/usr/bin/env bash
set -euo pipefail
swift build -c release
mkdir -p dist
cp -R .build/release/OfflineLANHelperMac dist/OfflineLANHelperMac
