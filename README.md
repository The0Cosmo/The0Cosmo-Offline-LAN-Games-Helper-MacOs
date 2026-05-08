# Offline LAN Games Helper - macOS

Offline LAN Games Helper is a native macOS app for LAN/offline multiplayer games that you legally own. It helps with LAN IP discovery, macOS firewall guidance, normal game launching, game-specific tutorials, exported guides, and official dedicated server tools where a real supported server option exists.

This project is not affiliated with Steam, Valve, Paradox, Epic Games, Rockstar, Riot Games, Mojang, Microsoft, Apple, or any game publisher.

## For Normal Users

Download the macOS release as a `.dmg` or `.app`, then open the app normally.

Normal users do not need:

- Python
- Homebrew
- pip
- PyInstaller
- Xcode
- Swift
- terminal commands
- developer tools

The app itself works offline for:

- LAN IP detection
- tutorials
- game path selection
- launching already-installed games
- LAN tests
- save backups
- mod-list export
- controller diagnostics and profile notes
- exporting guides

## Offline Mode

After the app is downloaded and installed, normal LAN-helper features work offline. Optional server downloads and online-only games require internet and are not handled by this app.

Use the `Offline Mode` toggle to hide or block optional internet/download actions. LAN IP detection, tutorials, path selection, launching installed games, LAN tests, backups, mod-list export, invite export, and guide export still work offline.

If macOS blocks the app because it is unsigned or newly downloaded, use macOS System Settings privacy/security controls to allow the app. Do not download repacked copies from unofficial sites.

## Release Files

The maintainer build creates:

```text
dist/Offline LAN Games Helper.app
dist/Offline LAN Games Helper.dmg
```

Distribute the `.dmg` from GitHub Releases. End users should only need to download the `.dmg`, open it, and launch the app.

## Supported Platform

- macOS 13 or newer
- Native Swift/SwiftUI app
- No Windows firewall, Windows registry, or `.exe` build logic
- No Python runtime required for the final app

## What The App Does

- Shows the Mac hostname and private LAN IPv4 addresses.
- Shows network interface names when available.
- Warns when multiple LAN/VPN adapters may confuse IP selection.
- Copies the selected host IP.
- Tests one user-entered or selected LAN IP with ping and one TCP port.
- Generates copyable/exportable invite messages for friends.
- Allows manual selection of `.app` bundles or executable files.
- Saves local settings in the user's Application Support folder.
- Launches selected games normally.
- Opens macOS System Settings for firewall/permissions help.
- Creates timestamped save/world backups and restores backups only after confirmation.
- Exports mod file lists for Minecraft Java and other modded games so players can compare setups.
- Includes safe macOS controller guidance and diagnostics.
- Shows English tutorials, ports, notes, troubleshooting, and privacy text.
- Exports Markdown LAN/server guides.
- Helps with official dedicated server tools only when supported, including status for server processes started by this app.

## What The App Cannot Do

- It cannot turn online-only games into LAN games.
- It cannot emulate matchmaking, account services, Steam, Epic, Paradox, or other online services.
- It cannot bypass DRM, launchers, authentication, game ownership checks, anti-cheat, or licenses.
- It cannot create cracks, loaders, Steam emulators, patched executables, hooks, injectors, modified game files, or offline-service emulators.
- It cannot modify original game files.
- It cannot silently change macOS firewall rules.
- It cannot create a dedicated server for games that only support in-game hosting.

## macOS Firewall / Permissions

The app includes a `Firewall / Permissions` tab with this policy:

```text
On macOS, you may need to allow incoming connections for the game or server app in System Settings. This helper does not silently change firewall settings.
```

Use `Open macOS System Settings` to open System Settings safely. If the exact firewall pane is not available on your macOS version, open System Settings and search for `Firewall`.

## Server Tools

Normal LAN helper features work offline and do not require downloads.

Server Tools are optional and can only:

- open official download pages;
- use official SteamCMD app IDs if verified and listed;
- launch official dedicated server executables;
- let the user select local official server files;
- export instructions.

Server Tools cannot create fake servers, emulate online services, bypass authentication, patch game files, or download from unofficial sources.

If Server Tools require SteamCMD or official dedicated server files, the app marks those as optional external tools. Those tools may connect to official services.

If server support is unavailable, the app shows:

```text
No supported dedicated server is available for this game. Host from inside the game if supported.
```

If a game has no official dedicated server, use in-game hosting.

The Server Tools tab also shows whether a dedicated server process started by this app is running or stopped. `Start Server` starts only the selected official server file. `Stop Server` asks for confirmation and only stops a server process that this app started for the selected game. It does not kill unrelated processes.

## LAN Test / Connection Test

Use `LAN Test` to test one IP address that you enter or select. The app can:

- ping the target IP;
- test one TCP port;
- use the selected game's default ports from `games.json` when listed.

This is not a scanner. It does not scan the internet, random IP ranges, or LAN ranges.

## Invites

Use `Copy Invite` or `Export Invite` to generate a ready-to-send message with the selected game name, host IP, port, and client join instructions.

## Backups

Use `Backups` to select a world/save folder and create timestamped `.zip` backups in the user's Application Support folder:

```text
Application Support/Offline LAN Games Helper/backups/GAME_NAME
```

Restore requires confirmation. Restoring can overwrite files with matching names, but the helper does not delete original saves.

## Mod List Export

Use `Mods` to select a mods folder and export file names, sizes, and modified dates. Share the exported list with other players so everyone can compare mod setups before joining a modded LAN session.

The app does not download, install, or update mods.

## Controller Helper on macOS

The macOS version includes safe controller guidance and diagnostics.

It can open macOS settings, show basic connected controller information where available, and provide Steam Input / local multiplayer setup checklists.

HidHide and DS4Windows are Windows-only and are not included in the macOS version.

The app does not install drivers, hook input, inject into games, patch executables, or bypass anti-cheat/DRM.

The Controller Helper can:

- open Bluetooth Settings;
- open Game Controller Settings if the current macOS version provides that pane;
- open Privacy & Security Settings;
- open Steam or Steam Support help;
- copy a macOS controller checklist;
- copy a Steam Input checklist;
- show controller name/status through Apple's local GameController framework when available;
- save local multiplayer controller profile notes on your Mac.

For Minecraft Java and Prism Launcher, controller mods may not isolate input per window. Do not use Controlify and MidnightControls together. Use only one controller mod at a time and keep separate Prism Launcher instances/configs per player when testing.

## Game Filtering

The macOS catalog keeps only games that are macOS-compatible and have real offline LAN, local hosting, or official dedicated server possibilities.

Included macOS catalog:

- Terraria
- Stardew Valley
- Valheim
- Minecraft Java Edition
- Factorio
- Project Zomboid
- OpenTTD
- Xonotic
- Teeworlds
- Hedgewars
- 0 A.D.

Removed from macOS: VALORANT, osu!, Grand Theft Auto V, Cyberpunk 2077, Paradox Launcher v2, BombSquad, Crab Game, Muck, Windows-only games, online-only games, matchmaking-only games, and uncertain games.

## Support / Donate

Offline LAN Games Helper is free to use.

If the app helped you and you want to support development, you can donate here:

- PayPal: https://paypal.me/REPLACE_WITH_MY_PAYPALME
- GitHub Sponsors: https://github.com/sponsors/The0Cosmo

Donations are optional and do not unlock extra features.

## Privacy

Offline LAN Games Helper works locally on your device. It does not collect, sell, share, or upload personal data. It may read local network information such as your LAN IP address and adapter names only to show them inside the app.

See [PRIVACY.md](PRIVACY.md) for details.

## License

Copyright (c) 2026 The0Cosmo. All rights reserved.

This software is for personal, non-commercial use only. See [LICENSE](LICENSE) for the full license terms.

## Maintainer Build Instructions

These steps are for the developer or release maintainer only. End users do not need them.

Build on macOS with Xcode command line tools or Xcode installed:

```bash
cd "/path/to/MacOs OfflineLan Helper"
chmod +x build_macos.sh
./build_macos.sh
```

The script:

- builds the SwiftUI app with `swift build -c release`;
- creates `dist/Offline LAN Games Helper.app`;
- copies `games.json`, `README.md`, `PRIVACY.md`, `LICENSE`, and the icon into the app bundle;
- applies ad-hoc local code signing when `codesign` is available;
- creates `dist/Offline LAN Games Helper.dmg` when `hdiutil` is available.

This repository also keeps `lan_games_helper_macos.py` as a developer fallback/reference implementation. It is not required for the final macOS app and should not be required for end users.

## Troubleshooting

- Make sure all players are on the same LAN or VPN LAN.
- Make sure everyone uses the same game version, compatible mods, and compatible DLC setup.
- Copy the host IP from the same interface/network used by the clients.
- If multiple VPN/LAN adapters are listed, try the IP from the active LAN/VPN.
- Verify that clients can ping the host IP.
- Allow incoming connections for the game or server executable in macOS Firewall.
- For dedicated servers, read the official server documentation for config files, saves, and ports.
