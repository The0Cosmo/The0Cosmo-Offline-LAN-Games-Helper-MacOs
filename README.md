# Offline LAN Games Helper - macOS

Offline LAN Games Helper is a safe macOS GUI utility for LAN/offline multiplayer games that you legally own. It helps with host IP discovery, LAN tutorials, normal game launching, manual firewall guidance, and official dedicated server tools where a real supported server option exists.

This app is not a server emulator. It does not bypass DRM, Steam, Epic, Paradox Launcher, authentication, ownership checks, anti-cheat, online services, or licenses. It does not create cracks, loaders, Steam emulators, patched executables, hooks, injectors, modified game files, or offline-service emulators.

## What The App Does

- Shows the Mac hostname and private LAN IPv4 addresses.
- Warns when multiple LAN/VPN adapters may confuse IP selection.
- Lets you copy the selected host IP for friends.
- Detects installed games from common macOS app paths and Steam libraries.
- Saves manually selected app or executable paths in `user_config.json`.
- Launches selected games normally.
- Opens macOS Firewall/System Settings help without silently changing settings.
- Shows English LAN tutorials, troubleshooting, ports, and compatibility notes.
- Exports a Markdown guide for the selected game.
- Helps with official dedicated server tools only when supported.

## What The App Cannot Do

- It cannot turn online-only games into LAN games.
- It cannot emulate matchmaking, account services, Steam, Epic, Paradox, or other online services.
- It cannot bypass ownership checks or anti-cheat.
- It cannot modify original game files.
- It cannot create a dedicated server for games that only support in-game hosting.

## Run From Source

Open Terminal in this folder on macOS:

```bash
cd "/path/to/MacOs OfflineLan Helper"
python3 lan_games_helper_macos.py
```

If you prepared the project on Windows, copy the folder to your Mac first. The macOS app should be run and built on macOS.

## Build The macOS App

Run on macOS:

```bash
cd "/path/to/MacOs OfflineLan Helper"
chmod +x build_macos.sh
./build_macos.sh
```

The build script:

- creates or uses `.venv`;
- installs `pyinstaller` and `pillow`;
- generates `assets/offline_lan_helper.icns` if needed;
- builds a windowed app bundle;
- copies `games.json` and `user_config.json` beside the app bundle.

The app bundle is created under:

```text
dist/Offline LAN Games Helper macOS.app
```

## macOS Firewall / Permissions

This app does not silently modify macOS firewall settings.

If a game cannot accept LAN connections:

1. Open `System Settings`.
2. Go to `Network` and then `Firewall`, or search for `Firewall`.
3. Allow incoming connections for the game or official server executable.
4. Make sure all players use the same LAN or VPN LAN.

The `Open Firewall Help` button opens System Settings safely and shows the same instructions.

## Selecting macOS Apps

Use `Manual Select Game` when automatic detection fails.

You can select:

- a `.app` bundle from `/Applications`, `~/Applications`, or a Steam library;
- an executable file inside an app bundle;
- a user-provided official server file.

Manual paths are saved in `user_config.json`.

## Server Tools

The `Server Tools` tab is intentionally conservative.

Supported server support types:

- `none`: no supported dedicated server; use in-game hosting if available.
- `in_game_host`: host from inside the game.
- `official_dedicated`: launch or select an official dedicated server executable already installed.
- `steamcmd`: install with SteamCMD only if `games.json` contains a verified official app ID and the user selects SteamCMD.
- `manual_files`: use user-provided local official server files.
- `official_download_page`: open the official download page in a browser.

SteamCMD is used normally. The app does not bundle, emulate, patch, or bypass SteamCMD. If a server requires a purchased game or a logged-in account, follow the official game/server documentation.

Only official SteamCMD app IDs should be added to `games.json`. If an app ID is not verified, leave it blank and use manual files or an official download page instead.

## Add A Custom Game

Use `Add Custom Game` to add a macOS-compatible LAN/offline game that is not in `games.json`.

You can enter:

- game name;
- app or executable path;
- optional ports;
- host tutorial;
- client tutorial;
- server support type;
- optional server file path;
- notes.

Custom games are saved in `user_config.json`. The app never edits the built-in `games.json` when adding a custom game.

## Export Tutorials

Use `Export Tutorial` to create a Markdown guide in:

```text
exported_guides
```

The guide includes the selected game, host IP, LAN tutorial, server tools notes, ports, and troubleshooting.

## Editing games.json

Each built-in game entry uses this schema:

```json
{
  "name": "Game Name",
  "platforms": ["macOS"],
  "lan_status": "Supported / Local server / In-game host",
  "exe_names": [],
  "common_paths_windows": [],
  "common_paths_macos": [],
  "ports": [],
  "host_tutorial": [],
  "client_tutorial": [],
  "offline_notes": [],
  "troubleshooting": [],
  "launch_notes": [],
  "server_support": "in_game_host",
  "server_notes": [],
  "server_files": [],
  "steamcmd_app_id": "",
  "server_executable_names": [],
  "server_common_paths_windows": [],
  "server_common_paths_macos": [],
  "server_install_steps": [],
  "server_launch_command_windows": "",
  "server_launch_command_macos": "",
  "server_config_files": [],
  "server_ports": [],
  "official_download_url": ""
}
```

Only add games that are macOS-compatible and have real offline LAN, local hosting, or official dedicated server support. If support is uncertain, do not add the game.

## Why Some Games Are Excluded

Windows-only games, launcher-only entries, online-only games, and matchmaking-only games are intentionally excluded from the macOS catalog. This helper cannot replace online services or make unsupported games work offline.

Examples intentionally excluded include VALORANT, osu!, Grand Theft Auto V, Cyberpunk 2077, Paradox Launcher v2, BombSquad, Crab Game, Muck, Human: Fall Flat, The Escapists 2, and Windows-only games without reliable macOS LAN support.

## Troubleshooting

- Make sure all players are on the same LAN or VPN LAN.
- Make sure everyone uses the same game version, compatible mods, and compatible DLC setup.
- Copy the host IP from the same interface/network used by the clients.
- If multiple VPN/LAN adapters are listed, try the IP from the active LAN/VPN.
- Verify that clients can ping the host IP.
- Allow incoming connections for the game or server executable in macOS Firewall.
- For dedicated servers, read the official server documentation for config files, saves, and ports.
