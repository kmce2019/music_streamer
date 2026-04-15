# Music Streamer

A legally safer, production-minded, cross-platform music app inspired by modern local-first players.

## Current MVP scope
- Flutter app shell with GoRouter navigation.
- BLoC/Cubit state management and strict layered architecture.
- Local music import from a user-selected folder.
- Playback via `just_audio` with queue, seek, shuffle, repeat, and mini/full player surfaces.
- Search, favorites, playlists, history, theme settings.
- Plugin runtime with capability declarations and safety policy checks.
- Safe bundled plugin: internet radio directory.

## Legal and safety constraints
This project intentionally avoids scraping, DRM circumvention, ad bypassing, or unauthorized extraction from third-party services.

## Important implementation notes
- Persistence is currently **MVP in-memory storage** (`InMemoryDb`) to keep architecture stable while Isar/Drift integration is finalized.
- Plugin signature validation is currently a **checksum/policy gate scaffold**; production detached signature verification is planned in Rust helpers.

## Prerequisites
1. Flutter SDK stable (3.24+ recommended).
2. A desktop/mobile toolchain for your target (Android Studio/Xcode/desktop build deps).

## Exact run instructions
From repo root:

```bash
flutter pub get
```

If this repository was not initialized with platform folders yet, generate them once:

```bash
flutter create --platforms=android,ios,linux,macos,windows,web .
```

Then run on a specific target:

```bash
flutter run -d linux
# or: flutter run -d chrome
# or: flutter run -d android
```

## Local import + playback smoke test
1. Open **Library** tab.
2. Click the folder icon to choose a directory containing `.mp3/.m4a/.flac/.wav/.ogg` files.
3. Tap any imported track to load queue + play.
4. Open **Now Playing** tab for seek/shuffle/repeat controls.

## Tests
```bash
flutter test
```

## Project docs
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [ROADMAP.md](ROADMAP.md)
- [TODO.md](TODO.md)

## Rust helper placeholder
See `rust/` for optional performance/security helper integration points.


## Third-party source note
Integrations like iHeartRadio should only be added when using an official, documented API with terms-compliant authentication and usage.
