# Offline LAN Games Helper - macOS

Created by **KiwiLiu**.

Native SwiftUI macOS version of Offline LAN Games Helper. It loads supported macOS LAN/offline game info only when a game is clicked, uses scrollable readable text, includes text size controls, themes, settings, and short invite copy modes.

Normal users should use a built `.app`/`.dmg`. Developers can build with:

```bash
swift build -c release
```

Safety: this app does not bypass DRM, launchers, authentication, anti-cheat, ownership checks, or online services.

## Optimized Game Detail Loading

The macOS SwiftUI version loads the game catalog once, then loads each game's detailed LAN/offline instructions only after the user selects that game. A progress indicator appears while the selected game's details are prepared. Details are cached in memory while the app is open.

Settings open separately from the game list, and text size can be changed with A- / A+ or in Settings.
