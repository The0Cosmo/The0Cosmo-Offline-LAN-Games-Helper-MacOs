#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV="$ROOT/.venv"

if [ ! -x "$VENV/bin/python" ]; then
  "$PYTHON_BIN" -m venv "$VENV"
fi

"$VENV/bin/python" -m pip install --upgrade pip
"$VENV/bin/python" -m pip install pyinstaller pillow

"$VENV/bin/python" "$ROOT/make_icon_macos.py"

"$VENV/bin/python" -m PyInstaller \
  --windowed \
  --name "Offline LAN Games Helper macOS" \
  --icon "assets/offline_lan_helper.icns" \
  --add-data "games.json:." \
  "$ROOT/lan_games_helper_macos.py"

mkdir -p "$ROOT/dist"
cp "$ROOT/games.json" "$ROOT/dist/games.json"
cp "$ROOT/user_config.json" "$ROOT/dist/user_config.json"

echo
echo "Build complete."
echo "App bundle: $ROOT/dist/Offline LAN Games Helper macOS.app"
echo "Editable data files copied beside the app: dist/games.json, dist/user_config.json"
